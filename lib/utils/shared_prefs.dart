import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences? _prefs;
  static const _kActiveId = 'activeStudentId';
  static const _kActiveEmail = 'activeEmail';
  static const _kActiveName = 'activeName';
  static const _kActiveAvatar = 'activeAvatar';
  static const _kActiveContact = 'activeContactNo';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveActiveProfile({
    required String id,
    required String email,
    required String name,
    required String contact,
    String avatar = '',
  }) async {
    await _prefs?.setString(_kActiveId, id);
    await _prefs?.setString(_kActiveEmail, email);
    await _prefs?.setString(_kActiveName, name);
    await _prefs?.setString(_kActiveContact, contact);
    await _prefs?.setString(_kActiveAvatar, avatar);
  }

  static String? getActiveStudentId() => _prefs?.getString(_kActiveId);
  static String? getActiveEmail() => _prefs?.getString(_kActiveEmail);
  static String? getActiveName() => _prefs?.getString(_kActiveName);
  static String? getActiveAvatar() => _prefs?.getString(_kActiveAvatar);
  static String? getActiveContact() => _prefs?.getString(_kActiveContact);

  static Future<void> clearActiveProfile() async {
    await _prefs?.remove(_kActiveId);
    await _prefs?.remove(_kActiveEmail);
    await _prefs?.remove(_kActiveName);
    await _prefs?.remove(_kActiveContact);
    await _prefs?.remove(_kActiveAvatar);
  }
}
