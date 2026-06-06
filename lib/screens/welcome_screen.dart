import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'main/main_tabs_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final UserModel user;
  final bool returning;
  const WelcomeScreen({super.key, required this.user, required this.returning});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.returning ? 3600 : 3000), () {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainTabsScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: const Color(0xFF124428),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.returning ? 'We knew you would be back.' : 'Welcome, ${widget.user.name}',
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              widget.returning ? 'Your Food Rush table is ready again.' : 'You eat, we deliver to you.',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}