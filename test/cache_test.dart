import 'package:hive_test/hive_test.dart';
import 'package:meal_client/meal_client.dart';

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
  test('should return a value even if expired, for Config', () async {
    await adapter.adapterSaveMethod('bolo1', 'fuba');
    await adapter.adapterSaveMethod(ClientKeys.usuario, 'keep value');

    await Future.delayed(const Duration(seconds: 2));
    final data = await adapter.adapterReadMethod('bolo1');
    expect(data, isNull);
    final configData = await adapter.adapterReadMethod(ClientKeys.usuario);
    expect(configData, 'keep value');
  });
}
