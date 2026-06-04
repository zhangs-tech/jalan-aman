import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jalan_aman/pages/login_page.dart';
import 'package:jalan_aman/pages/register_page.dart';
import '../components/app_icon.dart';
import '../components/buttons.dart';
import '../theme/theme.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // force light status bar icons on dark green background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              // center content
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppIcon(),
                    SizedBox(height: AppSpacing.xl),
                    _AppTitle(),
                  ],
                ),
              ),

              // bottom buttons
              Column(
                children: [
                  Buttons(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    label: 'Register',
                    type: ButtonType.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Buttons(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    label: 'Login',
                    type: ButtonType.outlined,
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Jalan Aman',
          style: AppTextStyles.displayLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'See it, Report it, Stay safe.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.80),
          ),
        ),
      ],
    );
  }
}
