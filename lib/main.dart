import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator State Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const MyHomePage(title: 'Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String _display = '0';

  void _pressButton(String value) {}

  String _buttonLabel(String value) {
    switch (value) {
      case '+':
        return 'Add';
      case '−':
        return 'Subtract';
      case '×':
        return 'Multiply';
      case '÷':
        return 'Divide';
      case '=':
        return 'Equals';
      case 'AC':
        return 'All clear';
      default:
        return value;
    }
  }

  Widget _buildButton(String value) {
    final colors = Theme.of(context).colorScheme;
    final isOperator = ['+', '−', '×', '÷', '='].contains(value);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Semantics(
          label: _buttonLabel(value),
          child: ElevatedButton(
            key: ValueKey('button$value'),
            onPressed: () => _pressButton(value),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(48, 72),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              backgroundColor: isOperator
                  ? colors.primaryContainer
                  : colors.surfaceContainerHigh,
              foregroundColor: isOperator
                  ? colors.onPrimaryContainer
                  : colors.onSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(fontSize: 26),
            ),
            child: ExcludeSemantics(child: Text(value)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final rows = [
      ['7', '8', '9', '÷'],
      ['4', '5', '6', '×'],
      ['1', '2', '3', '−'],
      ['0', 'AC', '=', '+'],
    ];

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Left-to-right calculation',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 80,
                          width: double.infinity,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              _display,
                              key: const Key('calculatorDisplay'),
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w500,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final row in rows)
                    Row(
                      children: [for (final value in row) _buildButton(value)],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
