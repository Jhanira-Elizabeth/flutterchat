import 'package:hive/hive.dart';

class CacheService {
  /// Devuelve todos los datos de un box como Map<String, dynamic>
  static Future<Map<String, dynamic>> getAllData(String boxName) async {
    var box = await Hive.openBox(boxName);
    return Map<String, dynamic>.from(box.toMap());
  }
  static Future<Box> openBox(String boxName) async {
    return await Hive.openBox(boxName);
  }

  static Future<void> saveData(String boxName, String key, dynamic value) async {
    var box = await Hive.openBox(boxName);
    await box.put(key, value);
  }

  static Future<dynamic> getData(String boxName, String key) async {
    var box = await Hive.openBox(boxName);
    return box.get(key);
  }

  static Future<void> clearBox(String boxName) async {
    var box = await Hive.openBox(boxName);
    await box.clear();
  }
}
