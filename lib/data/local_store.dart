import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  LocalStore._prefs(this._prefs) : _memory = null;

  LocalStore._memory() : _prefs = null, _memory = <String, Object?>{};

  final SharedPreferences? _prefs;
  final Map<String, Object?>? _memory;

  static Future<LocalStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStore._prefs(prefs);
  }

  static LocalStore memory() => LocalStore._memory();

  List<String> readStringList(String key) {
    final value = _prefs?.getStringList(key) ?? _memory?[key];
    return value is List<String> ? value : const <String>[];
  }

  String readString(String key, {String fallback = ''}) {
    final value = _prefs?.getString(key) ?? _memory?[key];
    return value is String ? value : fallback;
  }

  bool readBool(String key, {bool fallback = false}) {
    final value = _prefs?.getBool(key) ?? _memory?[key];
    return value is bool ? value : fallback;
  }

  Future<void> writeStringList(String key, List<String> values) async {
    if (_prefs != null) {
      await _prefs.setStringList(key, values);
    } else {
      _memory?[key] = List<String>.from(values);
    }
  }

  Future<void> writeString(String key, String value) async {
    if (_prefs != null) {
      await _prefs.setString(key, value);
    } else {
      _memory?[key] = value;
    }
  }

  Future<void> writeBool(String key, bool value) async {
    if (_prefs != null) {
      await _prefs.setBool(key, value);
    } else {
      _memory?[key] = value;
    }
  }

  Future<void> remove(String key) async {
    if (_prefs != null) {
      await _prefs.remove(key);
    } else {
      _memory?.remove(key);
    }
  }

  String readJson(String key, {String fallback = '{}'}) {
    final value = _prefs?.getString(key) ?? _memory?[key];
    return value is String ? value : fallback;
  }

  Future<void> writeJson(String key, Object value) async {
    final encoded = jsonEncode(value);
    if (_prefs != null) {
      await _prefs.setString(key, encoded);
    } else {
      _memory?[key] = encoded;
    }
  }
}
