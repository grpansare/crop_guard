import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_page.dart';
import 'farmer_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _controller.forward();

    // Do the token check
    _checkAuth();
  }

  void _initAnimations() {
    // Main animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Fade in animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Scale animation for the logo
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // Pulse animation for the loader
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 2500)); // splash delay
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            token != null ? const FarmerDashboard() : const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(75),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.agriculture,
                        size: 80,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // App title
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      'Crop Disease App',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Loader
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        children: [
                          Center(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withOpacity(0.8),
                                ),
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Loading text
                  FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _controller,
                        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
                      ),
                    ),
                    child: Text(
                      'Loading...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
