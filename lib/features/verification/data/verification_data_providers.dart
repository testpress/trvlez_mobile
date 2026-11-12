import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/network/dio_provider.dart';
import 'package:trvlez_mobile/features/verification/data/datasources/s3_upload_data_source.dart';
import 'package:trvlez_mobile/features/verification/data/datasources/verification_remote_data_source.dart';

/// Provider for [S3UploadDataSource].
final s3UploadDataSourceProvider = Provider<S3UploadDataSource>((ref) {
  return const S3UploadDataSource();
});

/// Backward compatibility alias for [s3UploadDataSourceProvider].
final s3UploadClientProvider = s3UploadDataSourceProvider;

/// Provider for [VerificationRemoteDataSource].
final verificationRemoteDataSourceProvider =
    Provider<VerificationRemoteDataSource>((ref) {
      final dio = ref.watch(dioProvider);
      return VerificationRemoteDataSourceImpl(dio: dio);
    });
