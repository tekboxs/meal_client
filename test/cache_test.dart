import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meal_client/src/data/meal/meal_db_adapter.dart';

import 'package:path_provider/path_provider.dart';
import 'package:test/test.dart';

void main() async {
  final adapter = MealClientDBAdapter();
  Directory dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
  test('should return MealDataBaseError', () async {
    final result = await adapter.read('bolo');

    expect(result, MealDataBaseError.notFound);
  });

  test('should create a field sync', () async {
    adapter.save('bolo1', 'fuba');
    debugPrint('[MealCli] >>  keep execution');
  });

  test('should read field', () async {
    final result = await adapter.read('bolo1');
    expect(result, 'fuba');
  });
}
