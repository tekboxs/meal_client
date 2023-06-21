import 'package:db_commons/db_commons.dart';
import 'package:logger/logger.dart';
import 'package:meal_client/src/data/models/cache_model.dart';

enum MealDataBaseError { notFound, outdated }

/// Responsible for communicating with the database.
class MealClientDBAdapter {
  var logger = Logger();

  final MealDataBase dataBase = MealDataBase(boxName: 'clientBox');

  static const _workCacheDuration = Duration(minutes: 5);
  static const _cacheDuration = Duration(hours: 8);

  Future<void> saveMethod(
    dynamic key,
    dynamic valueToSave, {
    bool ignoreWorkMemory = false,
  }) async {
    final memory = ignoreWorkMemory
        ? null
        : await maybeWorkMemory(
            key,
            returnRaw: true,
          );

    if (memory != null) {
      // Check if the value was written to memory within the last 5 minutes
      final memoryCreationTime = memory.creationDate;
      final currentTime = DateTime.now();
      final difference = currentTime.difference(memoryCreationTime);

      if (difference <= _workCacheDuration) {
        logger.w("$key DONT saved, work memory yet available");
        return;
      }
    }

    await dataBase.writeMethod(
      key,
      CacheModel(creationDate: DateTime.now(), value: valueToSave).toString(),
    );
    logger.d("$key Saved");
  }

  Future<dynamic> read(
    dynamic key, {
    bool ignoreCache = true,
    bool ignoreWorkCache = false,
  }) async {
    if (await existsKey(key)) {
      final data = await dataBase.readMethod(key);
      final cache = CacheModel.fromJson(data);

      if (ignoreCache) return cache.value;

      if (_isWorkCacheAvailable(cache) && !ignoreWorkCache) {
        logger.i("$key has Work cache, ignoring request");
        return cache.value;
      }

      if (_isValidCache(cache)) {
        return cache.value;
      } else {
        logger.i("$key EXPIRED, removing from db...");
        await delete(key);
      }
    }

    logger.w("$key NOT EXIST in DB");
    return null;
  }

  Future<void> delete(dynamic key) async {
    await dataBase.deleteMethod(key);
    logger.i("$key deleted");
  }

  Future<bool> existsKey(dynamic key) async {
    return await dataBase.existKey(key);
  }

  Future<dynamic> maybeWorkMemory(dynamic key, {bool returnRaw = false}) async {
    if (await existsKey(key)) {
      final data = await dataBase.readMethod(key);
      final cache = CacheModel.fromJson(data);

      if (_isWorkCacheAvailable(cache)) {
        if (returnRaw) {
          return cache;
        } else {
          return cache.value;
        }
      }
    }
    return null;
  }

  bool _isValidCache(CacheModel cache) {
    final currentTime = DateTime.now();
    final difference = currentTime.difference(cache.creationDate);
    return difference <= _cacheDuration;
  }

  bool _isWorkCacheAvailable(CacheModel cache) {
    final currentTime = DateTime.now();
    final difference = currentTime.difference(cache.creationDate);
    return difference <= _workCacheDuration;
  }
}
