import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';

class PinInput extends StatefulWidget {
  final Function(String) onPinEntered;
  final String title;
  final String? errorMessage;
  final bool isConfirming;
  final String? initialPin;

  const PinInput({
    super.key,
    required this.onPinEntered,
    required this.title,
    this.errorMessage,
    this.isConfirming = false,
    this.initialPin,
  });

  @override
  State<PinInput> createState() => _PinInputState();
}

class _PinInputState extends State<PinInput> {
  String _pin = '';
  final int _pinLength = 4;
  final List<String> _numbers = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '0'
  ];

  void _onNumberPressed(String number) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += number;
      });
      if (_pin.length == _pinLength) {
        widget.onPinEntered(_pin);
      }
    }
  }

  void _onBackspacePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialPin != null) {
      _pin = widget.initialPin!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: tPrimaryColor,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _pinLength,
            (index) => Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: tPrimaryColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  index < _pin.length ? '●' : '',
                  style: const TextStyle(
                    fontSize: 24,
                    color: tPrimaryColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (widget.errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(
            widget.errorMessage!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 14,
            ),
          ),
        ],
        const SizedBox(height: 30),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _numbers.length + 1,
          itemBuilder: (context, index) {
            if (index == _numbers.length) {
              return _buildBackspaceButton();
            }
            return _buildNumberButton(_numbers[index]);
          },
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onNumberPressed(number),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: tPrimaryColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: tPrimaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onBackspacePressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: tPrimaryColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(
              Icons.backspace,
              color: tPrimaryColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
