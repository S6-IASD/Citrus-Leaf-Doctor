import 'package:flutter_test/flutter_test.dart';
import 'package:citrus_leaf_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CitrusLeafApp());
    expect(find.byType(CitrusLeafApp), findsOneWidget);
  });
}
