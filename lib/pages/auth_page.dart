import 'package:dice_master/pages/homepage.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    late bool isLoginScreen = true; // This can be toggled based on your logic

    if (isLoginScreen) {
      return Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Login Screen'),
              ElevatedButton(
                onPressed: () {
                  // Handle login logic
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('Register')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Register Screen'),
              ElevatedButton(
                onPressed: () {
                  // Handle registration logic
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isAuthenticated = false;
    // Here you can implement your authentication logic
    // For now, we will just return the home page
    return !isAuthenticated
        ? const AuthPage()
        : const MyHomePage(title: "Dice Master");
  }
}
