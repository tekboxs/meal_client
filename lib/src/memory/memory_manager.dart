import 'package:db_commons/db_commons.dart';
import 'package:meal_client/src/data/models/cache_model.dart';

import '../utils/memory_enum_keys.dart';

class MemoryManager {
  static HiveCustomService<CacheModel> get customService =>
      HiveCustomService<CacheModel>(
        boxName: MemoryBoxes.cache.name,
      );
  static HiveSimpleService get service => HiveSimpleService(
        boxName: MemoryBoxes.configs.name,
      );
}
