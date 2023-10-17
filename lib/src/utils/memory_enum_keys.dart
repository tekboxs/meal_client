import 'package:meal_client/src/data/models/cache_model.dart';

import '../memory/memory_manager.dart';

extension MemoryCacheAdapter on Uri {
  Future<List<CacheModel>?> get memoryGetAll async =>
      await MemoryManager.customService.getAllItems();

  Future<CacheModel?> get memoryGet async =>
      await MemoryManager.customService.getItem(
        this,
      );

  Future get memoryRemove async => await MemoryManager.customService.deleteItem(
        this,
      );

  Future memoryUpdate(value) async =>
      await MemoryManager.customService.updateItem(
        this,
        CacheModel(value: value),
      );
  Future memoryAdd(value) async => await MemoryManager.customService.addItem(
        CacheModel(value: value),
      );
  Future memoryAddAll(List values) async =>
      await MemoryManager.customService.addAllItems(
        values.map((value) => CacheModel(value: value)).toList(),
      );
}

extension MemoryConfigAdapter on ClientConfigEnumKeys {
  Future get read async => await MemoryManager.service.readMethod(this);

  Future get remove async => await MemoryManager.service.deleteMethod(this);

  Future write(value) async => await MemoryManager.service.writeMethod(
        this,
        value,
      );
}

enum MemoryBoxes {
  configs,
  cache,
}

enum ClientConfigEnumKeys {
  token,
  usuario,
  senha,
  conta,
  baseUrl,
}
