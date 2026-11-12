import 'dart:async';

import 'package:trvlez_mobile/features/verification/domain/repositories/verification_repository.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_job_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_status.dart';

/// A service to poll the backend for verification job updates using exponential backoff.
class VerificationPollingService {
  final VerificationRepository repository;

  bool _isPolling = false;

  VerificationPollingService({required this.repository});

  /// Starts polling the verification job.
  ///
  /// The [onUpdate] callback is triggered whenever a successful response is received.
  /// If the job completes (either verified or failed), polling stops automatically.
  Future<void> startPolling({
    required String jobId,
    int initialIntervalSeconds = 2,
    int maxIntervalSeconds = 15,
    int maxDurationSeconds = 300,
    required void Function(
      VerificationJobResult jobResult,
      VerificationStatus? domainStatus,
    )
    onUpdate,
    void Function()? onTimeout,
  }) async {
    _isPolling = true;
    int currentInterval = initialIntervalSeconds;
    int totalElapsed = 0;
    bool completed = false;

    while (_isPolling && totalElapsed < maxDurationSeconds) {
      await Future.delayed(Duration(seconds: currentInterval));

      if (!_isPolling) {
        break; // Check again in case it was cancelled during delay
      }

      try {
        final jobResult = await repository.getVerificationJob(jobId);
        VerificationStatus? status;

        // If the job failed or completed, try to fetch the domain status to get uiMitigation
        if (jobResult.isComplete) {
          try {
            status = await repository.getVerificationStatus();
          } catch (_) {
            // Ignore status fetch error, use what we have in jobResult
          }
        }

        if (!_isPolling) break;

        onUpdate(jobResult, status);

        if (jobResult.isComplete) {
          completed = true;
          _isPolling = false;
          break;
        }
      } catch (_) {
        // Non-critical network error — continue polling
      }

      totalElapsed += currentInterval;
      if (currentInterval < maxIntervalSeconds) {
        currentInterval = (currentInterval * 2).clamp(1, maxIntervalSeconds);
      }
    }

    final timedOut =
        _isPolling && totalElapsed >= maxDurationSeconds && !completed;
    _isPolling = false;
    if (timedOut) {
      onTimeout;
    }
  }

  void stopPolling() {
    _isPolling = false;
  }
}
