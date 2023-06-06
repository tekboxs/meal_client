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

    await MealClientDBAdapter().save(
      ClientKeys.baseUrl,
      baseUrl,
    );

    await MealClientDBAdapter().save(ClientKeys.usuario, user);
    await MealClientDBAdapter().save(ClientKeys.conta, account);
    await MealClientDBAdapter().save(ClientKeys.senha, password);
  });

  test('should return a Error', () async {
    MealClientRepository repo = MealClientRepository(
      MealUnoApiClient(initializer: initializer),
    );

    final result = await repo.getProducts();
    expect(result, isList);

    await MealClientDBAdapter().save(ClientKeys.usuario, 'fddas');
    expectLater(
      () async => (await repo.getProducts()),
      throwsA(isA<MealClientError>()),
    );
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

    await MealClientDBAdapter().save(ClientKeys.usuario, user);
    await MealClientDBAdapter().save(ClientKeys.senha, password);

    final result = await repo.getProducts();

    expect(result, isList);

    await MealClientDBAdapter().save(ClientKeys.usuario, user2);
    await MealClientDBAdapter().save(ClientKeys.senha, password2);

    final result2 = await repo.getProducts();

    expect(result2, isList);
  });
}
