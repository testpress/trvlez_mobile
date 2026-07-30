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
