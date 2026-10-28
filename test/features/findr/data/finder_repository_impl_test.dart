import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/features/findr/data/datasources/finder_remote_data_source.dart';
import 'package:trvlez_mobile/features/findr/data/models/finder_dto.dart';
import 'package:trvlez_mobile/features/findr/data/repositories/finder_repository_impl.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/finder_activation_params.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/finder_status.dart';

class MockFinderRemoteDataSource extends Fake
    implements FinderRemoteDataSource {
  bool shouldThrow = false;
  int statusCode = 500;
  FinderActivationRequestDto? lastActivationDto;
  FinderProfileUpdateDto? lastUpdateDto;

  @override
  Future<FinderStatusResponseDto> getFinderStatus() async {
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: '/finders/me'),
        response: Response(
          requestOptions: RequestOptions(path: '/finders/me'),
          statusCode: statusCode,
        ),
        type: DioExceptionType.badResponse,
      );
    }

    return FinderStatusResponseDto(
      finder: FinderDto(
        id: 'finder-test-1',
        userId: 'user-test-1',
        status: 'active',
        addressLine1: '1 Oxford St',
        city: 'London',
        postalCode: 'W1D 1BS',
        residentialCountryCode: 'GB',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
      eligibility: const FinderEligibilityDto(
        isEligible: true,
        reason: 'eligible',
      ),
      reverificationRequired: false,
    );
  }

  @override
  Future<FinderDto> activateFinder(
      FinderActivationRequestDto requestDto) async {
    lastActivationDto = requestDto;
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: '/finders/me/activate'),
        response: Response(
          requestOptions: RequestOptions(path: '/finders/me/activate'),
          statusCode: statusCode,
        ),
        type: DioExceptionType.badResponse,
      );
    }

    return FinderDto(
      id: 'finder-activated-1',
      userId: 'user-test-1',
      status: 'active',
      addressLine1: requestDto.addressLine1,
      city: requestDto.city,
      postalCode: requestDto.postalCode,
      residentialCountryCode: requestDto.residentialCountryCode,
      agreementVersion: requestDto.agreementVersion,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<FinderDto> updateProfile(FinderProfileUpdateDto updateDto) async {
    lastUpdateDto = updateDto;
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: '/finders/me/profile'),
        response: Response(
          requestOptions: RequestOptions(path: '/finders/me/profile'),
          statusCode: statusCode,
        ),
        type: DioExceptionType.badResponse,
      );
    }

    return FinderDto(
      id: 'finder-updated-1',
      userId: 'user-test-1',
      status: 'active',
      addressLine1: updateDto.addressLine1 ?? '1 Oxford St',
      city: updateDto.city ?? 'London',
      postalCode: updateDto.postalCode ?? 'W1D 1BS',
      residentialCountryCode: updateDto.residentialCountryCode ?? 'GB',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

void main() {
  late MockFinderRemoteDataSource mockDataSource;
  late FinderRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockFinderRemoteDataSource();
    repository = FinderRepositoryImpl(remoteDataSource: mockDataSource);
  });


  group('FinderRepositoryImpl Tests', () {
    test('getFinderStatus returns domain model successfully', () async {
      final summary = await repository.getFinderStatus();

      expect(summary.hasActiveFinder, isTrue);
      expect(summary.finder?.id, 'finder-test-1');
      expect(summary.eligibility.isEligible, isTrue);
      expect(summary.eligibility.reason, FinderEligibilityReason.eligible);
      expect(summary.reverificationRequired, isFalse);
    });

    test('getFinderStatus maps 404/500 DioException to AppException', () async {
      mockDataSource.shouldThrow = true;
      mockDataSource.statusCode = 404;

      expect(
        () => repository.getFinderStatus(),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('activateFinder forwards request DTO and returns domain entity',
        () async {
      const params = FinderActivationParams(
        addressLine1: '10 Downing St',
        city: 'London',
        postalCode: 'SW1A 2AA',
        residentialCountryCode: 'GB',
        agreementVersion: 'v1.0',
        agreementAccepted: true,
      );

      final identity = await repository.activateFinder(params);

      expect(identity.id, 'finder-activated-1');
      expect(identity.status, FinderStatusType.active);
      expect(mockDataSource.lastActivationDto?.addressLine1, '10 Downing St');
      expect(mockDataSource.lastActivationDto?.agreementAccepted, isTrue);
    });

    test('updateProfile forwards update parameters', () async {
      const params = FinderProfileUpdateParams(
        city: 'Edinburgh',
        postalCode: 'EH1 1YZ',
      );

      final identity = await repository.updateProfile(params);

      expect(identity.id, 'finder-updated-1');
      expect(mockDataSource.lastUpdateDto?.city, 'Edinburgh');
      expect(mockDataSource.lastUpdateDto?.postalCode, 'EH1 1YZ');
    });

    test('getFinderTerms returns domain terms synchronously', () {
      final terms = repository.getFinderTerms();
      expect(terms.version, 'v1.0');
      expect(terms.sections.isNotEmpty, isTrue);
    });
  });
}

