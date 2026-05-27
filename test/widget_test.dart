import 'package:flutter_test/flutter_test.dart';
import 'package:zappy/app.dart';

void main() {
  testWidgets('renders login when user is logged out', (WidgetTester tester) async {
    await tester.pumpWidget(const ZappyApp());
    await tester.pump();
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
