import 'package:dio/dio.dart';
import 'package:trvlez_mobile/core/attribution/attribution_dto.dart';
import 'package:trvlez_mobile/core/attribution/attribution_remote_data_source.dart';
import 'package:trvlez_mobile/core/attribution/install_referrer_client.dart';
import 'package:trvlez_mobile/core/network/api_exception.dart';
import 'package:trvlez_mobile/core/storage/attribution_storage.dart';
import 'package:trvlez_mobile/core/utils/app_logger.dart';

/// Orchestrates Android Google Play Install Referrer capture and backend attribution handoff.
class AttributionService {
  static const int _statusBadRequest = 400;
  static const int _statusNotFound = 404;
  static const int _statusGone = 410;

  final InstallReferrerClient installReferrerClient;
  final AttributionStorage attributionStorage;
  final AttributionRemoteDataSource remoteDataSource;

  const AttributionService({
    required this.installReferrerClient,
    required this.attributionStorage,
    required this.remoteDataSource,
  });

  /// Captures `click_reference` from Play Store on first launch and submits install evidence.
  ///
  /// This operation is non-blocking and safe to run in the background on startup.
  /// It is idempotent:
  /// - If already recorded, returns immediately.
  /// - If non-Android, skips safely.
  /// - If network fails, preserves captured reference to retry on next launch or resume.
  Future<bool> captureInstallReferrer() async {
    try {
      if (attributionStorage.isInstallEvidenceRecorded()) {
        AppLogger.debug(
          '[Attribution] Install evidence already recorded; skipping.',
        );
        return true;
      }

      if (!installReferrerClient.isSupportedPlatform) {
        AppLogger.debug(
          '[Attribution] Non-Android platform; skipping install referrer.',
        );
        return false;
      }

      final pendingCandidate = await _resolvePendingClickReference();
      if (pendingCandidate == null) {
        return false;
      }

      return await _submitInstallEvidence(
        pendingCandidate.clickReference,
        occurredAt: pendingCandidate.occurredAt,
      );
    } on DioException catch (dioException) {
      return _handleDioException(dioException);
    } catch (unexpectedError, stackTrace) {
      AppLogger.warning(
        '[Attribution] Unexpected error capturing install referrer',
        unexpectedError,
        stackTrace,
      );
      return false;
    }
  }

  /// Resolves the referral click reference from local cache or queries the native Play Referrer.
  Future<_PendingReferralCandidate?> _resolvePendingClickReference() async {
    final cachedReference = attributionStorage.getClickReference();
    if (cachedReference != null && cachedReference.isNotEmpty) {
      return _PendingReferralCandidate(clickReference: cachedReference);
    }

    if (attributionStorage.isInstallReferrerChecked()) {
      AppLogger.debug(
        '[Attribution] Install referrer already checked previously; none found.',
      );
      return null;
    }

    final referrerResult = await installReferrerClient.getInstallReferrer();
    await attributionStorage.setInstallReferrerChecked(true);

    final capturedToken = referrerResult?.clickReference;
    if (capturedToken == null || capturedToken.isEmpty) {
      AppLogger.debug(
        '[Attribution] No click reference found in install referrer.',
      );
      return null;
    }

    await attributionStorage.saveClickReference(capturedToken);
    AppLogger.debug(
      '[Attribution] Captured click reference from Play Referrer',
    );
    return _PendingReferralCandidate(
      clickReference: capturedToken,
      occurredAt: referrerResult?.clickTimestamp,
    );
  }

  /// Submits the install evidence payload to the backend and records success.
  Future<bool> _submitInstallEvidence(
    String clickReference, {
    DateTime? occurredAt,
  }) async {
    AppLogger.debug('[Attribution] Submitting install evidence...');
    final response = await remoteDataSource.recordInstallEvidence(
      InstallEvidenceRequestDto(
        clickReference: clickReference,
        occurredAt: occurredAt,
      ),
    );

    if (response.valid) {
      await attributionStorage.setInstallEvidenceRecorded(true);
      AppLogger.debug('[Attribution] Successfully verified install evidence');
      return true;
    }

    return false;
  }

  /// Handles Dio errors, marking evidence recorded on permanent errors to prevent infinite loops.
  Future<bool> _handleDioException(DioException dioException) async {
    final innerError = dioException.error;
    final int? statusCode = innerError is ApiException
        ? innerError.statusCode
        : dioException.response?.statusCode;

    final isTerminalError =
        statusCode == _statusBadRequest ||
        statusCode == _statusNotFound ||
        statusCode == _statusGone;

    if (isTerminalError) {
      AppLogger.debug(
        '[Attribution] Terminal referral status $statusCode; marking recorded.',
      );
      await attributionStorage.setInstallEvidenceRecorded(true);
      return false;
    }

    AppLogger.warning(
      '[Attribution] Transient network/server error recording install evidence: ${dioException.type}',
    );
    return false;
  }
}

/// Helper container holding candidate referral attributes pending submission.
class _PendingReferralCandidate {
  final String clickReference;
  final DateTime? occurredAt;

  const _PendingReferralCandidate({
    required this.clickReference,
    this.occurredAt,
  });
}
