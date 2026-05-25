import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_aman/components/buttons.dart';
import 'package:jalan_aman/components/card.dart';
import 'package:jalan_aman/components/text_field.dart';
import 'package:jalan_aman/pages/login_page.dart';
import 'package:jalan_aman/providers/auth_providers.dart';
import 'package:jalan_aman/theme/theme.dart';
import 'package:jalan_aman/utils/form_validator.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Signing Up'),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final result = await ref.read(authStateProvider.notifier).register(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      // print(result);

      if (!mounted) return;

      final statusCode = result["statusCode"];
      // final data = result["data"];

      messenger.hideCurrentSnackBar();
      if (statusCode == 201) {
        messenger.showSnackBar(
          const SnackBar(content: Text("Register Success")),
        );
        Navigator.pop(context);
      } else if (statusCode == 409) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Email already registered')),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text("Connection error")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(const SnackBar(content: Text("Connection Error")));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.xl,
            ),
            child: _FormCard(
              formKey: _formKey,
              nameController: _nameController,
              emailController: _emailController,
              phoneController: _phoneController,
              passwordController: _passwordController,
              obscurePassword: _obscurePassword,
              isLoading: _isLoading,
              onTogglePassword: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              onRegister: _onRegister,
              onHaveAccount: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onRegister,
    required this.onHaveAccount,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onRegister;
  final VoidCallback onHaveAccount;

  @override
  Widget build(BuildContext context) {
    return Cards(
       child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            //Title
            Text(
              'Create a new account',
              style: AppTextStyles.h1,
              // textAlign: TextAlign.right,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "Join us to start reporting infrastructure issue around you",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              // textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            //Fields
            ModifiedTextField(
              label: "Name",
              controller: nameController,
              hint: "Enter your full name",
              prefixIcon: Icons.person_outline_rounded,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              validator: validateName,
            ),
            const SizedBox(height: AppSpacing.base),

            ModifiedTextField(
              label: "Email",
              controller: emailController,
              hint: "Enter your email address",
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: validateEmail,
            ),
            const SizedBox(height: AppSpacing.base),

            ModifiedTextField(
              label: "Phone",
              controller: phoneController,
              hint: "Enter your phone number",
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: validatePhone,
            ),
            const SizedBox(height: AppSpacing.base),

            ModifiedTextField(
              label: "Password",
              controller: passwordController,
              hint: "Enter your password",
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: obscurePassword,
              validator: validatePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: onTogglePassword,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _PasswordCriteria(passwordController: passwordController),
            const SizedBox(height: AppSpacing.base),

            Buttons(
              onPressed: onRegister,
              label: 'Register',
              type: ButtonType.inverted,
            ),
            const SizedBox(height: AppSpacing.base),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: onHaveAccount,
                  child: Text(
                    'Login',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),

    );
  }
}

class _PasswordCriteria extends StatelessWidget {
  const _PasswordCriteria({required this.passwordController});

  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: passwordController,
      builder: (context, value, child) {
        final text = value.text;
        final hasUpper = RegExp(r'[A-Z]').hasMatch(text);
        final hasLower = RegExp(r'[a-z]').hasMatch(text);
        final hasNumber = RegExp(r'[0-9]').hasMatch(text);
        final hasSpecial = RegExp(r'[!@#\$&*~]').hasMatch(text);
        final hasLength = text.length >= 8;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password must include:',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            _CriteriaRow(label: 'At least 8 characters', met: hasLength),
            _CriteriaRow(label: 'One uppercase letter', met: hasUpper),
            _CriteriaRow(label: 'One lowercase letter', met: hasLower),
            _CriteriaRow(label: 'One number', met: hasNumber),
            _CriteriaRow(label: 'One special character', met: hasSpecial),
          ],
        );
      },
    );
  }
}

class _CriteriaRow extends StatelessWidget {
  const _CriteriaRow({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final color = met ? AppColors.success : AppColors.textTertiary;
    final icon = met ? Icons.check_circle_rounded : Icons.circle_outlined;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: color)),
        ],
      ),
    );
  }
}
