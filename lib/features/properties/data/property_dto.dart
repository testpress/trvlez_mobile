import 'package:trvlez_mobile/features/properties/domain/property.dart';

class PropertyDto {
  final String id;
  final String name;
  final String? city;
  final String? countryCode;
  final String? shortDescription;
  final String? longDescription;
  final String? heroImageUrl;
  final double? latitude;
  final double? longitude;
  final String? currencyCode;
  final List<Map<String, dynamic>> roomTypes;

  const PropertyDto({
    required this.id,
    required this.name,
    this.city,
    this.countryCode,
    this.shortDescription,
    this.longDescription,
    this.heroImageUrl,
    this.latitude,
    this.longitude,
    this.currencyCode,
    required this.roomTypes,
  });

  factory PropertyDto.fromJson(Map<String, dynamic> json) {
    return PropertyDto(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String?,
      countryCode: json['country_code'] as String?,
      shortDescription: json['short_description'] as String?,
      longDescription: json['long_description'] as String?,
      heroImageUrl: json['hero_image_url'] as String?,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      currencyCode: json['currency_code'] as String?,
      roomTypes:
          (json['room_types'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }

  Property toDomain() {
    return Property(
      id: id,
      name: name,
      city: city ?? '',
      countryCode: countryCode ?? '',
      shortDescription: shortDescription ?? '',
      longDescription: longDescription ?? '',
      heroImageUrl: heroImageUrl ?? '',
      pricePerNight: 199.0, // Hardcoded placeholder for now as per Figma
      rating: 4.5, // Hardcoded placeholder for now as per Figma
      reviewsCount: 355, // Hardcoded placeholder
      roomTypes: roomTypes
          .map(
            (r) => RoomType(
              id: r['id'] as String? ?? '',
              name: r['name'] as String? ?? '',
              maxOccupancy: r['max_occupancy'] as int? ?? 2,
              maxAdults: r['max_adults'] as int? ?? 2,
              maxChildren: r['max_children'] as int? ?? 0,
              description: r['description'] as String? ?? '',
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
