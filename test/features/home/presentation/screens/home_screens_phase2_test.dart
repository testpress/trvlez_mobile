import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/core/widgets/app_segmented_control.dart';
import 'package:trvlez_mobile/core/widgets/ez_word.dart';
import 'package:trvlez_mobile/core/widgets/findr_card.dart';
import 'package:trvlez_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:trvlez_mobile/features/home/presentation/widgets/home_wordmark_row.dart';
import 'package:trvlez_mobile/features/home/presentation/widgets/main_scaffold.dart';
import 'package:trvlez_mobile/features/home/presentation/widgets/service_grid.dart';
import 'package:trvlez_mobile/features/profile/presentation/providers/profile_providers.dart';
import 'package:trvlez_mobile/features/profile/presentation/screens/account_screen.dart';
import 'package:trvlez_mobile/features/profile/presentation/screens/close_account_screen.dart';
import 'package:trvlez_mobile/features/profile/presentation/screens/preferences_screen.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
import 'package:trvlez_mobile/features/properties/presentation/providers/properties_providers.dart';
import 'package:trvlez_mobile/features/properties/presentation/screens/properties_listing_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/providers/reservations_providers.dart';
import 'package:trvlez_mobile/features/saved/presentation/screens/saved_screen.dart';

class _FakeProfileNotifier extends ProfileNotifier {
  final Profile _profile;
  _FakeProfileNotifier(this._profile);

  @override
  FutureOr<Profile> build() => _profile;
}

class _FakePropertiesNotifier extends PropertiesNotifier {
  final List<Property> _properties;
  _FakePropertiesNotifier(this._properties);

  @override
  FutureOr<List<Property>> build() => _properties;
}

class _FakeReservationListNotifier extends ReservationListNotifier {
  final List<Reservation> _reservations;
  _FakeReservationListNotifier(this._reservations);

