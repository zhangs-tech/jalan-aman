import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_aman/components/card.dart';
import 'package:jalan_aman/components/outline_button.dart';
import 'package:jalan_aman/pages/landing_page.dart';
import 'package:jalan_aman/providers/auth_providers.dart';
import 'package:jalan_aman/providers/profile_providers.dart';
import 'package:jalan_aman/providers/session_providers.dart';
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
    invalidateSessionScopedProviders(ref);

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
        title: Text(
          'Profile',
          style: AppTextStyles.h2.copyWith(color: AppColors.primary),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, _) => _ProfileErrorState(
          onRetry: () => ref.invalidate(userProfileProvider),
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
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ProfileHeader(
                        initials: _initials(profile['name'] ?? ''),
                        name: _displayValue(profile['name'] ?? ''),
                      ),
                      const SizedBox(height: AppSpacing.base),
                      _ProfileDetailsCard(
                        email: _displayValue(profile['email'] ?? ''),
                        phone: _displayValue(profile['phone'] ?? ''),
                      ),
                      const SizedBox(height: AppSpacing.base),
                      _ProfileActionCard(
                        isLoggingOut: _isLoggingOut,
                        onLogout: _onLogout,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileErrorState extends StatelessWidget {
  const _ProfileErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 56,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: AppSpacing.base),
              Text('Failed to load profile', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Pull to refresh or try loading your account again.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: AppSpacing.base),
              AppOutlineButton(
                onPressed: onRetry,
                icon: Icons.refresh_rounded,
                label: 'Retry',
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.initials, required this.name});

  final String initials;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Cards(
      appSpacing: Spacing.xl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.24),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: AppTextStyles.displayMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            name,
            style: AppTextStyles.h1,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailsCard extends StatelessWidget {
  const _ProfileDetailsCard({
    required this.email,
    required this.phone,
  });

  final String email;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          _ProfileInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: email,
          ),
          const Divider(height: AppSpacing.xl, color: AppColors.divider),
          _ProfileInfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: phone,
          ),
        ],
      ),
    );
  }
}

class _ProfileActionCard extends StatelessWidget {
  const _ProfileActionCard({
    required this.isLoggingOut,
    required this.onLogout,
  });

  final bool isLoggingOut;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Session', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.xs),
          Text('Sign out of this device.', style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.base),
          AppOutlineButton(
            isLoading: isLoggingOut,
            onPressed: onLogout,
            icon: Icons.logout_rounded,
            label: 'Logout',
            loadingLabel: 'Logging out...',
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppRadius.inputRadius,
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Cards(appSpacing: Spacing.base, child: child);
  }
}
