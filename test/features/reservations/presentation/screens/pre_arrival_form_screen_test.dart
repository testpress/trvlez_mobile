import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';
import 'package:trvlez_mobile/features/reservations/presentation/providers/reservations_providers.dart';
import 'package:trvlez_mobile/features/reservations/presentation/screens/pre_arrival_form_screen.dart';

class _FakeFormRepository extends Fake implements FormRepository {
  bool shouldThrow = false;
  int getCallCount = 0;

  @override
  Future<ReservationFormResponse> getReservationForm(
    String reservationId,
  ) async {
    getCallCount++;
    if (shouldThrow) {
      throw const NetworkException('Failed to load form');
    }
    return const ReservationFormResponse(
      template: FormTemplate(
        id: 't-1',
        title: 'Arrival Details',
        formDefinition: FormDefinition(version: 1, sections: []),
      ),
      submission: null,
      preFillData: {},
    );
  }
}

void main() {
  group('PreArrivalFormScreen State Surfaces', () {
    testWidgets('renders LoadingView during initial load', (tester) async {
      final fakeRepo = _FakeFormRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [formRepositoryProvider.overrideWithValue(fakeRepo)],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PreArrivalFormScreen(reservationId: 'res-123'),
          ),
        ),
      );

      expect(find.byType(LoadingView), findsOneWidget);
      expect(find.text('Loading pre-arrival form...'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('renders ErrorView and handles retry on failure', (
      tester,
    ) async {
      final fakeRepo = _FakeFormRepository()..shouldThrow = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [formRepositoryProvider.overrideWithValue(fakeRepo)],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PreArrivalFormScreen(reservationId: 'res-123'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('Unable to load form'), findsOneWidget);
      expect(find.text('Failed to load form'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      fakeRepo.shouldThrow = false;
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsNothing);
      expect(fakeRepo.getCallCount, greaterThan(1));
    });
  });
}
