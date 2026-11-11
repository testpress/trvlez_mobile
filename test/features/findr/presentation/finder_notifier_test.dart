import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/findr/presentation/providers/findr_providers.dart';

class FakeFinderRepository implements FinderRepository {
  bool shouldFail = false;
  FinderStateSummary currentSummary = const FinderStateSummary(
    finder: null,
    eligibility: FinderEligibility(
      isEligible: true,
      reason: FinderEligibilityReason.eligible,
    ),
    reverificationRequired: false,
  );

  @override
  Future<FinderStateSummary> getFinderStatus() async {
    if (shouldFail) {
      throw Exception('Network connection failed');
    }
    return currentSummary;
  }

  @override
  FinderTerms getFinderTerms() {
    return FinderTerms.defaultTerms;
  }

  @override
  Future<FinderIdentity> activateFinder(FinderActivationParams params) async {
    if (shouldFail) {
      throw Exception('Activation rejected');
    }

    final activated = FinderIdentity(
      id: 'f-new-1',
      userId: 'u-1',
      status: FinderStatusType.active,
      address: FinderAddress(
        addressLine1: params.addressLine1,
        city: params.city,
        postalCode: params.postalCode,
        residentialCountryCode: params.residentialCountryCode,
      ),
      agreementVersion: params.agreementVersion,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    currentSummary = FinderStateSummary(
      finder: activated,
      eligibility: const FinderEligibility(
        isEligible: true,
        reason: FinderEligibilityReason.eligible,
      ),
      reverificationRequired: false,
    );

    return activated;
  }

  @override
  Future<FinderIdentity> updateProfile(FinderProfileUpdateParams params) async {
    if (shouldFail) {
      throw Exception('Profile update rejected');
    }

    final updated = FinderIdentity(
      id: 'f-new-1',
      userId: 'u-1',
      status: FinderStatusType.active,
      address: FinderAddress(
        addressLine1: params.addressLine1 ?? '1 Main St',
        city: params.city ?? 'London',
        postalCode: params.postalCode ?? 'SW1A 1AA',
        residentialCountryCode: params.residentialCountryCode ?? 'GB',
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    currentSummary = FinderStateSummary(
      finder: updated,
      eligibility: const FinderEligibility(
        isEligible: true,
        reason: FinderEligibilityReason.eligible,
      ),
      reverificationRequired: false,
    );

    return updated;
  }

  @override
  Future<List<HotelReferralItem>> listHotelReferrals({
    String? status,
    int skip = 0,
    int limit = 50,
  }) async => const [];

  @override
  Future<int> countAssociatedHotels() async => 0;

  @override
  Future<TravelerShareLink> getTravelerShareLink() async =>
      const TravelerShareLink(
        shareCode: 'TRV-TEST-1',
        shareUrl: 'https://trvlez.com/r/TRV-TEST-1',
      );

  @override
  Future<HotelReferralItem> createHotelReferral(
    HotelReferralCreateParams params,
  ) async {
    return HotelReferralItem(
      id: 'ref-1',
      finderId: 'f-1',
      hotelName: params.hotelName,
      status: 'introduction_sent',
      statusLabel: 'Invited',
      state: FindrRecommendationState.awaiting,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<FindrPortfolio> getFindrPortfolio() async => FindrPortfolio.empty;
}

void main() {
  late FakeFinderRepository fakeRepository;
  late ProviderContainer container;

  setUp(() {
    fakeRepository = FakeFinderRepository();
    container = ProviderContainer(
      overrides: [finderRepositoryProvider.overrideWithValue(fakeRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('FinderNotifier Tests', () {
    test('initial state loads status from repository', () async {
      final initialAsync = container.read(finderNotifierProvider);
      expect(initialAsync, isA<AsyncLoading>());

      final data = await container.read(finderNotifierProvider.future);
      expect(data.eligibility.isEligible, isTrue);
      expect(data.finder, isNull);
    });

    test('activate submits params and transitions state to active', () async {
      await container.read(finderNotifierProvider.future);

      const params = FinderActivationParams(
        addressLine1: '10 Downing St',
        city: 'London',
        postalCode: 'SW1A 2AA',
        residentialCountryCode: 'GB',
        agreementVersion: '1.0',
        agreementAccepted: true,
      );

      final success = await container
          .read(finderNotifierProvider.notifier)
          .activate(params);

      expect(success, isTrue);

      final updatedState = container.read(finderNotifierProvider).value;
      expect(updatedState?.hasActiveFinder, isTrue);
      expect(updatedState?.finder?.address?.city, 'London');
    });

    test(
      'activate handles errors gracefully and keeps state in error',
      () async {
        await container.read(finderNotifierProvider.future);
        fakeRepository.shouldFail = true;

        const params = FinderActivationParams(
          addressLine1: '10 Downing St',
          city: 'London',
          postalCode: 'SW1A 2AA',
          residentialCountryCode: 'GB',
          agreementVersion: '1.0',
          agreementAccepted: true,
        );

        final success = await container
            .read(finderNotifierProvider.notifier)
            .activate(params);

        expect(success, isFalse);
        expect(container.read(finderNotifierProvider).hasError, isTrue);
      },
    );

    test('refresh refetches status from repository', () async {
      await container.read(finderNotifierProvider.future);

      fakeRepository.currentSummary = const FinderStateSummary(
        finder: null,
        eligibility: FinderEligibility(
          isEligible: false,
          reason: FinderEligibilityReason.verificationIncomplete,
        ),
        reverificationRequired: false,
      );

      await container.read(finderNotifierProvider.notifier).refresh();

      final updatedState = container.read(finderNotifierProvider).value;
      expect(updatedState?.eligibility.isEligible, isFalse);
      expect(
        updatedState?.eligibility.reason,
        FinderEligibilityReason.verificationIncomplete,
      );
    });
  });
}
