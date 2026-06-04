import 'package:flutter_test/flutter_test.dart';
import 'package:tugas_p5/main.dart';

void main() {
  testWidgets('Smoke test: HomePage title check', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: This might fail in CI because of sqflite initialization, 
    // but as a basic check it's better than the counter test.
    await tester.pumpWidget(const MyApp());

    // Verify that the title is present.
    expect(find.text('Catatan Mahasiswa'), findsOneWidget);
  });
}
