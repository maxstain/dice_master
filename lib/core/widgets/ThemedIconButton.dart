import 'package:flutter/material.dart';

class ThemedIconButton extends StatefulWidget {
  final Icon icon;
  final String text;
  final ButtonStyle style;
  final VoidCallback? onPressed;

  const ThemedIconButton({
    super.key,
    required this.icon,
    required this.text,
    required this.style,
    this.onPressed,
  });

  @override
  State<ThemedIconButton> createState() => _ThemedIconButtonState();
}

class _ThemedIconButtonState extends State<ThemedIconButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: widget.style,
      child: Row(
        children: [
          widget.icon,
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
