import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design_system/colors.dart';

/// PIN entry widget for Bright Minds authentication
class PinEntryWidget extends StatefulWidget {
  final int pinLength;
  final Function(String) onPinComplete;
  final VoidCallback? onClear;
  final bool obscureText;

  const PinEntryWidget({
    super.key,
    this.pinLength = 4,
    required this.onPinComplete,
    this.onClear,
    this.obscureText = true,
  });

  @override
  State<PinEntryWidget> createState() => _PinEntryWidgetState();
}

class _PinEntryWidgetState extends State<PinEntryWidget> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  String _pin = '';

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.pinLength; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty) {
      // Move to next field
      if (index < widget.pinLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last digit, unfocus
        _focusNodes[index].unfocus();
      }

      // Update PIN
      _pin = _controllers.map((c) => c.text).join();

      // Check if PIN is complete
      if (_pin.length == widget.pinLength) {
        widget.onPinComplete(_pin);
      }
    }
  }

  void _clearPin() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _pin = '';
    _focusNodes[0].requestFocus();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.pinLength,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: 60,
                height: 60,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  obscureText: widget.obscureText,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: SafePlayColors.brightIndigo,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: SafePlayColors.brightIndigo,
                        width: 3,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) => _onDigitEntered(index, value),
                  onTap: () {
                    // Clear field on tap
                    _controllers[index].clear();
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (_pin.isNotEmpty)
          TextButton.icon(
            onPressed: _clearPin,
            icon: const Icon(Icons.backspace),
            label: const Text('Clear'),
            style: TextButton.styleFrom(
              foregroundColor: SafePlayColors.brightIndigo,
            ),
          ),
      ],
    );
  }
}

/// PIN strength indicator
class PinStrengthIndicator extends StatelessWidget {
  final String pin;

  const PinStrengthIndicator({
    super.key,
    required this.pin,
  });

  PinStrength _calculateStrength() {
    if (pin.length < 4) return PinStrength.weak;

    // Check for simple patterns
    if (_hasRepeatingDigits()) return PinStrength.weak;
    if (_hasSequentialDigits()) return PinStrength.weak;

    // Check for diversity
    final uniqueDigits = pin.split('').toSet().length;
    if (uniqueDigits >= 4) return PinStrength.strong;
    if (uniqueDigits >= 3) return PinStrength.medium;

    return PinStrength.weak;
  }

  bool _hasRepeatingDigits() {
    return pin == pin[0] * pin.length;
  }

  bool _hasSequentialDigits() {
    for (int i = 0; i < pin.length - 1; i++) {
      final current = int.tryParse(pin[i]) ?? 0;
      final next = int.tryParse(pin[i + 1]) ?? 0;
      if ((next - current).abs() != 1) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (pin.length < 4) return const SizedBox.shrink();

    final strength = _calculateStrength();
    final color = strength.color;
    final label = strength.label;

    return Column(
      children: [
        LinearProgressIndicator(
          value: strength.value,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        Text(
          'PIN Strength: $label',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

enum PinStrength {
  weak(0.33, 'Weak', Colors.red),
  medium(0.66, 'Medium', Colors.orange),
  strong(1.0, 'Strong', Colors.green);

  const PinStrength(this.value, this.label, this.color);
  final double value;
  final String label;
  final Color color;
}
