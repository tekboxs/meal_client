import 'package:hive/hive.dart';

enum ClientKeys {
  baseUrl,
  conta,
  usuario,
  senha,
  token,
}

extension ClientMemory on ClientKeys {
  Future get read async {
    return await HiveSimpleClientService(boxName: 'client').readMethod(
      this,
    );
  }

  Future get remove async {
    return await HiveSimpleClientService(boxName: 'client').deleteMethod(
      this,
    );
  }

  Future write(value) async {
    await HiveSimpleClientService(boxName: 'client').writeMethod(
      this,
      value,
    );
  }
}

///Save simple data like primitives types
class HiveSimpleClientService {
  final String boxName;
  Box? box;

  HiveSimpleClientService({this.boxName = 'defaultDb'});

  ///open box to make possible read and update
  _init() async {
    if (box == null || !box!.isOpen) {
      box = await Hive.openBox(boxName);
    }
  }

  ///return if a key already in memory
  ///can be used to handle update or add
  Future<bool> existKey(dynamic key) async {
    await _init();
    return box!.containsKey(key.toString());
  }

  ///remove all current data
  Future<void> clear() async {
    await _init();
    await box!.clear();
  }

  ///remove only a key
  ///have no effect if this doesnt exists
  Future deleteMethod(key) async {
    await _init();
    return await box!.delete(key.toString());
  }

  ///return stored value this service only handle
  ///[PRIMITIVES] types, if not exists return null
  Future<dynamic> readMethod(dynamic key) async {
    await _init();
    if (key is int) {
      return await box!.getAt(key);
    } else {
      return await box!.get(key.toString());
    }
  }

  ///override a current key
  ///if not already exists may cause exception
  Future<void> writeMethod(dynamic key, dynamic value) async {
    await _init();
    if (key is int) {
      await box!.putAt(key, value);
    }
    await box!.put(key.toString(), value);
  }

  Future<int> get memoryLength async {
    await _init();
    return box!.length;
  }

  Future<List<dynamic>> get getAllItens async {
    await _init();
    return [for (var key in box!.keys) await readMethod(key)];
  }
}

class HiveCustomClientService<T> {
  String? boxName;
  Box<T>? box;

  HiveCustomClientService({this.boxName}) {
    boxName ??= T.toString()[0].toLowerCase() + T.toString().substring(1);
  }

  ///open related type of box defined by main class
  Future<void> _init() async {
    if (box == null || !box!.isOpen) {
      box = await Hive.openBox<T>(boxName!);
    }
  }

  ///add a [adapter] type in memory
  ///related by <T> on main class
  Future<int> addItem(T item) async {
    await _init();
    return await box!.add(item);
  }

  ///add a [adapter List] type in memory
  ///related by <T> on main class
  Future<Iterable<int>> addAllItems(List<T> items) async {
    await _init();
    return await box!.addAll(items);
  }

  ///override a memory item by new value
  ///if item not current in memory could
  ///cause a error
  Future<void> updateItem(dynamic key, T item) async {
    await _init();

    if (key is int) {
      await box!.putAt(key, item);
    } else {
      await box!.put(key.toString(), item);
    }
  }

  ///delete item by key or index
  ///if not exists have no effect
  Future<void> deleteItem(dynamic key) async {
    await _init();

    if (key is int) {
      await box!.deleteAt(key);
    } else {
      await box!.delete(key.toString());
    }
  }

  ///return stored value this service only handle
  ///[ADAPTERS] types, if not exists return null
  Future<T?> getItem(dynamic key) async {
    await _init();

    if (key is int) {
      return box!.getAt(key);
    } else {
      return box!.get(key.toString());
    }
  }

  ///get all [adapters] in current memory
  Future<List<T>> getAllItems() async {
    await _init();

    return box!.values.toList();
  }

  ///clear current memory
  Future<void> clear() async {
    await _init();

    await box!.clear();
  }

  Future<T?> getItemMaybe(dynamic key) async {
    await _init();

    if (key is int) {
      return box!.getAt(key);
    } else {
      return box!.get(key.toString());
    }
  }

  Future<void> close() async {
    await box?.close();
  }

  ///length of current memory by index
  int get itemCount => box!.length;
}
