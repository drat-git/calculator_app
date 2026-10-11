import 'package:calculator_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> press(WidgetTester tester, List<String> buttons) async {
  for (final button in buttons) {
    final target = find.byKey(ValueKey('button$button'));
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
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
  final calculations = <String, List<String>>{
    '12': ['1', '2'],
    '20': ['8', '+', '1', '2', '='],
    '-3': ['8', '−', '1', '1', '='],
    '42': ['6', '×', '7', '='],
    '3.5': ['7', '÷', '2', '='],
    '1.5': ['2', '+', '4', '−', '3', '×', '2', '÷', '4', '='],
  };
  for (final calculation in calculations.entries) {
    testWidgets('Calculate ${calculation.value.join(' ')}', (tester) async {
      await tester.pumpWidget(const MyApp());
      await press(tester, calculation.value);
      expectDisplay(tester, calculation.key);
    });
  }

  testWidgets('Each step of the assignment trace is visible', (tester) async {
    await tester.pumpWidget(const MyApp());
    const keys = ['1', '2', '+', '3', '×', '4', '='];
    const values = ['1', '12', '12', '3', '15', '4', '60'];
    for (var i = 0; i < keys.length; i++) {
      await press(tester, [keys[i]]);
      expectDisplay(tester, values[i]);
    }
  });

  testWidgets('Equals without an operand preserves the pending operator', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, ['7', '+', '=']);
    expectDisplay(tester, '7');
    await press(tester, ['2', '=']);
    expectDisplay(tester, '9');
  });

  testWidgets(
    'An operator continues a result and leading zeros stay readable',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await press(tester, ['0', '0', '3', '=']);
      expectDisplay(tester, '3');
      await press(tester, ['+', '4', '=']);
      expectDisplay(tester, '7');
      await press(tester, ['AC', '+', '=', '5']);
      expectDisplay(tester, '5');
    },
  );

  testWidgets('Division by zero recovers through AC', (tester) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, ['8', '÷', '0', '=']);
    expect(
      find.text('Cannot divide by zero. Press AC to start again.'),
      findsOneWidget,
    );
    await press(tester, ['AC', '2', '×', '3', '=']);
    expectDisplay(tester, '6');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Keypad fits a narrow phone with large text', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    for (final button in tester.widgetList<ElevatedButton>(
      find.byType(ElevatedButton),
    )) {
      final size = tester.getSize(find.byKey(button.key!));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    }
    await tester.ensureVisible(find.byKey(const ValueKey('button=')));
    await press(tester, ['2', '+', '3', '=']);
    expectDisplay(tester, '5');
  });

  testWidgets('Landscape preserves state and lets the keypad scroll', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    await press(tester, ['7', '+']);
    tester.view.physicalSize = const Size(800, 400);
    await tester.pumpAndSettle();
    expectDisplay(tester, '7');
    await tester.ensureVisible(find.byKey(const ValueKey('button=')));
    await press(tester, ['2', '=']);
    expectDisplay(tester, '9');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Controls have accessible labels and consistent press feedback', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const MyApp());
    expect(find.bySemanticsLabel('Multiply'), findsOneWidget);
    expect(find.bySemanticsLabel('All clear'), findsOneWidget);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    for (final button in tester.widgetList<ElevatedButton>(
      find.byType(ElevatedButton),
    )) {
      expect(button.style!.splashFactory, InkRipple.splashFactory);
      expect(
        button.style!.animationDuration,
        const Duration(milliseconds: 150),
      );
    }
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('button8'))),
    );
    await tester.pump(const Duration(milliseconds: 80));
    expect(tester.takeException(), isNull);
    await gesture.up();
    await tester.pumpAndSettle();
    expectDisplay(tester, '8');
    semantics.dispose();
  });
  testWidgets('Theme toggle preserves a pending calculation', (tester) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, ['7', '+']);
    final page = find.byType(MyHomePage);
    expect(find.text('Dark mode'), findsOneWidget);
    expect(
      tester.widget<SwitchListTile>(find.byKey(const Key('themeToggle'))).value,
      isFalse,
    );
    expect(Theme.of(tester.element(page)).brightness, Brightness.light);
    await tester.tap(find.byKey(const Key('themeToggle')));
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(page)).brightness, Brightness.dark);
    expect(
      tester.widget<SwitchListTile>(find.byKey(const Key('themeToggle'))).value,
      isTrue,
    );
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
      ['9', '+', '2'],
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
