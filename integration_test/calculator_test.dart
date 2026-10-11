import 'package:calculator_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/widget_test.dart' show press, expectDisplay;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Calculator transitions and features on Android', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    final sequences = [
      ['1', '2', '+', '3', '×'],
      ['4', '='],
      ['AC', '2', '+', '3', '×', '4', '='],
      ['AC', '9', '+', '×', '2', '='],
      ['AC', '7', '+', '='],
      ['2', '='],
      ['=', '8'],
      ['−', '1', '1', '='],
      ['AC', '6', '×', '7', '='],
      ['AC', '7', '÷', '2', '='],
      ['AC', '9', '+', 'AC', '2', '×', '3', '='],
    ];
    const results = [
      '15',
      '60',
      '20',
      '18',
      '7',
      '9',
      '8',
      '-3',
      '42',
      '3.5',
      '6',
    ];
    for (var i = 0; i < sequences.length; i++) {
      await press(tester, sequences[i]);
      expectDisplay(tester, results[i]);
    }
    await press(tester, [
      'AC',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '0',
    ]);
    expectDisplay(tester, '1234567890');
    await press(tester, ['AC', '7', '+']);
    await tester.ensureVisible(find.byKey(const Key('themeToggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('themeToggle')));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(MyHomePage))).brightness,
      Brightness.dark,
    );
    expectDisplay(tester, '7');
    await press(tester, ['2', '=']);
    expectDisplay(tester, '9');
    await tester.ensureVisible(find.byKey(const Key('themeToggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('themeToggle')));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(MyHomePage))).brightness,
      Brightness.light,
    );
    await press(tester, ['AC', '8', '÷', '0', '=']);
    expect(
      find.text('Cannot divide by zero. Press AC to start again.'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 5));
    await press(tester, ['AC', '2', '×', '3', '=']);
    expectDisplay(tester, '6');
    expect(tester.takeException(), isNull);
  });
  testWidgets('Android rotation preserves the pending calculation', (
    tester,
  ) async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await press(tester, ['AC', '7', '+']);
    expect(
      tester.view.physicalSize.height,
      greaterThan(tester.view.physicalSize.width),
    );
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(
      tester.view.physicalSize.width,
      greaterThan(tester.view.physicalSize.height),
    );
    expectDisplay(tester, '7');
    await press(tester, ['2', '=']);
    expectDisplay(tester, '9');
    expect(tester.takeException(), isNull);
    await SystemChrome.setPreferredOrientations([]);
  });
}
