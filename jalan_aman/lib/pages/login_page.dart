import 'package:flutter/material.dart';
import 'package:jalan_aman/components/buttons.dart';
import 'package:jalan_aman/components/text_field.dart';
import 'package:jalan_aman/pages/register_page.dart';
import 'package:jalan_aman/theme/theme.dart';
import 'package:jalan_aman/utils/form_validator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });

    //TODO: API CALL
    setState(() {
      _isLoading = false;
    });
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
              emailController: _emailController,
              passwordController: _passwordController,
              obscurePassword: _obscurePassword,
              isLoading: _isLoading,
              onTogglePassword: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              onLogin: _onLogin,
              onDontHaveAccount: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
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
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onLogin,
    required this.onDontHaveAccount,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;
  final VoidCallback onDontHaveAccount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.card,
      ),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            //Title
            Text(
              'Login to existing account',
              style: AppTextStyles.h1,
              // textAlign: TextAlign.right,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "Continue to reporting infrastructure issue around you",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              // textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            //Fields
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
            const SizedBox(height: AppSpacing.base),

            Buttons(
              onPressed: onLogin,
              label: 'Register',
              type: ButtonType.inverted,
            ),
            const SizedBox(height: AppSpacing.base),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Dont have an account? ',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: onDontHaveAccount,
                  child: Text(
                    'Register',
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
