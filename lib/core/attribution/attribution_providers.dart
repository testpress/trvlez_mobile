import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/attribution/attribution_remote_data_source.dart';
import 'package:trvlez_mobile/core/attribution/attribution_service.dart';
import 'package:trvlez_mobile/core/attribution/install_referrer_client.dart';
import 'package:trvlez_mobile/core/storage/attribution_storage.dart';

export 'package:trvlez_mobile/core/attribution/attribution_dto.dart';
export 'package:trvlez_mobile/core/attribution/attribution_remote_data_source.dart';
export 'package:trvlez_mobile/core/attribution/attribution_service.dart';
export 'package:trvlez_mobile/core/attribution/install_referrer_client.dart';
export 'package:trvlez_mobile/core/storage/attribution_storage.dart';

/// Provider for [InstallReferrerClient].
final installReferrerClientProvider = Provider<InstallReferrerClient>((ref) {
  return const InstallReferrerClient();
});

/// Provider for [AttributionService].
final attributionServiceProvider = Provider<AttributionService>((ref) {
  return AttributionService(
    installReferrerClient: ref.watch(installReferrerClientProvider),
    attributionStorage: ref.watch(attributionStorageProvider),
    remoteDataSource: ref.watch(attributionRemoteDataSourceProvider),
  );
});
