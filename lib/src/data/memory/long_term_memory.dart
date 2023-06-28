part of 'meal_db_adapter.dart';

class _LongTermMemory {
  final MealDataBase longTermMemory = MealDataBase(boxName: 'clientBox');
  static const _longTermMemoryDuration = Duration(hours: 8);
  // static const _longTermMemoryDuration = Duration(seconds: 1);

  Future<void> clearLongTermMemoryInternal() async {
    await longTermMemory.clear();
  }

  Future<dynamic> readLongTermMemory(key) async {
    try {
      final memoryData = await longTermMemory.readMethod(key);
      if (memoryData != null) {
        final cacheData = CacheModel.fromJson(memoryData);
        if (isValidLongTermMemory(cacheData.creationDate)) {
          return cacheData.value;
        } else {
          if (key.toString().toLowerCase().startsWith('clientkeys')) {
            debugPrint(
              "[readLongTermMemory]>> return $key even expired, because is config value",
            );
            return cacheData.value;
          } else {
            debugPrint(
              "[readLongTermMemory]>> $key is not config and expired on long memory removing... "
                  .toUpperCase(),
            );
            await deleteLongTermMemory(key);
            return;
          }
        }
      }
      debugPrint(
        "[readLongTermMemory]>> $key not found on long memory".toUpperCase(),
      );
      return;
    } catch (e) {
      debugPrint(
          "[readLongTermMemory]>> $key cant access memory $e".toUpperCase());
      return;
    }
  }

  Future<void> saveOnLongTermMemory(key, value) async {
    await longTermMemory.writeMethod(
      key,
      CacheModel(creationDate: DateTime.now(), value: value).toString(),
    );
    debugPrint("[saveOnLongTermMemory]>> $key saved");
  }

  Future<void> deleteLongTermMemory(key) async {
    await longTermMemory.deleteMethod(key);
    debugPrint("[deleteLongTermMemory]>> $key deleted");
  }

  bool isValidLongTermMemory(DateTime creation) {
    final currentTime = DateTime.now();
    final difference = currentTime.difference(creation);
    return difference <= _longTermMemoryDuration;
  }
}
