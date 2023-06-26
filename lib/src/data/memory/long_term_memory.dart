part of 'meal_db_adapter.dart';

class _LongTermMemory {
  final MealDataBase longTermMemory = MealDataBase(boxName: 'clientBox');
  static const _longTermMemoryDuration = Duration(hours: 8);

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
          debugPrint("[readLongTermMemory]>> $key expired on long memory ");
          await deleteLongTermMemory(key);
          return;
        }
      }
      debugPrint("[readLongTermMemory]>> $key not found on long memory ");
      return;
    } catch (e) {
      debugPrint("[readLongTermMemory]>> $key cant access memory $e");
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
    debugPrint("diffe>> ${difference <= _longTermMemoryDuration}");
    return difference <= _longTermMemoryDuration;
  }
}
