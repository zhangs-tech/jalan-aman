import 'package:flutter/material.dart';
import 'package:jalan_aman/components/outline_button.dart';
import 'package:jalan_aman/pages/landing_page.dart';
import 'package:jalan_aman/services/secure_storage.dart';
import 'package:jalan_aman/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  bool _isLoggingOut = false;

  String _name = '';
  String _email = '';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _name = prefs.getString('name') ?? '';
      _email = prefs.getString('email') ?? '';
      _phone = prefs.getString('phone') ?? '';
      _isLoading = false;
    });
  }

  Future<void> _onLogout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);

    final prefs = await SharedPreferences.getInstance();
    await SecureStorage.delete('accessToken');
    await prefs.remove('userId');
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('phone');
    await prefs.remove('role');

    if (!mounted) return;
    setState(() => _isLoggingOut = false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LandingPage()),
      (route) => false,
    );
  }

  String _displayValue(String value) => value.isEmpty ? '—' : value;

  String get _initials {
    if (_name.trim().isEmpty) return 'JA';
    final parts = _name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    final first = parts.first.characters.first.toUpperCase();
    final last = parts.last.characters.first.toUpperCase();
    return '$first$last';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Profile'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.refresh_rounded),
        //     onPressed: _loadProfile,
        //   ),
        // ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadProfile,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.base),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _ProfileHeader(
                    initials: _initials,
                    name: _displayValue(_name),
                    email: _displayValue(_email),
                    phone: _displayValue(_phone),
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
