import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_10_nim/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(AplikasiPuskesmasBandung());
    expect(find.byType(AplikasiPuskesmasBandung), findsOneWidget);
  });
}
