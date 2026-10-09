import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/features/profile/presentation/profile_setup_screen.dart';
import 'package:trvlez_mobile/features/profile/presentation/providers/profile_providers.dart';
import 'package:trvlez_mobile/features/profile/presentation/widgets/nationality_picker_field.dart';
import 'package:trvlez_mobile/features/profile/presentation/widgets/personal_details_form.dart';
import 'package:trvlez_mobile/features/profile/presentation/widgets/profile_avatar_uploader.dart';

class MockProfileRepository extends Fake implements ProfileRepository {
  bool shouldThrow = false;
  Profile profileToReturn = const Profile(
    id: 'prof-setup-1',
    phone: '+15559876543',
    nationality: 'Canada',
    gender: 'female',
    onboardingStep: 'welcome',
  );

  String? lastUpdatedPhone;
  String? lastUpdatedNationality;

  @override
  Future<Profile> getProfile() async {
    return profileToReturn;
  }

  @override
  Future<Profile> updateProfile({
    String? phone,
    String? nationality,
    String? gender,
    DateTime? dateOfBirth,
    String? passportNumber,
    DateTime? passportExpiry,
  }) async {
    lastUpdatedPhone = phone;
    lastUpdatedNationality = nationality;

    if (shouldThrow) {
      throw const ValidationException('Failed to update profile');
    }

    profileToReturn = profileToReturn.copyWith(
      phone: phone,
      nationality: nationality,
      gender: gender,
      dateOfBirth: dateOfBirth,
      passportNumber: passportNumber,
      passportExpiry: passportExpiry,
    );
    return profileToReturn;
  }
}

void main() {
  group('ProfileSetupScreen Widget Tests', () {
    late MockProfileRepository mockRepo;

    setUp(() {
      mockRepo = MockProfileRepository();
    });

    testWidgets(
      'renders avatar uploader, personal details form, and submit button',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [profileRepositoryProvider.overrideWithValue(mockRepo)],
            child: const MaterialApp(home: ProfileSetupScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Profile Setup'), findsOneWidget);
        expect(find.byType(ProfileAvatarUploader), findsOneWidget);
        expect(find.byType(PersonalDetailsForm), findsOneWidget);
        expect(find.byType(NationalityPickerField), findsOneWidget);
        expect(find.text('Complete Profile'), findsOneWidget);
        expect(find.byType(AppButton), findsOneWidget);
      },
    );

    testWidgets('pre-populates form fields from loaded profile state', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [profileRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: ProfileSetupScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('+15559876543'), findsOneWidget);
      expect(find.text('Canada'), findsOneWidget);
    });

    testWidgets('validates required phone number on empty submission', (
      tester,
    ) async {
      mockRepo.profileToReturn = const Profile(
        id: 'prof-setup-empty',
        onboardingStep: 'welcome',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [profileRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: ProfileSetupScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Complete Profile'));
      await tester.tap(find.text('Complete Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Phone Number is required'), findsOneWidget);
    });

    testWidgets('submits modified profile to repository', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [profileRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: ProfileSetupScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final phoneFinder = find.widgetWithText(TextFormField, '+15559876543');
      await tester.enterText(phoneFinder, '+15550001111');
      await tester.ensureVisible(find.text('Complete Profile'));
      await tester.tap(find.text('Complete Profile'));
      await tester.pumpAndSettle();

      expect(mockRepo.lastUpdatedPhone, '+15550001111');
    });

    testWidgets('shows error banner when repository update throws', (
      tester,
    ) async {
      mockRepo.shouldThrow = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [profileRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: ProfileSetupScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Complete Profile'));
      await tester.tap(find.text('Complete Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Failed to update profile'), findsOneWidget);
    });
  });
}
