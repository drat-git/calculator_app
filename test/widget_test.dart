import 'package:calculator_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> press(WidgetTester tester, List<String> buttons) async {
  for (final button in buttons) {
    await tester.tap(find.byKey(ValueKey('button$button')));
    await tester.pumpAndSettle();
  }
}

void expectDisplay(WidgetTester tester, String value) {
  final display = tester.widget<Text>(
    find.byKey(const Key('calculatorDisplay')),
  );
  expect(display.data, value);
}

void main() {
  testWidgets('Theme toggle preserves a pending calculation', (tester) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, ['7', '+']);
    final page = find.byType(MyHomePage);
    expect(Theme.of(tester.element(page)).brightness, Brightness.light);
    await tester.tap(find.byKey(const Key('themeToggle')));
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(page)).brightness, Brightness.dark);
    expectDisplay(tester, '7');
    await press(tester, ['2', '=']);
    expectDisplay(tester, '9');
    await tester.tap(find.byKey(const Key('themeToggle')));
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(page)).brightness, Brightness.light);
    expectDisplay(tester, '9');
  });
  testWidgets('AC clears digits, pending operations and results', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    for (final sequence in [
      ['1', '2'],
      ['9', '+'],
      ['2', '×', '3', '='],
    ]) {
      await press(tester, sequence);
      await press(tester, ['AC']);
      expectDisplay(tester, '0');
      await press(tester, ['2', '×', '3', '=']);
      expectDisplay(tester, '6');
      await press(tester, ['AC']);
    }
  });
  testWidgets('Operations use a running total from left to right', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, ['2', '+', '3', '×']);
    expectDisplay(tester, '5');
    await press(tester, ['4', '=']);
    expectDisplay(tester, '20');
  });

  testWidgets('Operators replace and equals waits for an operand', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, ['9', '+', '×', '=', '2', '=']);
    expectDisplay(tester, '18');
  });

  testWidgets('Repeated equals is ignored and a digit starts fresh', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, ['2', '+', '3', '=', '=']);
    expectDisplay(tester, '5');
    await press(tester, ['8']);
    expectDisplay(tester, '8');
    await press(tester, ['÷', '2', '=']);
    expectDisplay(tester, '4');
  });
}
