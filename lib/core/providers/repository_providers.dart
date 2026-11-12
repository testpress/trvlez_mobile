import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/network/dio_provider.dart';
import 'package:trvlez_mobile/core/storage/attribution_storage.dart';
import 'package:trvlez_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:trvlez_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:trvlez_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:trvlez_mobile/features/findr/data/datasources/finder_remote_data_source.dart';
import 'package:trvlez_mobile/features/findr/data/repositories/finder_repository_impl.dart';
import 'package:trvlez_mobile/features/findr/domain/repositories/finder_repository.dart';
import 'package:trvlez_mobile/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:trvlez_mobile/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:trvlez_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:trvlez_mobile/features/properties/data/datasources/properties_remote_data_source.dart';
import 'package:trvlez_mobile/features/properties/data/repositories/properties_repository_impl.dart';
import 'package:trvlez_mobile/features/properties/domain/repositories/properties_repository.dart';
import 'package:trvlez_mobile/features/reservations/data/datasources/form_remote_data_source.dart';
import 'package:trvlez_mobile/features/reservations/data/datasources/reservation_remote_data_source.dart';
import 'package:trvlez_mobile/features/reservations/data/repositories/form_repository_impl.dart';
import 'package:trvlez_mobile/features/reservations/data/repositories/reservation_repository_impl.dart';
import 'package:trvlez_mobile/features/reservations/domain/repositories/form_repository.dart';
import 'package:trvlez_mobile/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:trvlez_mobile/features/verification/data/repositories/verification_repository_impl.dart';
import 'package:trvlez_mobile/features/verification/data/services/nfc_passport_service_impl.dart';
import 'package:trvlez_mobile/features/verification/data/verification_data_providers.dart';
import 'package:trvlez_mobile/features/verification/domain/repositories/verification_repository.dart';
import 'package:trvlez_mobile/features/verification/domain/services/nfc_passport_service.dart';

/// Central dependency composition boundary for domain repository contracts.
///
/// This boundary wires concrete data implementations to domain interfaces.
/// Presentation providers and UI screens depend solely on domain interfaces
/// and these providers, never importing the data layer directly.

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
    attributionStorage: ref.watch(attributionStorageProvider),
  );
});

final propertiesRepositoryProvider = Provider<PropertiesRepository>((ref) {
  return PropertiesRepositoryImpl(
    remoteDataSource: ref.watch(propertiesRemoteDataSourceProvider),
  );
});

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  return ReservationRepositoryImpl(
    remoteDataSource: ref.watch(reservationRemoteDataSourceProvider),
  );
});

final formRepositoryProvider = Provider<FormRepository>((ref) {
  return FormRepositoryImpl(
    remoteDataSource: ref.watch(formRemoteDataSourceProvider),
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ref.watch(profileRemoteDataSourceProvider),
  );
});

final finderRepositoryProvider = Provider<FinderRepository>((ref) {
  return FinderRepositoryImpl(
    remoteDataSource: ref.watch(finderRemoteDataSourceProvider),
  );
});

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  return VerificationRepositoryImpl(
    remoteDataSource: ref.watch(verificationRemoteDataSourceProvider),
    s3UploadClient: ref.watch(s3UploadClientProvider),
  );
});

final nfcPassportServiceProvider = Provider<NfcPassportService>((ref) {
  return NfcPassportServiceImpl();
});
