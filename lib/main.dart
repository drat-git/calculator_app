import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _darkTheme = false;

  void _toggleTheme() {
    setState(() {
      _darkTheme = !_darkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator State Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _darkTheme ? ThemeMode.dark : ThemeMode.light,
      themeAnimationDuration: const Duration(milliseconds: 250),
      home: MyHomePage(
        title: 'Calculator',
        darkTheme: _darkTheme,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.darkTheme,
    required this.onToggleTheme,
  });

  final String title;
  final bool darkTheme;
  final VoidCallback onToggleTheme;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _input = '';
  double? _total;
  String? _operator;
  bool _waitingForInput = true;
  bool _resultShown = false;

  String get _display {
    if (_input.isNotEmpty) return _input;
    final value = _total ?? 0;
    final text = value.toString();
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }

  void _pressButton(String value) {
    if (int.tryParse(value) != null) {
      _enterDigit(value);
    } else if (value == '=') {
      _showResult();
    } else if (value == 'AC') {
      _clear();
    } else {
      _chooseOperator(value);
    }
  }

  void _clear() {
    setState(() {
      _input = '';
      _total = null;
      _operator = null;
      _waitingForInput = true;
      _resultShown = false;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  void _enterDigit(String digit) {
    setState(() {
      if (_resultShown) {
        _total = null;
        _operator = null;
      }
      if (_waitingForInput || _resultShown || _input == '0') {
        _input = digit;
      } else {
        _input += digit;
      }
      _waitingForInput = false;
      _resultShown = false;
    });
  }

  double? _calculate(double left, String operation, double right) {
    if (operation == '÷' && right == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot divide by zero. Press AC to start again.'),
        ),
      );
      return null;
    }
    final double result;
    switch (operation) {
      case '+':
        result = left + right;
      case '−':
        result = left - right;
      case '×':
        result = left * right;
      default:
        result = left / right;
    }
    if (!result.isFinite) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Number is too large. Press AC to reset.'),
        ),
      );
      return null;
    }
    return result;
  }

  void _chooseOperator(String operation) {
    if (_waitingForInput) {
      if (_total != null) {
        setState(() {
          _operator = operation;
          _resultShown = false;
        });
      }
      return;
    }
    final number = double.parse(_input);
    final nextTotal = _operator == null
        ? number
        : _calculate(_total!, _operator!, number);
    if (nextTotal == null || !nextTotal.isFinite) return;
    setState(() {
      // Finish the pending operation before saving the next one.
      _total = nextTotal;
      _operator = operation;
      _input = '';
      _waitingForInput = true;
      _resultShown = false;
    });
  }

  void _showResult() {
    if (_waitingForInput) return;
    final number = double.parse(_input);
    final nextTotal = _operator == null
        ? number
        : _calculate(_total!, _operator!, number);
    if (nextTotal == null || !nextTotal.isFinite) return;
    setState(() {
      _total = nextTotal;
      _operator = null;
      _input = '';
      _waitingForInput = true;
      _resultShown = true;
    });
  }

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
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            key: const Key('themeToggle'),
            tooltip: widget.darkTheme
                ? 'Switch to light theme'
                : 'Switch to dark theme',
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.darkTheme ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
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