  @override
  FutureOr<List<Reservation>> build() => _reservations;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2 Home Hub & Navigation Shell Tests', () {
    testWidgets(
      'HomeScreen renders wordmark, location, service cards, and Findr card',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              travelerVerificationStateProvider.overrideWithValue(
                TravelerVerificationState.verified,
              ),
            ],
            child: const MaterialApp(home: HomeScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Wordmark brand row
        expect(find.byType(HomeWordmarkRow), findsOneWidget);

        // Location row default
        expect(find.text('Edinburgh, UK'), findsOneWidget);

        // 4 Service cards in grid
        expect(find.byType(ServiceCard), findsNWidgets(4));
        expect(find.text('Hotels, resorts, villas'), findsOneWidget);
        expect(find.text('Exchange and spend'), findsOneWidget);
        expect(find.text('Duty free and local'), findsOneWidget);
        expect(find.text('Talk to your host'), findsOneWidget);

        // Findr card
        expect(find.byType(FindrCard), findsOneWidget);
        expect(find.text('Activate Findr'), findsOneWidget);

        // Tap Activate Findr and verify it transitions to active
        await tester.ensureVisible(find.text('Activate Findr'));
        await tester.tap(find.text('Activate Findr'));
        await tester.pumpAndSettle();

        expect(find.text('Recommend a hotel'), findsOneWidget);
      },
    );

    testWidgets(
      'HomeScreen renders Verification in review on FindrCard when verification is processing',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              travelerVerificationStateProvider.overrideWithValue(
                TravelerVerificationState.submitted,
              ),
            ],
            child: const MaterialApp(home: HomeScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(FindrCard), findsOneWidget);
        expect(find.text('Verification in review'), findsOneWidget);
        expect(find.text('Start verification'), findsNothing);
      },
    );

    testWidgets(
      'HomeScreen renders Start verification on FindrCard when traveler is unverified',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              travelerVerificationStateProvider.overrideWithValue(
                TravelerVerificationState.profileComplete,
              ),
            ],
            child: const MaterialApp(home: HomeScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(FindrCard), findsOneWidget);
        expect(find.text('Start verification'), findsOneWidget);
        expect(find.text('Verification in review'), findsNothing);
      },
    );

    testWidgets(
      'MainScaffold renders all 4 tab destinations and handles navigation',
      (tester) async {
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const MainScaffold(
                child: Center(child: Text('Home Content')),
              ),
            ),
            GoRoute(
              path: AppRoutes.myTrips,
              builder: (context, state) => const MainScaffold(
                child: Center(child: Text('Bookings Content')),
              ),
            ),
            GoRoute(
              path: AppRoutes.favorites,
              builder: (context, state) => const MainScaffold(
                child: Center(child: Text('Saved Content')),
              ),
            ),
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const MainScaffold(
                child: Center(child: Text('Account Content')),
              ),
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Bookings'), findsOneWidget);
        expect(find.text('Saved'), findsOneWidget);
        expect(find.text('Account'), findsOneWidget);
        expect(find.text('Home Content'), findsOneWidget);

        // Tap Bookings tab
        await tester.tap(find.text('Bookings'));
        await tester.pumpAndSettle();
        expect(find.text('Bookings Content'), findsOneWidget);

        // Tap Saved tab
        await tester.tap(find.text('Saved'));
        await tester.pumpAndSettle();
        expect(find.text('Saved Content'), findsOneWidget);

        // Tap Account tab
        await tester.tap(find.text('Account'));
        await tester.pumpAndSettle();
        expect(find.text('Account Content'), findsOneWidget);
      },
    );

    testWidgets(
      'AccountScreen renders verified state, settings groups, and sign-out',
      (tester) async {
        const mockProfile = Profile(
          id: 'usr-1',
          nationality: 'NG',
          gender: 'female',
          onboardingStep: 'completed',
          dateOfBirth: null,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              travelerVerificationStateProvider.overrideWithValue(
                TravelerVerificationState.verified,
              ),
              currentProfileProvider.overrideWith(
                () => _FakeProfileNotifier(mockProfile),
              ),
            ],
            child: const MaterialApp(home: AccountScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Heading and profile initials
        expect(find.text('Account'), findsOneWidget);
        expect(find.text('T'), findsOneWidget);

        // Verified account drops the hero card
        expect(find.text('Verify your identity'), findsNothing);

        // Settings categories
        expect(find.text('Personal'), findsOneWidget);
        expect(find.text('Personal details'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Security'), findsOneWidget);
        expect(find.text('Preferences'), findsOneWidget);
        expect(find.text('Sign out'), findsOneWidget);
      },
    );

    testWidgets(
      'AccountScreen renders in-review verification state without start verification button',
      (tester) async {
        const mockProfile = Profile(id: 'usr-1', onboardingStep: 'submitted');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              travelerVerificationStateProvider.overrideWithValue(
                TravelerVerificationState.submitted,
              ),
              currentProfileProvider.overrideWith(
                () => _FakeProfileNotifier(mockProfile),
              ),
            ],
            child: const MaterialApp(home: AccountScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Verification in review'), findsOneWidget);
        expect(
          find.text('Our system is reviewing your documents'),
          findsOneWidget,
        );
        expect(find.text('Start verification'), findsNothing);
      },
    );

    testWidgets(
      'AccountScreen renders needs-attention verification state when failed',
      (tester) async {
        const mockProfile = Profile(id: 'usr-1', onboardingStep: 'submitted');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              travelerVerificationStateProvider.overrideWithValue(
                TravelerVerificationState.failed,
              ),
              currentProfileProvider.overrideWith(
                () => _FakeProfileNotifier(mockProfile),
              ),
            ],
            child: const MaterialApp(home: AccountScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Verification needs attention'), findsOneWidget);
        expect(find.text('Start verification'), findsNothing);
      },
    );

    testWidgets(
      'AccountScreen renders start verification prompt for unverified traveler',
      (tester) async {
        const mockProfile = Profile(
          id: 'usr-1',
          onboardingStep: 'profile_complete',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              travelerVerificationStateProvider.overrideWithValue(
                TravelerVerificationState.profileComplete,
              ),
              currentProfileProvider.overrideWith(
                () => _FakeProfileNotifier(mockProfile),
              ),
            ],
            child: const MaterialApp(home: AccountScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Verify your identity'), findsOneWidget);
        expect(find.text('Start verification'), findsOneWidget);
      },
    );

    testWidgets('SavedScreen renders segmented categories and empty state', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            propertiesNotifierProvider.overrideWith(
              () => _FakePropertiesNotifier(const []),
            ),
          ],
          child: const MaterialApp(home: SavedScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Title & segmented control options
      expect(find.text('Saved'), findsOneWidget);
      expect(find.byType(AppSegmentedControl), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is EzWord && w.rest == 'Stays'),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((w) => w is EzWord && w.rest == 'Shop'),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((w) => w is EzWord && w.rest == 'Chat'),
        findsOneWidget,
      );

      // Empty state
      expect(find.text('Nothing saved yet'), findsOneWidget);

      // Switch to Shop
      await tester.tap(
        find.byWidgetPredicate((w) => w is EzWord && w.rest == 'Shop'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Nothing saved yet'), findsOneWidget);
    });

    testWidgets('CloseAccountScreen renders warnings and confirmation checks', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: CloseAccountScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Close my account'), findsOneWidget);
      expect(find.text('Deactivate'), findsWidgets);
      expect(find.text('Close and delete my data'), findsOneWidget);
    });

    testWidgets(
      'PropertiesListingScreen renders search, chips, and property listings',
      (tester) async {
        const sampleProperty = Property(
          id: 'stay-1',
          name: 'The Balmoral Hotel',
          city: 'Edinburgh',
          stateRegion: 'Scotland',
          countryCode: 'UK',
          propertyType: 'hotel',
          shortDescription: 'Luxury hotel',
          longDescription: 'Historic 5-star hotel in Edinburgh city centre',
          heroImageUrl: '',
          pricePerNight: 280.0,
          rating: 4.9,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              propertiesNotifierProvider.overrideWith(
                () => _FakePropertiesNotifier(const [sampleProperty]),
              ),
            ],
            child: const MaterialApp(home: PropertiesListingScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Top search bar and category chips
        expect(find.text('Search properties or cities'), findsOneWidget);
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Hotels'), findsOneWidget);

        // Property name rendered
        expect(find.text('The Balmoral Hotel'), findsWidgets);
      },
    );

    testWidgets(
      'HomeScreen dynamically renders upcoming reservation, check-in banner, and allows theme toggle',
      (tester) async {
        final mockReservation = Reservation(
          id: 'res-999',
          confirmationCode: 'RES999',
          status: ReservationStatus.confirmed,
          checkInDate: DateTime.now().add(const Duration(days: 3)),
          checkOutDate: DateTime.now().add(const Duration(days: 7)),
          guestName: 'Kiprono Cheruiyot',
          numberOfGuests: 2,
          rooms: const [],
          propertySummary: const ReservationPropertySummary(
            id: 'prop-ritz',
            name: 'The Ritz Edinburgh',
            city: 'Edinburgh',
          ),
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              travelerVerificationStateProvider.overrideWithValue(
                TravelerVerificationState.verified,
              ),
              reservationListProvider.overrideWith(
                () => _FakeReservationListNotifier([mockReservation]),
              ),
            ],
            child: const MaterialApp(home: HomeScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Dynamic guest greeting
        expect(find.textContaining('Kiprono'), findsOneWidget);

        // Dynamic Check-in banner
        expect(find.text('Check in for The Ritz Edinburgh'), findsOneWidget);

        // Dynamic Next stay
        expect(find.text('The Ritz Edinburgh'), findsWidgets);
        expect(find.text('4 nights'), findsOneWidget);

        // Theme toggle icon in top bar
        expect(find.byIcon(AppIcons.bulb), findsOneWidget);
        await tester.tap(find.byIcon(AppIcons.bulb));
        await tester.pumpAndSettle();
      },
    );

    testWidgets('PreferencesScreen toggles theme mode', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: PreferencesScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Theme'), findsOneWidget);
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      expect(find.text('Choose Theme'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
    });
  });
}
