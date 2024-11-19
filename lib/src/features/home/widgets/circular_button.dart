import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {
  final IconData iconData;
  final String label;
  final VoidCallback onPressed;

  const CircularButton({
    super.key,
    required this.iconData,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 239, 73, 52),
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20.0),
          ),
          child: Icon(iconData, color: Colors.white),
        ),
        const SizedBox(height: 10.0),
        Text(label),
      ],
    );
  }
}
