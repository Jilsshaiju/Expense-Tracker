import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;
  bool _minDelayPassed = false;

  @override
  void initState() {
    super.initState();
    // Ensure animation plays for at least 1.5 s before routing.
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _minDelayPassed = true;
      _tryNavigate();
    });
  }

  void _tryNavigate() {
    if (!mounted || _navigated || !_minDelayPassed) return;
    final status = context.read<AppAuthProvider>().status;
    if (status == AuthStatus.initial) return; // still resolving
    _navigated = true;
    if (status == AuthStatus.authenticated) {
      Navigator.pushReplacementNamed(context, AppRouter.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Re-run whenever auth status changes.
    final status = context.watch<AppAuthProvider>().status;
    if (status != AuthStatus.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryNavigate());
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.cardGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 128,
                height: 128,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
                  .animate()
                  .scale(
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                      begin: const Offset(0.5, 0.5))
                  .fadeIn(),
              const SizedBox(height: 24),
              Text(AppStrings.appName,
                      style: AppTextStyles.displayLarge
                          .copyWith(color: Colors.white, fontSize: 40))
                  .animate()
                  .slideY(begin: 0.3, duration: 500.ms, delay: 300.ms)
                  .fadeIn(delay: 300.ms),
              const SizedBox(height: 8),
              Text(AppStrings.tagline,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: Colors.white70, fontSize: 15))
                  .animate()
                  .fadeIn(delay: 600.ms),
              const SizedBox(height: 60),
              const CircularProgressIndicator(
                      color: Colors.white54, strokeWidth: 2)
                  .animate()
                  .fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
