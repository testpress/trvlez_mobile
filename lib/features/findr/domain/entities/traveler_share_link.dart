import 'package:meta/meta.dart';

/// Finder's permanent traveler referral share code and landing link.
@immutable
class TravelerShareLink {
  const TravelerShareLink({
    required this.shareCode,
    required this.shareUrl,
  });

  final String shareCode;
  final String shareUrl;
}
