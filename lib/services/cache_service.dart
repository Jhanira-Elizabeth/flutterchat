import 'package:hive/hive.dart';

class CacheService {
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
