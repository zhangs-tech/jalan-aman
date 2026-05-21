import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jalan_aman/pages/landing_page.dart';
import 'package:jalan_aman/services/location_service.dart';
import 'package:jalan_aman/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  LocationService.checkLocationService();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.light;
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      GoogleFonts.dmSansTextTheme(theme.textTheme),
    );

    return MaterialApp(
      title: 'Jalan Aman',
      // debugShowCheckedModeBanner: false,
      theme: theme.copyWith(textTheme: textTheme),
      home: const LandingPage(),
    );
  }
}
