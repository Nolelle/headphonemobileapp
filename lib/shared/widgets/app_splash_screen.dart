import 'package:flutter/material.dart';

class AppSplashScreen extends StatefulWidget {
  final bool isDarkMode;

  const AppSplashScreen({
    super.key,
    required this.isDarkMode,
  });

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _showLoading = false;

  @override
  void initState() {
    super.initState();

    // Create a pulsing animation for the logo
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Make the animation repeat in both directions
    _pulseController.repeat(reverse: true);

    // Delay showing the loading indicator
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showLoading = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Theme colors based on mode
    final primaryColor = widget.isDarkMode
        ? const Color.fromRGBO(104, 92, 162, 1.0) // Dark theme color
        : const Color.fromRGBO(133, 86, 169, 1.0); // Light theme color

    final backgroundColor = widget.isDarkMode
        ? const Color.fromRGBO(20, 20, 20, 1)
        : const Color.fromRGBO(245, 245, 245, 1);

    final textColor =
        widget.isDarkMode ? Colors.white : const Color.fromRGBO(50, 50, 50, 1);

    final secondaryTextColor = widget.isDarkMode
        ? const Color.fromRGBO(200, 200, 200, 1)
        : const Color.fromRGBO(100, 100, 100, 1);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated headphone logo
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.headphones_rounded,
                    size: 100,
                    color: primaryColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // App name with animated appearance
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  Text(
                    'Bone+',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Premium Sound Experience',
                    style: TextStyle(
                      fontSize: 16,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // Loading indicator with delayed appearance
            if (_showLoading)
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeIn,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Column(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Loading text
                    Text(
                      'Connecting to your audio device...',
                      style: TextStyle(
                        fontSize: 16,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(
                  height: 64), // Placeholder height when loading is not visible
          ],
        ),
      ),
    );
  }
}
