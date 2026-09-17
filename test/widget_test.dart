import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/main.dart';

void main() {
  testWidgets('MyBikeApp renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const MyBikeApp());

    // Verify splash screen renders
    expect(find.text('MYBIKE'), findsOneWidget);

    // Settle splash timer & animations
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
