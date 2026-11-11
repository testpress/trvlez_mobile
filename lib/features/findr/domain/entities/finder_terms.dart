/// Domain entity representing a single section within the Findr Terms and Conditions.
class FinderTermsSection {
  final String title;
  final String content;

  const FinderTermsSection({required this.title, required this.content});
}

/// Domain entity representing versioned Findr Participation Terms & Conditions.
class FinderTerms {
  final String version;
  final String title;
  final String effectiveDate;
  final String summary;
  final List<FinderTermsSection> sections;

  const FinderTerms({
    required this.version,
    required this.title,
    required this.effectiveDate,
    required this.summary,
    required this.sections,
  });

  /// Standard fallback terms used when offline or degrading gracefully.
  static const FinderTerms defaultTerms = FinderTerms(
    version: '1.0',
    title: 'Findr Programme Agreement & Participation Terms',
    effectiveDate: '2026-01-01',
    summary:
        'This Agreement governs your participation in the TRVLez Findr Programme. '
        'By activating your Findr status, you agree to recommend authentic hospitality '
        'properties and earn platform commissions in accordance with these terms.',
    sections: [
      FinderTermsSection(
        title: '1. Eligibility & Market Availability',
        content:
            'The Findr Programme is currently available exclusively to verified travelers '
            'holding a valid United Kingdom (GBR) passport and residing at a verified UK address. '
            'Participants must be at least 18 years of age and maintain an active, fully verified '
            'TRVLez account with valid biometric verification.',
      ),
      FinderTermsSection(
        title: '2. Property Recommendations & Standards',
        content:
            'As a Findr, you may recommend independent and boutique hotels you have personal experience with. '
            'All recommendations undergo human review by TRVLez before property outreach. '
            'Misleading, fraudulent, or commercial self-referrals are strictly prohibited.',
      ),
      FinderTermsSection(
        title: '3. Commission & Reward Structure',
        content:
            'Findrs earn 5% of TRVLez platform commission on completed and realized guest stays at approved '
            'properties for a period of 12 months from the date of the property\'s first qualified booking. '
            'Payouts are processed to your nominated UK bank account following guest checkout.',
      ),
      FinderTermsSection(
        title: '4. Ongoing Verification & Address Requirements',
        content:
            'You must maintain a valid passport on file. If your passport expires, your Findr status '
            'will be paused until biometric re-verification is completed. Failure to re-verify within '
            'scheduled reminder periods may result in deactivation.',
      ),
      FinderTermsSection(
        title: '5. Compliance & Termination',
        content:
            'TRVLez reserves the right to suspend or terminate Findr accounts for violation of community standards, '
            'fraudulent activity, or program abuse. You may cancel your Findr membership at any time.',
      ),
    ],
  );
}
