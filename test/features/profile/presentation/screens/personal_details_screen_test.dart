import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/features/profile/presentation/providers/profile_providers.dart';
import 'package:trvlez_mobile/features/profile/presentation/screens/personal_details_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import '../../../../fixtures/fake_verification_repository.dart';

class MockProfileRepository extends Fake implements ProfileRepository {
  Profile profileToReturn = const Profile(
    id: 'test-user-1',
    displayName: 'Amara',
    email: 'amara@example.com',
    legalName: 'Amara Chidinma Okafor',
    dateOfBirth: null,
    nationality: 'Nigeria',
    passportNumber: 'A12345678',
    onboardingStep: 'verified',
  );

  @override
  Future<Profile> getProfile() async => profileToReturn;

  @override
  Future<Profile> updateUserDetails({
    String? displayName,
    String? email,
  }) async {
    profileToReturn = profileToReturn.copyWith(
      displayName: displayName ?? profileToReturn.displayName,
      email: email ?? profileToReturn.email,
    );
    return profileToReturn;
  }
}

void main() {
  group('PersonalDetailsScreen Widget Tests', () {
    late MockProfileRepository mockRepo;
    late FakeVerificationRepository fakeVerificationRepo;

    setUp(() {
      mockRepo = MockProfileRepository();
      fakeVerificationRepo = FakeVerificationRepository();
    });

    Widget createTestWidget({required bool isVerified}) {
      return ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(mockRepo),
          verificationRepositoryProvider.overrideWithValue(
            fakeVerificationRepo,
          ),
          travelerVerificationStateProvider.overrideWithValue(
            isVerified
                ? TravelerVerificationState.verified
                : TravelerVerificationState.profilePending,
          ),
          currentProfileProvider.overrideWith(
            () => _TestProfileNotifier(mockRepo.profileToReturn),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const PersonalDetailsScreen(),
        ),
      );
    }

    testWidgets('Verified account displays legal name ONLY and re-verify CTA', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(isVerified: true));
      await tester.pumpAndSettle();

      // Top title and details
      expect(find.text('Personal details'), findsOneWidget);
      expect(find.text('Display name'), findsOneWidget);
      expect(find.text('Amara'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('amara@example.com'), findsOneWidget);

      // Identity section verified elements
      expect(find.text('FROM YOUR PASSPORT'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('Legal name'), findsOneWidget);
      expect(find.text('Amara Chidinma Okafor'), findsOneWidget);
      expect(find.text('Changed your legal name?'), findsOneWidget);
      expect(find.text('Re-verify'), findsOneWidget);

      // Privacy note
      expect(
        find.textContaining(
          'Your date of birth was checked once to confirm you\'re 18+',
        ),
        findsOneWidget,
      );

      // NON-NEGOTIABLE: Date of birth, nationality, passport number must NEVER be displayed
      expect(find.text('Date of birth'), findsNothing);
      expect(find.text('Nationality'), findsNothing);
      expect(find.text('Passport number'), findsNothing);
      expect(find.text('Nigeria'), findsNothing);
      expect(find.text('A12345678'), findsNothing);
    });

    testWidgets(
      'Unverified account displays locked legal name and verify button',
      (tester) async {
        await tester.pumpWidget(createTestWidget(isVerified: false));
        await tester.pumpAndSettle();

        // Your details
        expect(find.text('Display name'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);

        // Locked identity row
        expect(find.text('Add with your passport'), findsOneWidget);
        expect(
          find.textContaining(
            'Your legal name comes straight from your passport chip',
          ),
          findsOneWidget,
        );
        expect(find.text('Verify with your passport'), findsOneWidget);

        // Re-verify CTA should NOT be present when unverified
        expect(find.text('Re-verify'), findsNothing);

        // NON-NEGOTIABLE: No date of birth, nationality, or document number
        expect(find.text('Date of birth'), findsNothing);
        expect(find.text('Nigeria'), findsNothing);
        expect(find.text('A12345678'), findsNothing);
      },
    );

    testWidgets(
      'Tapping Re-verify on verified account shows confirmation dialog',
      (tester) async {
        await tester.pumpWidget(createTestWidget(isVerified: true));
        await tester.pumpAndSettle();

        final reverifyBtn = find.text('Re-verify');
        expect(reverifyBtn, findsOneWidget);
        await tester.tap(reverifyBtn);
        await tester.pumpAndSettle();

        expect(find.text('Re-verify your identity?'), findsOneWidget);
        expect(find.text('Start re-scan'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping Start re-scan in confirmation dialog calls startReverification',
      (tester) async {
        await tester.pumpWidget(createTestWidget(isVerified: true));
        await tester.pumpAndSettle();

        final reverifyBtn = find.text('Re-verify');
        await tester.tap(reverifyBtn);
        await tester.pumpAndSettle();

        expect(find.text('Start re-scan'), findsOneWidget);
        await tester.tap(find.text('Start re-scan'));
        await tester.pumpAndSettle();

        expect(fakeVerificationRepo.startReverificationCalled, isTrue);
      },
    );
  });
}

class _TestProfileNotifier extends ProfileNotifier {
  _TestProfileNotifier(this.initial);
  final Profile initial;

  @override
  Future<Profile> build() async => initial;
}
