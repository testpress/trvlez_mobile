import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/auth/data/models/login_response_dto.dart';
import 'package:trvlez_mobile/features/auth/data/models/traveler_signup_dto.dart';

void main() {
  group('Auth DTO Tests', () {
    test('LoginResponseDto deserializes and serializes JSON payload', () {
      final json = {
        'access_token': 'jwt_access_token_123',
        'token_type': 'bearer',
      };

      final dto = LoginResponseDto.fromJson(json);
      expect(dto.accessToken, 'jwt_access_token_123');
      expect(dto.tokenType, 'bearer');

      final serialized = dto.toJson();
      expect(serialized['access_token'], 'jwt_access_token_123');
      expect(serialized['token_type'], 'bearer');
    });

    test('TravelerSignupResponseDto deserializes nested JSON payload', () {
      final json = {
        'id': 'user-uuid-1',
        'email': 'traveler@trvlez.com',
        'full_name': 'Morgan Freeman',
        'traveler_profile': {
          'id': 'profile-uuid-1',
          'onboarding_step': 'profile_pending',
          'nationality': 'USA',
          'phone': '+15551234567',
        },
      };

      final dto = TravelerSignupResponseDto.fromJson(json);
      expect(dto.id, 'user-uuid-1');
      expect(dto.email, 'traveler@trvlez.com');
      expect(dto.fullName, 'Morgan Freeman');
      expect(dto.travelerProfile.id, 'profile-uuid-1');
      expect(dto.travelerProfile.onboardingStep, 'profile_pending');
      expect(dto.travelerProfile.nationality, 'USA');
      expect(dto.travelerProfile.phone, '+15551234567');

      final serialized = dto.toJson();
      expect(serialized['id'], 'user-uuid-1');
      expect(serialized['email'], 'traveler@trvlez.com');
      expect(serialized['full_name'], 'Morgan Freeman');
      expect(
        (serialized['traveler_profile'] as Map<String, dynamic>)['id'],
        'profile-uuid-1',
      );
    });

    test('TravelerSignupResponseDto handles nullable fields', () {
      final json = {
        'id': 'user-uuid-2',
        'email': 'minimal@trvlez.com',
        'traveler_profile': {
          'id': 'profile-uuid-2',
          'onboarding_step': 'welcome',
        },
      };

      final dto = TravelerSignupResponseDto.fromJson(json);
      expect(dto.id, 'user-uuid-2');
      expect(dto.fullName, isNull);
      expect(dto.travelerProfile.nationality, isNull);
      expect(dto.travelerProfile.phone, isNull);
    });
  });
}
