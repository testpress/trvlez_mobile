import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/features/findr/data/datasources/finder_remote_data_source.dart';
import 'package:trvlez_mobile/features/findr/data/models/finder_dto.dart';
import 'package:trvlez_mobile/features/findr/data/models/referral_dto.dart';
import 'package:trvlez_mobile/features/findr/data/repositories/finder_repository_impl.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/hotel_referral_create_params.dart';

class _FakeFinderRemoteDataSource implements FinderRemoteDataSource {
  bool shouldThrow = false;
  int statusCode = 500;
  String errorMessage = 'Error';

  FinderStatusResponseDto finderStatus = FinderStatusResponseDto(
    finder: FinderDto(
      id: 'finder-1',
      userId: 'user-1',
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    eligibility: const FinderEligibilityDto(
      isEligible: true,
      reason: 'eligible',
    ),
    reverificationRequired: false,
  );

  HotelReferralsListResponseDto hotelReferrals = HotelReferralsListResponseDto(
    items: [
      HotelReferralDto(
        id: 'ref-1',
        finderId: 'finder-1',
        status: 'converted',
        hotelName: 'Live Hotel',
        createdAt: DateTime.now(),
      ),
      HotelReferralDto(
        id: 'ref-2',
        finderId: 'finder-1',
        status: 'introduction_sent',
        hotelName: 'Pending Hotel',
        createdAt: DateTime.now(),
      ),
    ],
    count: 2,
  );

  HotelAssociationsResponseDto associatedHotels =
      const HotelAssociationsResponseDto(items: [
    {'id': 'assoc-1'},
  ], count: 1);

  TravelerShareLinkDto travelerShareLink = const TravelerShareLinkDto(
    shareCode: 'TRV-SHARE-99',
    shareUrl: 'https://trvlez.com/r/TRV-SHARE-99',
  );

  @override
  Dio get dio => throw UnimplementedError();

  @override
  Future<FinderStatusResponseDto> getFinderStatus() async {
    _checkThrow();
    return finderStatus;
  }

  @override
  Future<FinderDto> activateFinder(FinderActivationRequestDto requestDto) async {
    _checkThrow();
    return finderStatus.finder!;
  }

  @override
  Future<FinderDto> updateProfile(FinderProfileUpdateDto updateDto) async {
    _checkThrow();
    return finderStatus.finder!;
  }

  @override
  Future<HotelReferralsListResponseDto> listHotelReferrals({
    String? status,
    int skip = 0,
    int limit = 50,
  }) async {
    _checkThrow();
    return hotelReferrals;
  }

  @override
  Future<HotelAssociationsResponseDto> listAssociatedHotels({
    int skip = 0,
    int limit = 50,
  }) async {
    _checkThrow();
    return associatedHotels;
  }

  @override
  Future<TravelerShareLinkDto> getTravelerShareLink() async {
    _checkThrow();
    return travelerShareLink;
  }

  @override
  Future<HotelReferralCreateResponseDto> createHotelReferral(
    HotelReferralCreateRequestDto requestDto,
  ) async {
    _checkThrow();
    return HotelReferralCreateResponseDto(
      referral: HotelReferralDto(
        id: 'new-ref-1',
        finderId: 'finder-1',
        status: 'introduction_sent',
        hotelName: requestDto.hotelName,
        createdAt: DateTime.now(),
      ),
      invitationToken: 'raw-token-123',
      invitationUrl: 'https://trvlez.com/invite',
      optOutUrl: 'https://trvlez.com/opt-out',
    );
  }

  void _checkThrow() {
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: statusCode,
          data: {'detail': errorMessage},
        ),
        type: DioExceptionType.badResponse,
      );
    }
  }
}

void main() {
  group('FinderRepositoryImpl Referral Tests', () {
    late _FakeFinderRemoteDataSource fakeRemoteDataSource;
    late FinderRepositoryImpl repository;

    setUp(() {
      fakeRemoteDataSource = _FakeFinderRemoteDataSource();
      repository = FinderRepositoryImpl(
        remoteDataSource: fakeRemoteDataSource,
      );
    });

    test('getFindrPortfolio returns empty when user is not active Finder', () async {
      fakeRemoteDataSource.finderStatus = const FinderStatusResponseDto(
        finder: null,
        eligibility: FinderEligibilityDto(isEligible: false, reason: 'unverified'),
        reverificationRequired: false,
      );

      final portfolio = await repository.getFindrPortfolio();

      expect(portfolio.joined, isFalse);
      expect(portfolio.joinedCount, 0);
      expect(portfolio.inReviewCount, 0);
      expect(portfolio.earned, '£0.00');
      expect(portfolio.dueAmount, '£0.00');
      expect(portfolio.dueDate, '—');
      expect(portfolio.hotelReferrals, isEmpty);
      expect(portfolio.payouts, isEmpty);
    });

    test('getFindrPortfolio aggregates real backend counts and share link', () async {
      final portfolio = await repository.getFindrPortfolio();

      expect(portfolio.joined, isTrue);
      expect(portfolio.joinedCount, 1);
      expect(portfolio.inReviewCount, 1);
      expect(portfolio.earned, '£0.00'); // Zero hardcoded values!
      expect(portfolio.dueAmount, '£0.00');
      expect(portfolio.dueDate, '—');
      expect(portfolio.shareCode, 'TRV-SHARE-99');
      expect(portfolio.shareUrl, 'https://trvlez.com/r/TRV-SHARE-99');
      expect(portfolio.hotelReferrals.length, 2);
      expect(portfolio.hotelReferrals[0].hotelName, 'Live Hotel');
      expect(portfolio.hotelReferrals[1].hotelName, 'Pending Hotel');
      expect(portfolio.payouts, isEmpty);
    });

    test('createHotelReferral succeeds and returns domain entity', () async {
      const params = HotelReferralCreateParams(
        hotelName: 'New Grand Hotel',
        streetAddress: '12 Beach Rd',
        city: 'Nice',
        postalCode: '06000',
        countryCode: 'FR',
        targetEmail: 'gm@newgrand.fr',
      );

      final item = await repository.createHotelReferral(params);

      expect(item.id, 'new-ref-1');
      expect(item.hotelName, 'New Grand Hotel');
      expect(item.statusLabel, 'Invited');
    });

    test('maps 409 conflict to ValidationException with backend message', () async {
      fakeRemoteDataSource.shouldThrow = true;
      fakeRemoteDataSource.statusCode = 409;
      fakeRemoteDataSource.errorMessage =
          'This hotel is already under an active invitation or 180-day opt-out cooldown.';

      const params = HotelReferralCreateParams(
        hotelName: 'Collided Hotel',
        streetAddress: '12 Beach Rd',
        city: 'Nice',
        postalCode: '06000',
        countryCode: 'FR',
        targetEmail: 'gm@collided.fr',
      );

      expect(
        () => repository.createHotelReferral(params),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('180-day opt-out cooldown'),
          ),
        ),
      );
    });
  });
}
