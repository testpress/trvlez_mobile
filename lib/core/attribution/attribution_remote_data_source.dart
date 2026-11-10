import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/attribution/attribution_dto.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/network/dio_provider.dart';

/// Remote data source for recording mobile install evidence with the TrvlEz backend.
class AttributionRemoteDataSource {
  final Dio dio;

  const AttributionRemoteDataSource({required this.dio});

  /// Posts install evidence to `POST /public/referrals/traveler/install-evidence`.
  Future<InstallEvidenceResponseDto> recordInstallEvidence(
    InstallEvidenceRequestDto requestDto,
  ) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/public/referrals/traveler/install-evidence',
      data: requestDto.toJson(),
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        'Empty response received from install-evidence endpoint',
      );
    }
    return InstallEvidenceResponseDto.fromJson(data);
  }
}

/// Provider for [AttributionRemoteDataSource].
final attributionRemoteDataSourceProvider =
    Provider<AttributionRemoteDataSource>((ref) {
  return AttributionRemoteDataSource(dio: ref.watch(dioProvider));
});

