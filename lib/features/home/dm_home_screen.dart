import 'package:flutter/material.dart';

class DungeonMasterHomeScreen extends StatefulWidget {
  const DungeonMasterHomeScreen({super.key});

  @override
  State<DungeonMasterHomeScreen> createState() =>
      _DungeonMasterHomeScreenState();
}

class _DungeonMasterHomeScreenState extends State<DungeonMasterHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
