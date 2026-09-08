import 'package:trvlez_mobile/features/properties/domain/property.dart';

class PropertyDto {
  final String id;
  final String name;
  final String? city;
  final String? stateRegion;
  final String? countryCode;
  final String? propertyType;
  final String? shortDescription;
  final String? longDescription;
  final String? heroImageUrl;
  final double? latitude;
  final double? longitude;
  final String? currencyCode;
  final List<String> amenities;
  final int? totalRooms;
  final String? checkinTime;
  final String? checkoutTime;
  final String? addressLine1;
  final List<Map<String, dynamic>> roomTypes;

  const PropertyDto({
    required this.id,
    required this.name,
    this.city,
    this.stateRegion,
    this.countryCode,
    this.propertyType,
    this.shortDescription,
    this.longDescription,
    this.heroImageUrl,
    this.latitude,
    this.longitude,
    this.currencyCode,
    this.amenities = const [],
    this.totalRooms,
    this.checkinTime,
    this.checkoutTime,
    this.addressLine1,
    this.roomTypes = const [],
  });

  factory PropertyDto.fromJson(Map<String, dynamic> json) {
    // Parse amenities from either listing item ("amenities": ["wifi", ...])
    // or public detail ("facilities": [{"facility_type": "wifi"}, ...])
    List<String> parsedAmenities = [];
    if (json['amenities'] is List) {
      parsedAmenities = (json['amenities'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();
    } else if (json['facilities'] is List) {
      parsedAmenities = (json['facilities'] as List<dynamic>)
          .map((e) {
            if (e is Map<String, dynamic>) {
              return e['facility_type']?.toString() ?? '';
            }
            return e.toString();
          })
          .where((s) => s.isNotEmpty)
          .toList();
    }

    String? heroImageUrl = json['hero_image_url'] as String?;
    if ((heroImageUrl == null || heroImageUrl.isEmpty) && json['images'] is List) {
      final imgList = json['images'] as List;
      for (final img in imgList) {
        if (img is Map<String, dynamic>) {
          if (img['is_primary'] == true && img['image_url'] != null) {
            heroImageUrl = img['image_url'] as String;
            break;
          }
        }
      }
      if ((heroImageUrl == null || heroImageUrl.isEmpty) && imgList.isNotEmpty) {
        final firstImg = imgList.first;
        if (firstImg is String) {
          heroImageUrl = firstImg;
        } else if (firstImg is Map<String, dynamic>) {
          heroImageUrl = firstImg['image_url'] as String?;
        }
      }
    }

    return PropertyDto(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String?,
      stateRegion: json['state_region'] as String?,
      countryCode: json['country_code'] as String?,
      propertyType: json['property_type'] as String?,
      shortDescription: (json['short_description'] ?? json['description']) as String?,
      longDescription: (json['long_description'] ??
              json['description'] ??
              json['short_description']) as String?,
      heroImageUrl: heroImageUrl,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      currencyCode: json['currency_code'] as String?,
      amenities: parsedAmenities,
      totalRooms: json['total_rooms'] as int?,
      checkinTime: json['checkin_time'] as String?,
      checkoutTime: json['checkout_time'] as String?,
      addressLine1:
          (json['address_line_1'] ?? json['address_line1']) as String?,
      roomTypes:
          (json['room_types'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    );
  }

  Property toDomain() {
    return Property(
      id: id,
      name: name,
      city: city ?? '',
      countryCode: countryCode ?? '',
      stateRegion: stateRegion ?? '',
      propertyType: propertyType,
      shortDescription: shortDescription ?? '',
      longDescription: longDescription ?? shortDescription ?? '',
      heroImageUrl: heroImageUrl ?? '',
      amenities: amenities,
      totalRooms: totalRooms,
      checkinTime: checkinTime,
      checkoutTime: checkoutTime,
      addressLine1: addressLine1,
      pricePerNight: null,
      rating: null,
      reviewsCount: null,
      roomTypes: roomTypes
          .map(
            (r) => RoomType(
              id: r['id']?.toString() ?? '',
              name: r['name']?.toString() ?? '',
              maxOccupancy: r['max_occupancy'] as int? ?? 2,
              maxAdults: r['max_adults'] as int? ?? 2,
              maxChildren: r['max_children'] as int? ?? 0,
              description: r['description']?.toString() ?? '',
            ),
          )
          .toList(),
    );
  }
}

class PropertyListingResponseDto {
  final List<PropertyDto> items;
  final int total;
  final int skip;
  final int limit;

  const PropertyListingResponseDto({
    required this.items,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory PropertyListingResponseDto.fromJson(Map<String, dynamic> json) {
    return PropertyListingResponseDto(
      items:
          (json['data'] as List<dynamic>?)
              ?.map((e) => PropertyDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['count'] as int? ?? 0,
      skip: json['skip'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
    );
  }
}
