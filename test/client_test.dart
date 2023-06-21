import 'package:db_commons/db_commons.dart';
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
    await MealDataBase(boxName: 'clientBox').clear();

    await MealClientDBAdapter().saveMethod(
      ClientKeys.baseUrl,
      baseUrl,
      ignoreWorkMemory: true,
    );

    await MealClientDBAdapter().saveMethod(
      ClientKeys.usuario,
      user,
      ignoreWorkMemory: true,
    );
    await MealClientDBAdapter().saveMethod(
      ClientKeys.conta,
      account,
      ignoreWorkMemory: true,
    );
    await MealClientDBAdapter().saveMethod(
      ClientKeys.senha,
      password,
      ignoreWorkMemory: true,
    );
  });

  test('should return a Error', () async {
    MealClientRepository repo = MealClientRepository(
      MealUnoApiClient(initializer: initializer),
    );

    final result = await repo.getProducts();
    expect(result, isList);

    await MealClientDBAdapter().saveMethod(
      ClientKeys.usuario,
      'error',
      ignoreWorkMemory: true,
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
    for (int i = 0; i < 300; i++) {
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

    await MealClientDBAdapter().saveMethod(
      ClientKeys.usuario,
      user,
      ignoreWorkMemory: true,
    );
    await MealClientDBAdapter().saveMethod(
      ClientKeys.senha,
      password,
      ignoreWorkMemory: true,
    );

    final result = await repo.getProducts();

    expect(result, isList);

    await MealClientDBAdapter().saveMethod(
      ClientKeys.usuario,
      user2,
      ignoreWorkMemory: true,
    );
    await MealClientDBAdapter().saveMethod(
      ClientKeys.senha,
      password2,
      ignoreWorkMemory: true,
    );

    final result2 = await repo.getProducts();

    expect(result2, isList);
  });
}
