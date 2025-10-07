import 'package:flutter/material.dart';

class CustomListTile extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color titleColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Function()? onTap;

  const CustomListTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.titleColor,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  State<CustomListTile> createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        widget.icon,
        color: widget.iconColor,
        size: 20,
      ),
      title: Text(
        widget.title,
        style: TextStyle(
          color: widget.titleColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(widget.subtitle),
      trailing: widget.trailing,
      onTap: widget.onTap,
    );
  }
}
