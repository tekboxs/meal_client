// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:db_commons/db_commons.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meal_client/meal_client.dart';
import 'package:test/test.dart';
import 'keys.dart';
// ignore_for_file: public_member_api_docs, sort_constructors_first

///this is how sould be used in code
class MealClientRepository {
  final IMealClient _client;
  MealClientRepository(this._client);

  getProducts() async {
    return await _client.getMethod('/estoque/produto');
  }

  getProductsWithCache() async {
    return await _client.getMethod('/estoque/produto', enableCache: true);
  }

  getWithBaseUrl() async {
    return await _client.getMethod('$baseUrl/estoque/produto');
  }

  getProductFromCacheOnError() async {
    await _client.getMethod('/estoque/produto');

    // debugPrint("[MealCli] >> request done, executing error");

    return await _client.getMethod(
      '/estoque/produto',
      headers: {'bolo': 'fuba'},
    );
  }
}

void main() async {
  /// init hive
  // await MealHiveInitializer().init();
  WidgetsFlutterBinding.ensureInitialized();

  ///responsible for auth methods
  ///recive a client to avoid loop with initializer
  final authenticator = MealAuthenticator();

  ///responsible to intercep request and respose to add
  ///headers for exemple and get auth token
  final interceptors = MealUnoInterceptors(authenticator: authenticator);

  ///will get interceptor and url to return a client, used in repositories
  final initializer = MealUnoInitializer(baseUrl, interceptors);

  setUp(() async {
    await Hive.initFlutter();
    await MealDataBase(boxName: 'clientBox').clearMemory();

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

    try {
      final result = await repo.getProducts();
      // debugPrint(
      // ">> result with success: ${result.toString().substring(0, 20)}");

      // await MealClientDBAdapter().delete(ClientKeys.token);
      await MealClientDBAdapter().save(ClientKeys.usuario, 'supervisor2');

      final result2 = await repo.getProducts();
      // debugPrint(
      // ">> result with error: ${result2.toString().substring(0, 20)}");
    } catch (e) {
      // debugPrint(e.toString());
    }
  });
  test('should ignore initializer url', () async {
    MealClientRepository repo = MealClientRepository(
      MealUnoApiClient(initializer: initializer),
    );
    final result = await repo.getWithBaseUrl();

    // debugPrint(
    // "[MealCli] >> baseurl res: ${result.toString().substring(0, 20)}");
    expect(result, isList);
    // debugPrint("[MealCli] >>  baseurl item: ${result.first}");
  });

  test('should return a List', () async {
    MealClientRepository repo = MealClientRepository(
      MealUnoApiClient(initializer: initializer),
    );
    final result = await repo.getProducts();

    // debugPrint("[MealCli] >>  t1 res: ${result.toString().substring(0, 20)}");
    expect(result, isList);
    // debugPrint("[MealCli] >>  t1 item: ${result.first}");
  });

  test('should use cache', () async {
    MealClientRepository repo = MealClientRepository(
      MealUnoApiClient(initializer: initializer),
    );
    final result = await repo.getProductsWithCache();

    // debugPrint("[MealCli] >>  t2 res: ${result.toString().substring(0, 20)}");

    expect(result, isList);
    // debugPrint("[MealCli] >>  t2 item: ${result.first}");
  });

  test('should get cache when error', () async {
    MealClientRepository repo = MealClientRepository(
      MealUnoApiClient(initializer: initializer),
    );
    final result = await repo.getProductFromCacheOnError();

    // debugPrint("[MealCli] >>  t3 res: ${result.toString().substring(0, 20)}");

    expect(result, isList);
    // debugPrint("[MealCli] >>  t3 item: ${result.first}");
  });
}
