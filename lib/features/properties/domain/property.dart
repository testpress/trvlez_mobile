class Property {
  final String id;
  final String name;
  final String city;
  final String countryCode;
  final String shortDescription;
  final String longDescription;
  final String heroImageUrl;

  // Hardcoded for now as per Figma if backend doesn't provide them yet
  final double pricePerNight;
  final double rating;
  final int reviewsCount;
  final List<RoomType> roomTypes;

  const Property({
    required this.id,
    required this.name,
    required this.city,
    required this.countryCode,
    required this.shortDescription,
    required this.longDescription,
    required this.heroImageUrl,
    required this.pricePerNight,
    required this.rating,
    required this.reviewsCount,
    required this.roomTypes,
  });

  String get locationString {
    if (city.isNotEmpty && countryCode.isNotEmpty) {
      return '$city, $countryCode';
    } else if (city.isNotEmpty) {
      return city;
    } else if (countryCode.isNotEmpty) {
      return countryCode;
    }
    return '';
  }
}

class RoomType {
  final String id;
  final String name;
  final int maxOccupancy;
  final int maxAdults;
  final int maxChildren;
  final String description;

  const RoomType({
    required this.id,
    required this.name,
    required this.maxOccupancy,
    required this.maxAdults,
    required this.maxChildren,
    required this.description,
  });
}
