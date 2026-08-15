import 'package:flutter_test/flutter_test.dart';
import 'package:rolla/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('muestra la pantalla inicial de Rolla', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());

    expect(find.text('ROLLA'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}
