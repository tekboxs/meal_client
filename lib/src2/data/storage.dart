import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static Future remove(String key) async {
    final SharedPreferences shared = await SharedPreferences.getInstance();
    await shared.remove(key);
    return true;
  }

  static Future read(String key) async {
    final SharedPreferences shared = await SharedPreferences.getInstance();
    return shared.get(key);
  }

  static Future<bool> write(String key, value) async {
    final SharedPreferences shared = await SharedPreferences.getInstance();
    bool sucess = false;
    await shared.setString(key, value ?? "").then((result) => sucess = result);
    return sucess;
  }
}
