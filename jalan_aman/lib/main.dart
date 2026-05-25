import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jalan_aman/components/app_icon.dart';
import 'package:jalan_aman/pages/home_page.dart';
import 'package:jalan_aman/pages/landing_page.dart';
import 'package:jalan_aman/providers/auth_providers.dart';
import 'package:jalan_aman/services/location_service.dart';
import 'package:jalan_aman/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  LocationService.checkLocationService();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.light;
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      GoogleFonts.dmSansTextTheme(theme.textTheme),
    );

    return MaterialApp(
      title: 'Jalan Aman',
      theme: theme.copyWith(textTheme: textTheme),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends ConsumerStatefulWidget {
  const _AuthGate();

  @override
  ConsumerState<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<_AuthGate> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(authStateProvider, (prev, next) {
      if (next.status != AuthStatus.unknown) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => next.status == AuthStatus.authenticated
                ? const HomePage()
                : const LandingPage(),
          ),
          (_) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: AppIcon(),
      ),
    );
  }
}
