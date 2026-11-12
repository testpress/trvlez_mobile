import 'package:dio/dio.dart';
import 'package:trvlez_mobile/core/network/dio_error_mapper.dart';
import 'package:trvlez_mobile/features/findr/data/datasources/finder_remote_data_source.dart';
import 'package:trvlez_mobile/features/findr/data/models/finder_dto.dart';
import 'package:trvlez_mobile/features/findr/data/models/referral_dto.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/finder_activation_params.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/finder_status.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/finder_terms.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/findr_portfolio.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/hotel_referral_create_params.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/hotel_referral_item.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/traveler_share_link.dart';
import 'package:trvlez_mobile/features/findr/domain/repositories/finder_repository.dart';

/// Concrete repository implementation that coordinates Finder data and maps exceptions.
class FinderRepositoryImpl implements FinderRepository {
  const FinderRepositoryImpl({required this.remoteDataSource});

  final FinderRemoteDataSource remoteDataSource;

  @override
  Future<FinderStateSummary> getFinderStatus() async {
    try {
      final responseDto = await remoteDataSource.getFinderStatus();
      return responseDto.toDomain();
    } on DioException catch (dioException) {
      throw mapDioException(dioException);
    }
  }

  @override
  FinderTerms getFinderTerms() {
    return FinderTerms.defaultTerms;
  }

  @override
  Future<FinderIdentity> activateFinder(FinderActivationParams params) async {
    try {
      final requestDto = FinderActivationRequestDto.fromDomain(params);
      final responseDto = await remoteDataSource.activateFinder(requestDto);
      return responseDto.toDomain();
    } on DioException catch (dioException) {
      throw mapDioException(dioException);
    }
  }

  @override
  Future<FinderIdentity> updateProfile(FinderProfileUpdateParams params) async {
    try {
      final requestDto = FinderProfileUpdateDto.fromDomain(params);
      final responseDto = await remoteDataSource.updateProfile(requestDto);
      return responseDto.toDomain();
    } on DioException catch (dioException) {
      throw mapDioException(dioException);
    }
  }

  @override
  Future<List<HotelReferralItem>> listHotelReferrals({
    String? status,
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      final responseDto = await remoteDataSource.listHotelReferrals(
        status: status,
        skip: skip,
        limit: limit,
      );
      return responseDto.items.map((dto) => dto.toDomain()).toList();
    } on DioException catch (dioException) {
      throw mapDioException(dioException);
    }
  }

  @override
  Future<int> countAssociatedHotels() async {
    try {
      final responseDto = await remoteDataSource.listAssociatedHotels(
        skip: 0,
        limit: 1,
      );
      return responseDto.count;
    } on DioException catch (dioException) {
      throw mapDioException(dioException);
    }
  }

  @override
  Future<TravelerShareLink> getTravelerShareLink() async {
    try {
      final responseDto = await remoteDataSource.getTravelerShareLink();
      return responseDto.toDomain();
    } on DioException catch (dioException) {
      throw mapDioException(dioException);
    }
  }

  @override
  Future<HotelReferralItem> createHotelReferral(
    HotelReferralCreateParams params,
  ) async {
    try {
      final requestDto = HotelReferralCreateRequestDto.fromDomain(params);
      final responseDto = await remoteDataSource.createHotelReferral(
        requestDto,
      );
      return responseDto.referral.toDomain();
    } on DioException catch (dioException) {
      throw mapDioException(dioException);
    }
  }

  @override
  Future<FindrPortfolio> getFindrPortfolio() async {
    try {
      final summary = await getFinderStatus();
      final isFinderActive = summary.finder?.isActive ?? false;

      if (!isFinderActive) {
        return FindrPortfolio.empty.copyWith(joined: false);
      }

      // Fetch live referrals, associations count, and permanent traveler link in parallel
      final results = await Future.wait([
        listHotelReferrals(limit: 50),
        countAssociatedHotels(),
        getTravelerShareLink(),
      ]);

      final referrals = results[0] as List<HotelReferralItem>;
      final associatedCount = results[1] as int;
      final shareLink = results[2] as TravelerShareLink;

      final joinedCount = associatedCount > 0
          ? associatedCount
          : referrals.where((referral) => referral.isLive).length;

      final inReviewCount = referrals
          .where((referral) => referral.isPending || referral.isOutreach)
          .length;

      final recommendations = referrals
          .map(
            (referral) => FindrRecommendation(
              name: referral.hotelName,
              when: referral.formattedWhen,
              status: referral.statusLabel,
              state: referral.state,
            ),
          )
          .toList();

      return FindrPortfolio(
        joined: true,
        earned: '£0.00',
        joinedCount: joinedCount,
        inReviewCount: inReviewCount,
        dueAmount: '£0.00',
        dueDate: '—',
        recommendations: recommendations,
        hotelReferrals: referrals,
        payouts: const [],
        shareCode: shareLink.shareCode,
        shareUrl: shareLink.shareUrl,
      );
    } on DioException catch (dioException) {
      throw mapDioException(dioException);
    }
  }
}
