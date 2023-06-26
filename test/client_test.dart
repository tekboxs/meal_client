import 'package:flutter/material.dart';
import 'package:hive_test/hive_test.dart';
import 'package:meal_client/meal_client.dart';
import 'package:test/test.dart';
import 'keys.dart';

class MealClientRepository {
  final IMealClient _client;

  MealClientRepository(this._client);

  getProducts() async {
    return await _client.getMethod('/estoque/produto');
  }

  getProductsWithWorkMemory() async {
    return await _client.getMethod('/estoque/produto', enableWorkMemory: true);
  }

  getProductsWithNoWorkMemory() async {
    return await _client.getMethod('/estoque/produto', enableWorkMemory: false);
  }

  getWithBaseUrl() async {
    return await _client.getMethod('$baseUrl/estoque/produto');
  }

  getProductFromCacheOnError() async {
    await _client.getMethod('/estoque/produto');

    return await _client.getMethod(
      '/estoque/produto',
      headers: {'bolo': 'fuba'},
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authenticator = MealAuthenticator();

  final interceptors = MealUnoInterceptors(authenticator: authenticator);

  final initializer = MealUnoInitializer(baseUrl, interceptors);

  setUp(() async {
    await setUpTestHive();
    final adapter = MealClientDBAdapter();
    await adapter.adapterClearLongTermMemory();
    await adapter.adapterClearWorkMemory();

    await adapter.adapterSaveMethod(
      ClientKeys.baseUrl,
      baseUrl,
    );

    await adapter.adapterSaveMethod(
      ClientKeys.usuario,
      user,
    );
    await adapter.adapterSaveMethod(
      ClientKeys.conta,
      account,
    );
    await adapter.adapterSaveMethod(
      ClientKeys.senha,
      password,
    );
  });

  test('should return a Error', () async {
    MealClientRepository repo = MealClientRepository(
      MealUnoApiClient(initializer: initializer),
    );

    final result = await repo.getProducts();
    expect(result, isList);

    await MealClientDBAdapter().adapterSaveMethod(
      ClientKeys.usuario,
      'error',
    );
    expectLater(
      () async => (await repo.getProducts()),
      throwsA(isA<Exception>()),
    );
  });
  test('should do memoryRequest when avaliable', () async {
    MealClientRepository repo = MealClientRepository(
      MealUnoApiClient(initializer: initializer),
    );

    dynamic result1;
    for (int i = 0; i < 10; i++) {
      result1 = await repo.getProducts();
    }

    expect(result1, isList);
  });

  test('should ignore initializer url', () async {
    MealClientRepository repo = MealClientRepository(
      MealUnoApiClient(initializer: initializer),
    );
    final result = await repo.getWithBaseUrl();

    expect(result, isList);
  });

  test('should return a List', () async {
    MealClientRepository repo = MealClientRepository(
      MealUnoApiClient(initializer: initializer),
    );
    final result = await repo.getProducts();

    expect(result, isList);
  });

  test('should get cache when error', () async {
    MealClientRepository repo = MealClientRepository(
      MealUnoApiClient(initializer: initializer),
    );
    final result = await repo.getProductFromCacheOnError();

    expect(result, isList);
  });
  test('should auth new user', () async {
    MealClientRepository repo = MealClientRepository(
      MealUnoApiClient(initializer: initializer),
    );

    await MealClientDBAdapter().adapterSaveMethod(
      ClientKeys.usuario,
      user,
    );
    await MealClientDBAdapter().adapterSaveMethod(
      ClientKeys.senha,
      password,
    );

    final result = await repo.getProducts();

    expect(result, isList);

    await MealClientDBAdapter().adapterSaveMethod(
      ClientKeys.usuario,
      user2,
    );
    await MealClientDBAdapter().adapterSaveMethod(
      ClientKeys.senha,
      password2,
    );

    final result2 = await repo.getProducts();

    expect(result2, isList);
  });
}
