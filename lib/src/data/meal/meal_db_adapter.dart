import 'package:db_commons/db_commons.dart';
import 'package:flutter/material.dart';
import 'package:meal_client/src/data/models/cache_model.dart';

import '../../domain/data_base/i_meal_db_adpter.dart';

enum MealDataBaseError { notFound, outdated }

///responsible for comunicate with database
class MealClientDBAdapter implements IMealDBAdpter {
  final MealDataBase dataBase = MealDataBase(boxName: 'clientBox');

  @override
  void save(key, value) async {
    await dataBase.writeMethod(
      key,
      CacheModel(creationDate: DateTime.now(), value: value).toString(),
    );
    debugPrint(">> $key Saved");
  }

  @override
  read(key, {bool ignoreCache = true}) async {
    final data = await dataBase.readMethod(key);
    if (data == null) return MealDataBaseError.notFound;
    if (ignoreCache) return CacheModel.fromJson(data).value;

    CacheModel cache = CacheModel.fromJson(data);

    if (cache.creationDate.difference(DateTime.now()).inMinutes < 30) {
      return cache.value;
    }

    return MealDataBaseError.outdated;
  }

  @override
  void delete(key) async {
    await dataBase.deleteMethod(key);
    debugPrint(">> $key Deleted");
  }
}
