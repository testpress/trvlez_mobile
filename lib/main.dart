import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/app/app.dart';
import 'package:trvlez_mobile/core/network/dio_provider.dart';
import 'package:trvlez_mobile/core/storage/settings_repository.dart';
import 'package:trvlez_mobile/core/storage/token_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tokenStorage = TokenStorage();
  final initialToken = await tokenStorage.getToken();
  final initializedTokenStorage = TokenStorage(initialToken: initialToken);
  final settingsRepository = await SettingsRepository.init();

  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepository),
        tokenStorageProvider.overrideWithValue(initializedTokenStorage),
      ],
      child: const TrvlEzApp(),
    ),
  );
}
