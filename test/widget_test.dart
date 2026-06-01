import 'package:flutter_test/flutter_test.dart';

import 'package:trvlez_mobile/main.dart';

void main() {
  testWidgets('Registration screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const TrvlEzApp());

    // Verify the registration screen headline is displayed
    expect(find.text('Create your account'), findsOneWidget);

    // Verify form fields are present
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Verify the CTA button
    expect(find.text('Create Account'), findsOneWidget);
  });
}
