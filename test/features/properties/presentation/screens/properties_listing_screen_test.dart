import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
import 'package:trvlez_mobile/features/properties/presentation/providers/properties_providers.dart';
import 'package:trvlez_mobile/features/properties/presentation/screens/properties_listing_screen.dart';

class _FakePropertiesRepository extends Fake implements PropertiesRepository {
  List<Property> propertiesToReturn = [];
  bool shouldThrow = false;
  int getPropertiesCallCount = 0;

  @override
  Future<List<Property>> getProperties({
    int skip = 0,
    int limit = 50,
    String? search,
    String? city,
    String? propertyType,
  }) async {
    getPropertiesCallCount++;
    if (shouldThrow) {
      throw const NetworkException('Unable to reach server');
    }
    return propertiesToReturn;
  }
}

void main() {
  group('PropertiesListingScreen State Surfaces', () {
    testWidgets('renders LoadingView while properties are loading', (
      tester,
    ) async {
      final fakeRepo = _FakePropertiesRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [propertiesRepositoryProvider.overrideWithValue(fakeRepo)],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PropertiesListingScreen(),
          ),
        ),
      );

      expect(find.byType(LoadingView), findsOneWidget);
      expect(find.text('Loading properties...'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('renders ErrorView and retries fetch when repository fails', (
      tester,
    ) async {
      final fakeRepo = _FakePropertiesRepository()..shouldThrow = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [propertiesRepositoryProvider.overrideWithValue(fakeRepo)],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PropertiesListingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('Unable to load properties'), findsOneWidget);
      expect(find.text('Unable to reach server'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      // Now set shouldThrow = false and tap retry
      fakeRepo.shouldThrow = false;
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsNothing);
      expect(fakeRepo.getPropertiesCallCount, greaterThan(1));
    });
  });
}
