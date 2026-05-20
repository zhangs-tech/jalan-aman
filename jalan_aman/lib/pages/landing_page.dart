import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/app_icon.dart';
import '../components/buttons.dart';
import '../theme/theme.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Force light status bar icons on dark green background
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              // ── Center content ──────────────────────────────
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

              // ── Bottom buttons ──────────────────────────────
              Column(
                children: [
                  Buttons(
                    onPressed: () {
                      // TODO: Navigator.pushNamed(context, '/register');
                    },
                    label: 'Daftar',
                    type: ButtonType.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Buttons(
                    onPressed: () {
                      // TODO: Navigator.pushNamed(context, '/login');
                    },
                    label: 'Masuk',
                    type: ButtonType.inverted,
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xl),
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
          'Laporkan. Pantau. Perbaiki.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.80),
          ),
        ),
      ],
    );
  }
}
