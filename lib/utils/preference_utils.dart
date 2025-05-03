import 'package:shared_preferences/shared_preferences.dart';

Future<String> getString(String key) async {
  final preferences = await SharedPreferences.getInstance();
  return preferences.getString(key) ?? '';
}

Future<void> setString(String key, String value) async {
  final preferences = await SharedPreferences.getInstance();
  await preferences.setString(key, value);
}

Future<bool> getBool(String key) async {
  final preferences = await SharedPreferences.getInstance();
  return preferences.getBool(key) ?? false;
}

Future<void> setBool(String key, bool value) async {
  final preferences = await SharedPreferences.getInstance();
  await preferences.setBool(key, value);
}
