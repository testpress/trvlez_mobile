import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/verification/data/models/verification_challenge_dto.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/verification_challenge.dart';

void main() {
  group('VerificationChallenge and DTO', () {
    test('parses VerificationChallengeDto from JSON with primary keys', () {
      final json = {
        'challenge_id': 'chal-123',
        'challenge_type': 'turn_head',
        'instructions': 'Turn your head slowly to the left',
        'timeout_seconds': 30,
        'metadata': {'angle': 45},
      };

      final dto = VerificationChallengeDto.fromJson(json);
      expect(dto.challengeId, 'chal-123');
      expect(dto.challengeType, 'turn_head');
      expect(dto.instructions, 'Turn your head slowly to the left');
      expect(dto.timeoutSeconds, 30);
      expect(dto.metadata['angle'], 45);

      final domain = dto.toDomain();
      expect(domain, isA<VerificationChallenge>());
      expect(domain.challengeId, 'chal-123');
      expect(domain.challengeType, 'turn_head');
      expect(domain.instructions, 'Turn your head slowly to the left');
      expect(domain.timeoutSeconds, 30);
    });

    test('parses fallback keys for challenge_id and type', () {
      final json = {
        'id': 'fallback-id',
        'type': 'blink',
      };

      final dto = VerificationChallengeDto.fromJson(json);
      expect(dto.challengeId, 'fallback-id');
      expect(dto.challengeType, 'blink');
    });

    test('supports value equality', () {
      const c1 = VerificationChallenge(
        challengeId: 'c1',
        challengeType: 'smile',
        instructions: 'Smile for the camera',
        timeoutSeconds: 15,
      );

      const c2 = VerificationChallenge(
        challengeId: 'c1',
        challengeType: 'smile',
        instructions: 'Smile for the camera',
        timeoutSeconds: 15,
      );

      expect(c1, equals(c2));
      expect(c1.hashCode, equals(c2.hashCode));
    });
  });
}
