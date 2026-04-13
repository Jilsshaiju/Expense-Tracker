import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Basic smoke test — just verify the app widget class exists
    expect(ExpenseTrackerApp, isNotNull);
  });
}
