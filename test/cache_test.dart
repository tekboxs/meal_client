import 'package:hive_test/hive_test.dart';
import 'package:meal_client/src/data/memory/meal_db_adapter.dart';

import 'package:test/test.dart';

void main() async {
  final adapter = MealClientDBAdapter();
  setUp(() async {
    await setUpTestHive();
  });

  test('should return MealDataBaseError', () async {
    final data = await adapter.adapterReadMethod('bolo');
    expect(data, isNull);
  });

  test('should create a field', () async {
    await adapter.adapterSaveMethod('bolo1', 'fuba');
  });

  test('should create and read field', () async {
    await adapter.adapterSaveMethod('bolo1', 'fuba');
    final result = await adapter.adapterReadMethod('bolo1');
    expect(result, 'fuba');
  });
  test('should override a expired field', () async {
    await adapter.adapterSaveMethod('bolo1', 'fuba');
    await Future.delayed(const Duration(seconds: 8));
    final data = await adapter.adapterReadMethod('bolo1');
    expect(data, 'fuba');
  });
}
