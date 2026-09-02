import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/routes.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _startAnimation = false;

  @override
  void initState() {
    super.initState();
    // Start the animation slightly after the screen loads for a better effect
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _startAnimation = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image (Mountain)
          Image.asset('assets/Mobile-bg.png', fit: BoxFit.cover),

          // Subtle dark overlay to ensure text is readable over the mountain
          Container(color: Colors.black.withAlpha(50)),

          // Splash Icons Background - Only visible on initial load!
          AnimatedOpacity(
            duration: const Duration(milliseconds: 1000),
            opacity: _startAnimation ? 0.0 : 1.0,
            child: SizedBox.expand(
              child: Image.asset(
                'assets/splash_icons_bg_white.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Animated Title
          AnimatedAlign(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutCubic,
            alignment: _startAnimation
                ? const Alignment(0, -0.65)
                : Alignment.center,
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(
                begin: colorScheme.primary,
                end: _startAnimation ? Colors.white : colorScheme.primary,
              ),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
              builder: (context, color, child) {
                return Text(
                  'TrvlEz',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ebGaramond(
                    fontSize: 100,
                    fontWeight: FontWeight.w400,
                    color: color,
                    letterSpacing: 8.5,
                    height: 1.3,
                  ),
                );
              },
            ),
          ),

          // Animated Bottom Content (Subtitle & Buttons)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutCubic,
            bottom: _startAnimation ? 60 : -300, // Slide up from bottom
            left: 24,
            right: 24,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 1000),
              opacity: _startAnimation ? 1.0 : 0.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'All in One Place.\nTravel Like\nA Local',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ebGaramond(
                      fontSize: 42,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () => context.go(AppRoutes.register),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => context.go(AppRoutes.login),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
