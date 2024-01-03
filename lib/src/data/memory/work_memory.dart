part of 'meal_db_adapter.dart';

mixin _WorkMemory {
  final MealDataBase workMemory = MealDataBase(boxName: 'workMemoryBox');
  static const _workMemoryDuration = Duration(minutes: 5);

  Future<void> deleteWorkMemory(key) async {
    await workMemory.deleteMethod(key);
  }

  Future<void> clearWorkMemoryInternal() async {
    await workMemory.clear();
  }

  Future<dynamic> maybeReadWorkMemory(key) async {
    final memoryData = await workMemory.readMethod(key);
    if (memoryData != null) {
      final cacheData = CacheModel.fromJson(memoryData);

      if (isValidWorkMemory(cacheData.creationDate)) {
        return cacheData.value;
      } else {
        debugPrint("[maybeReadWorkMemory]>> $key expired removing");
        await deleteWorkMemory(key);
      }
    } else {
      return null;
    }
  }

  Future<void> maybeSaveOnWorkMemory(key, value,
      {bool forceOverride = false}) async {
    try {
      final memoryData = await workMemory.readMethod(key);

      if (forceOverride) {
        debugPrint(
          "[maybeSaveOnWorkMemory]>> forced override on $key",
        );
        await workMemory.writeMethod(
          key,
          CacheModel(value: value).toString(),
        );
        return;
      }

      if (memoryData != null) {
        final cacheData = CacheModel.fromJson(memoryData);
        if (isValidWorkMemory(cacheData.creationDate)) {
          debugPrint(
            "[maybeSaveOnWorkMemory]>> dont need write on $key WorkMemory",
          );
          return;
        } else {
          debugPrint(
            "[maybeSaveOnWorkMemory]>> $key was expired, override",
          );
          await workMemory.writeMethod(
            key,
            CacheModel(value: value).toString(),
          );
        }
      } else {
        debugPrint("[maybeSaveOnWorkMemory]>> $key is new, saved");
        await workMemory.writeMethod(
          key,
          CacheModel(value: value).toString(),
        );
      }
    } catch (e) {
      debugPrint(
        "[maybeSaveOnWorkMemory]>> cant fetch memory $e",
      );
      return;
    }
  }

  bool isValidWorkMemory(DateTime creation) {
    final currentTime = DateTime.now();
    final difference = currentTime.difference(creation);
    return difference <= _workMemoryDuration;
  }
}
