import 'dart:async';
import 'package:cineview/presentation/screen/onboarding_page.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OnboardingScreen()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFBCC1DA),
      body: Center(
        child: Padding(padding: const EdgeInsets.all(20.0),
          child: Image.asset('assets/images/Logo_CineView.png',
            width: 250,
            fit: BoxFit.contain,
          ),
        ),
      )
    );
  }
}