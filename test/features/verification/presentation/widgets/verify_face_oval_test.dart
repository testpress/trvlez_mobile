import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verify_face_oval.dart';

void main() {
  group('VerifyFaceOval Geometry & Rendering', () {
    testWidgets('renders default ergonomic face oval dimensions and halo', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: VerifyFaceOval())),
      );
      await tester.pumpAndSettle();

      final faceOvalFinder = find.byType(VerifyFaceOval);
      expect(faceOvalFinder, findsOneWidget);

      final widget = tester.widget<VerifyFaceOval>(faceOvalFinder);
      expect(widget.width, equals(224.0));
      expect(widget.height, equals(296.0));
      expect(widget.showGuidanceGuides, isTrue);

      // Verify ClipOval is present for face viewing
      expect(find.byType(ClipOval), findsOneWidget);

      // Verify custom painters for guidance and oval ring are present
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders custom dimensions and progress arc when recording', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerifyFaceOval(
              width: 220.0,
              height: 290.0,
              progress: 0.5,
              showGuidanceGuides: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final faceOvalFinder = find.byType(VerifyFaceOval);
      final widget = tester.widget<VerifyFaceOval>(faceOvalFinder);
      expect(widget.width, equals(220.0));
      expect(widget.height, equals(290.0));
      expect(widget.progress, equals(0.5));
    });

    testWidgets('renders custom previewChild inside the face oval', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerifyFaceOval(
              previewChild: ColoredBox(
                color: Colors.green,
                child: Text('Camera Feed'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Camera Feed'), findsOneWidget);
    });
  });
}
