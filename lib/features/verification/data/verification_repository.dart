import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/network/dio_provider.dart';
import 'package:trvlez_mobile/features/verification/data/datasources/s3_upload_client.dart';
import 'package:trvlez_mobile/features/verification/data/datasources/verification_remote_data_source.dart';
import 'package:trvlez_mobile/features/verification/data/repositories/verification_repository_impl.dart';
import 'package:trvlez_mobile/features/verification/domain/repositories/verification_repository.dart';

/// Provider for [S3UploadClient].
final s3UploadClientProvider = Provider<S3UploadClient>((ref) {
  return const S3UploadClient();
});

/// Provider for [VerificationRemoteDataSource].
final verificationRemoteDataSourceProvider =
    Provider<VerificationRemoteDataSource>((ref) {
      final dio = ref.watch(dioProvider);
      return VerificationRemoteDataSourceImpl(dio: dio);
    });

/// Provider for the [VerificationRepository] contract.
final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  final remoteDataSource = ref.watch(verificationRemoteDataSourceProvider);
  final s3Client = ref.watch(s3UploadClientProvider);
  return VerificationRepositoryImpl(
    remoteDataSource: remoteDataSource,
    s3UploadClient: s3Client,
  );
});
