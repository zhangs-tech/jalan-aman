import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userProfileProvider = FutureProvider<Map<String, String>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return {
    'name': prefs.getString('name') ?? '',
    'email': prefs.getString('email') ?? '',
    'phone': prefs.getString('phone') ?? '',
  };
});
