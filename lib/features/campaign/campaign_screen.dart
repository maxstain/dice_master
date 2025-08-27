import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManagementScreen extends StatefulWidget {
  final UserCredential user;

  const ManagementScreen({super.key, required this.user});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen>
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
        title: Text(widget.user.user!.displayName!),
      ),
    );
  }
}
