import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_aman/components/outline_button.dart';
import 'package:jalan_aman/pages/landing_page.dart';
import 'package:jalan_aman/providers/auth_providers.dart';
import 'package:jalan_aman/providers/profile_providers.dart';
import 'package:jalan_aman/theme/theme.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isLoggingOut = false;

  String _displayValue(String value) => value.isEmpty ? '—' : value;

  String _initials(String name) {
    if (name.trim().isEmpty) return 'JA';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    final first = parts.first.characters.first.toUpperCase();
    final last = parts.last.characters.first.toUpperCase();
    return '$first$last';
  }

  Future<void> _onLogout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);

    await ref.read(authStateProvider.notifier).logout();

    if (!mounted) return;
    setState(() => _isLoggingOut = false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LandingPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Profile'),
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Failed to load profile',
                  style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.md),
              AppOutlineButton(
                onPressed: () => ref.invalidate(userProfileProvider),
                icon: Icons.refresh_rounded,
                label: 'Retry',
              ),
            ],
          ),
        ),
        data: (profile) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () {
            ref.invalidate(userProfileProvider);
            return ref.read(userProfileProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.base),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _ProfileHeader(
                initials: _initials(profile['name'] ?? ''),
                name: _displayValue(profile['name'] ?? ''),
                email: _displayValue(profile['email'] ?? ''),
                phone: _displayValue(profile['phone'] ?? ''),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppOutlineButton(
                isLoading: _isLoggingOut,
                onPressed: _onLogout,
                icon: Icons.logout_rounded,
                label: 'Logout',
                loadingLabel: 'Logging out...',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.initials,
    required this.name,
    required this.email,
    required this.phone,
  });

  final String initials;
  final String name;
  final String email;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: AppTextStyles.displayLarge.copyWith(
                color: AppColors.textInverse,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(name, style: AppTextStyles.h1, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            email,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            phone,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
