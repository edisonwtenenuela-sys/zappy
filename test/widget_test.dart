// Basic widget test for Zappy.

import 'package:flutter_test/flutter_test.dart';
import 'package:zappy/app.dart';

void main() {
  testWidgets('renders Zappy app shell', (WidgetTester tester) async {
    await tester.pumpWidget(const ZappyApp());
    expect(find.text('Zappy Feed'), findsOneWidget);
  });
}
