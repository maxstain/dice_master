import 'package:flutter/material.dart';

class HomeDungeonMasterScreen extends StatefulWidget {
  final String dmName;

  const HomeDungeonMasterScreen({super.key, required this.dmName});

  @override
  State<HomeDungeonMasterScreen> createState() =>
      _HomeDungeonMasterScreenState();
}

class _HomeDungeonMasterScreenState extends State<HomeDungeonMasterScreen>
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dungeon Master Screen'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [Text("Hello, ${widget.dmName}")],
        ),
      ),
    );
  }
}
