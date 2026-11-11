import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/network/dio_provider.dart';
import 'package:trvlez_mobile/features/findr/data/models/finder_dto.dart';
import 'package:trvlez_mobile/features/findr/data/models/referral_dto.dart';

/// Remote data source responsible for HTTP requests to the Finder and Referral API endpoints.
class FinderRemoteDataSource {
  const FinderRemoteDataSource({required this.dio});

  final Dio dio;

  /// Fetches the caller's live Finder status, identity, and eligibility.
  Future<FinderStatusResponseDto> getFinderStatus() async {
    final response = await dio.get<Map<String, dynamic>>('/finders/me');
    final data = response.data;
    if (data == null) {
      throw const ServerException(
        'Empty response received from getFinderStatus',
      );
    }
    return FinderStatusResponseDto.fromJson(data);
  }

  /// Activates the caller's Finder account idempotently.
  Future<FinderDto> activateFinder(
    FinderActivationRequestDto requestDto,
  ) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/finders/me/activate',
      data: requestDto.toJson(),
    );
    final data = response.data;
    if (data == null) {
      throw const ServerException(
        'Empty response received from activateFinder',
      );
    }
    return FinderDto.fromJson(data);
  }

  /// Updates allowed Finder profile fields (residential address, email).
  Future<FinderDto> updateProfile(FinderProfileUpdateDto updateDto) async {
    final response = await dio.patch<Map<String, dynamic>>(
      '/finders/me/profile',
      data: updateDto.toJson(),
    );
    final data = response.data;
    if (data == null) {
      throw const ServerException('Empty response received from updateProfile');
    }
    return FinderDto.fromJson(data);
  }

  /// Fetches paginated hotel referrals initiated by the authenticated Finder.
  Future<HotelReferralsListResponseDto> listHotelReferrals({
    String? status,
    int skip = 0,
    int limit = 50,
  }) async {
    final queryParams = <String, dynamic>{'skip': skip, 'limit': limit};
    if (status != null) {
      queryParams['status'] = status;
    }
    final response = await dio.get<Map<String, dynamic>>(
      '/referrals/hotel',
      queryParameters: queryParams,
    );
    final data = response.data;
    if (data == null) {
      throw const ServerException(
        'Empty response received from listHotelReferrals',
      );
    }
    return HotelReferralsListResponseDto.fromJson(data);
  }

  /// Fetches permanently associated converted hotels for the authenticated Finder.
  Future<HotelAssociationsResponseDto> listAssociatedHotels({
    int skip = 0,
    int limit = 50,
  }) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/referrals/hotels/associated',
      queryParameters: {'skip': skip, 'limit': limit},
    );
    final data = response.data;
    if (data == null) {
      throw const ServerException(
        'Empty response received from listAssociatedHotels',
      );
    }
    return HotelAssociationsResponseDto.fromJson(data);
  }

  /// Fetches or initializes the Finder's permanent traveler share code and link.
  Future<TravelerShareLinkDto> getTravelerShareLink() async {
    final response = await dio.get<Map<String, dynamic>>(
      '/referrals/traveler/share-link',
    );
    final data = response.data;
    if (data == null) {
      throw const ServerException(
        'Empty response received from getTravelerShareLink',
      );
    }
    return TravelerShareLinkDto.fromJson(data);
  }

  /// Submits an outreach invitation to a prospective hotel partner.
  Future<HotelReferralCreateResponseDto> createHotelReferral(
    HotelReferralCreateRequestDto requestDto,
  ) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/referrals/hotel',
      data: requestDto.toJson(),
    );
    final data = response.data;
    if (data == null) {
      throw const ServerException(
        'Empty response received from createHotelReferral',
      );
    }
    return HotelReferralCreateResponseDto.fromJson(data);
  }
}

/// Provider for [FinderRemoteDataSource].
final finderRemoteDataSourceProvider = Provider<FinderRemoteDataSource>((ref) {
  return FinderRemoteDataSource(dio: ref.watch(dioProvider));
});
