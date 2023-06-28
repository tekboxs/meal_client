// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:db_commons/db_commons.dart';
import 'package:flutter/material.dart';

import 'package:meal_client/src/data/models/cache_model.dart';

part 'long_term_memory.dart';
part 'work_memory.dart';

enum MealDataBaseError { notFound, outdated }

class MealClientDBAdapter extends _LongTermMemory with _WorkMemory {
  final bool enableWorkMemory;
  final bool enableLongTermMemory;
  final bool forceOverride;
  MealClientDBAdapter(
      {this.enableWorkMemory = false,
      this.enableLongTermMemory = true,
      this.forceOverride = false});

  Future<void> adapterSaveMethod(key, value) async {
    await maybeSaveOnWorkMemory(key, value, forceOverride: forceOverride);
    await saveOnLongTermMemory(key, value);

    return;
  }

  Future<dynamic> adapterReadMethod(key) async {
    if (enableWorkMemory) {
      final workMemoryData = await maybeReadWorkMemory(key);
      if (workMemoryData != null) {
        return workMemoryData;
      }
    }
    if (enableLongTermMemory) {
      final longTermMemoryData = await readLongTermMemory(key);
      if (longTermMemoryData != null) {
        return longTermMemoryData;
      }
    }
    debugPrint("[readMethod]>> no data found on memory for $key");
    return;
  }

  Future<void> adapterDeleteMethod(key) async {
    await deleteWorkMemory(key);
    await deleteLongTermMemory(key);

    return;
  }

  Future<void> adapterClearWorkMemory() async {
    await clearWorkMemoryInternal();
    debugPrint("[clearWorkMemory]>>memory cleared");
    return;
  }

  Future<void> adapterClearLongTermMemory() async {
    await clearLongTermMemoryInternal();
    debugPrint("[clearLongTermMemory]>>memory cleared");
    return;
  }
}

/// Responsible for communicating with the database.
// class MealClientDBAdapter2 {
//   var logger = Logger();

//   final MealDataBase longTermDataBase = MealDataBase(boxName: 'clientBox');
//   final MealDataBase workMemoryDataBase = MealDataBase(
//     boxName: 'workMemoryBox',
//   );

//   static const _workCacheDuration = Duration(minutes: 5);
//   static const _cacheDuration = Duration(hours: 8);

//   Future<bool> _canWriteOnWorkMemory(dynamic key) async {
//     try {
//       final workMemoryData = await workMemoryDataBase.readMethod(key);

//       if (workMemoryData != null) {
//         final workMemoryCacheModel = CacheModel.fromJson(workMemoryData);
//         if (_isWorkCacheAvailable(workMemoryCacheModel)) {
//           //yet valid
//           return false;
//         }
//         //expired so can override
//         return true;
//       }

//       //not already in memory
//       return true;
//     } catch (e) {
//       logger.e('[_canWriteOnWorkMemory]>> cant check memory $e');
//       //error, avoid white
//       return false;
//     }
//   }

//   Future<bool> _canWriteOnLongTermMemory(dynamic key) async {
//     try {
//       final workMemoryData = await longTermDataBase.readMethod(key);

//       if (workMemoryData != null) {
//         final workMemoryCacheModel = CacheModel.fromJson(workMemoryData);
//         if (_isValidCache(workMemoryCacheModel)) {
//           //yet valid
//           return false;
//         }
//         //expired so can override
//         return true;
//       }

//       //not already in memory
//       return true;
//     } catch (e) {
//       logger.e('[_canWriteOnWorkMemory]>> cant check memory $e');
//       //error, avoid white
//       return false;
//     }
//   }

//   Future<void> saveMethod(dynamic key, dynamic value) async {
//     //check if can write in work memory
//   }

//   Future<void> saveMethod2(
//     dynamic key,
//     dynamic valueToSave, {
//     bool ignoreWorkMemory = false,
//   }) async {
//     final memory = ignoreWorkMemory
//         ? null
//         : await maybeWorkMemory(
//             key,
//             returnRaw: true,
//           );

//     if (memory != null) {
//       // Check if the value was written to memory within the last 5 minutes
//       final memoryCreationTime = memory.creationDate;
//       final currentTime = DateTime.now();
//       final difference = currentTime.difference(memoryCreationTime);

//       if (difference <= _workCacheDuration) {
//         logger.w("$key DONT saved, work memory yet available");
//         return;
//       }
//     }

//     await dataBase.writeMethod(
//       key,
//       CacheModel(creationDate: DateTime.now(), value: valueToSave).toString(),
//     );
//     logger.d("$key Saved");
//   }

//   Future<dynamic> read(
//     dynamic key, {
//     bool ignoreCache = true,
//     bool ignoreWorkCache = false,
//   }) async {
//     if (await existsKey(key)) {
//       final data = await dataBase.readMethod(key);
//       final cache = CacheModel.fromJson(data);

//       if (ignoreCache) return cache.value;

//       if (_isWorkCacheAvailable(cache) && !ignoreWorkCache) {
//         logger.i("$key has Work cache, ignoring request");
//         return cache.value;
//       }

//       if (_isValidCache(cache)) {
//         return cache.value;
//       } else {
//         logger.i("$key EXPIRED, removing from db...");
//         await delete(key);
//       }
//     }

//     logger.w("$key NOT EXIST in DB");
//     return null;
//   }

//   Future<void> delete(dynamic key) async {
//     await dataBase.deleteMethod(key);
//     logger.i("$key deleted");
//   }

//   Future<bool> existsKey(dynamic key) async {
//     return await dataBase.existKey(key);
//   }

//   Future<dynamic> maybeWorkMemory(dynamic key, {bool returnRaw = false}) async {
//     if (await existsKey(key)) {
//       final data = await dataBase.readMethod(key);
//       final cache = CacheModel.fromJson(data);

//       if (_isWorkCacheAvailable(cache)) {
//         if (returnRaw) {
//           return cache;
//         } else {
//           return cache.value;
//         }
//       }
//     }
//     return null;
//   }

//   bool _isValidCache(CacheModel cache) {
//     final currentTime = DateTime.now();
//     final difference = currentTime.difference(cache.creationDate);
//     return difference <= _cacheDuration;
//   }

//   bool _isWorkCacheAvailable(CacheModel cache) {
//     final currentTime = DateTime.now();
//     final difference = currentTime.difference(cache.creationDate);
//     return difference <= _workCacheDuration;
//   }
// }
