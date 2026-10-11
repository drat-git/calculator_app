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
