class Property {
  final String id;
  final String name;
  final String city;
  final String countryCode;
  final String stateRegion;
  final String? propertyType;
  final String shortDescription;
  final String longDescription;
  final String heroImageUrl;
  final List<String> amenities;
  final int? totalRooms;
  final String? checkinTime;
  final String? checkoutTime;
  final String? addressLine1;
  final double? pricePerNight;
  final String? currencyCode;
  final double? rating;
  final int? reviewsCount;
  final List<RoomType> roomTypes;

  const Property({
    required this.id,
    required this.name,
    required this.city,
    required this.countryCode,
    this.stateRegion = '',
    this.propertyType,
    required this.shortDescription,
    required this.longDescription,
    required this.heroImageUrl,
    this.amenities = const [],
    this.totalRooms,
    this.checkinTime,
    this.checkoutTime,
    this.addressLine1,
    this.pricePerNight,
    this.currencyCode,
    this.rating,
    this.reviewsCount,
    this.roomTypes = const [],
  });

  String get locationString {
    final parts = <String>[];
    if (city.isNotEmpty) parts.add(city);
    if (stateRegion.isNotEmpty && stateRegion != city) parts.add(stateRegion);
    if (countryCode.isNotEmpty) parts.add(countryCode);
    return parts.join(', ');
  }

  Property copyWith({
    String? id,
    String? name,
    String? city,
    String? countryCode,
    String? stateRegion,
    String? propertyType,
    String? shortDescription,
    String? longDescription,
    String? heroImageUrl,
    List<String>? amenities,
    int? totalRooms,
    String? checkinTime,
    String? checkoutTime,
    String? addressLine1,
    double? pricePerNight,
    String? currencyCode,
    double? rating,
    int? reviewsCount,
    List<RoomType>? roomTypes,
  }) {
    return Property(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      countryCode: countryCode ?? this.countryCode,
      stateRegion: stateRegion ?? this.stateRegion,
      propertyType: propertyType ?? this.propertyType,
      shortDescription: shortDescription ?? this.shortDescription,
      longDescription: longDescription ?? this.longDescription,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
      amenities: amenities ?? this.amenities,
      totalRooms: totalRooms ?? this.totalRooms,
      checkinTime: checkinTime ?? this.checkinTime,
      checkoutTime: checkoutTime ?? this.checkoutTime,
      addressLine1: addressLine1 ?? this.addressLine1,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      currencyCode: currencyCode ?? this.currencyCode,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      roomTypes: roomTypes ?? this.roomTypes,
    );
  }
}

class RoomType {
  final String id;
  final String name;
  final int maxOccupancy;
  final int maxAdults;
  final int maxChildren;
  final String description;
  final double? pricePerNight;
  final String? currencyCode;
  final bool isActive;

  const RoomType({
    required this.id,
    required this.name,
    required this.maxOccupancy,
    required this.maxAdults,
    required this.maxChildren,
    required this.description,
    this.pricePerNight,
    this.currencyCode,
    this.isActive = true,
  });

  /// Whether this room type has a valid positive nightly rate configured.
  bool get hasValidPrice => pricePerNight != null && pricePerNight! > 0;
}
