// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:db_commons/db_commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_client/meal_client.dart';

import 'keys.dart';

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

  getProductFromCacheOnError() async {
    await _client.getMethod('/estoque/produto');

    debugPrint("[MealCli] >> request done, executing error");

    return await _client.getMethod(
      '/estoque/produto',
      headers: {'bolo': 'fuba'},
    );
  }
}

void main() async {
  /// init hive
  await MealHiveInitializer().init();

  ///responsible for auth methods
  ///recive a client to avoid loop with initializer
  final authenticator = MealAuthenticator();

  ///responsible to intercep request and respose to add
  ///headers for exemple and get auth token
  final interceptors = MealUnoInterceptors(authenticator: authenticator);

  ///will get interceptor and url to return a client, used in repositories
  final initializer = MealUnoInitializer(baseUrl, interceptors);

  test('should return a Error', () async {
    await MealDataBase(boxName: 'clientBox').clearMemory();

    MealClientDBAdapter().save(ClientKeys.baseUrl, 'http://cecum.com.br:5000');
    MealClientDBAdapter().save(ClientKeys.usuario, 'supervisor');
    MealClientDBAdapter().save(ClientKeys.conta, 'grg');
    MealClientDBAdapter().save(ClientKeys.senha, 'kx1892');

    MealClientRepository repo = MealClientRepository(
      MealUnoApiClient(initializer: initializer),
    );
    final result = await repo.getProducts();

    debugPrint(">> result with success: ${result.toString().substring(0, 20)}");

    MealClientDBAdapter().delete(ClientKeys.token);
    MealClientDBAdapter().save(ClientKeys.senha, 'kx1892--');

    final result2 = await repo.getProducts();
    debugPrint(">> result with error: ${result2.toString().substring(0, 20)}");

    expect(result2, MealClientError.notFound);
  });
  test('should return a List', () async {
    await MealDataBase(boxName: 'clientBox').clearMemory();

    MealClientDBAdapter().delete(ClientKeys.token);
    MealClientDBAdapter().save(ClientKeys.baseUrl, 'http://cecum.com.br:5000');
    MealClientDBAdapter().save(ClientKeys.usuario, 'supervisor');
    MealClientDBAdapter().save(ClientKeys.conta, 'grg');
    MealClientDBAdapter().save(ClientKeys.senha, 'kx1892');

    MealClientRepository repo = MealClientRepository(
      MealUnoApiClient(initializer: initializer),
    );
    final result = await repo.getProducts();

    debugPrint("[MealCli] >>  t1 res: ${result.toString().substring(0, 20)}");
    expect(result, isList);
    debugPrint("[MealCli] >>  t1 item: ${result.first}");
  });

  test('should use cache', () async {
    MealClientRepository repo = MealClientRepository(
      MealUnoApiClient(initializer: initializer),
    );
    final result = await repo.getProductsWithCache();

    debugPrint("[MealCli] >>  t2 res: ${result.toString().substring(0, 20)}");

    expect(result, isList);
    debugPrint("[MealCli] >>  t2 item: ${result.first}");
  });

  test('should get cache when error', () async {
    MealClientRepository repo = MealClientRepository(
      MealUnoApiClient(initializer: initializer),
    );
    final result = await repo.getProductFromCacheOnError();

    debugPrint("[MealCli] >>  t3 res: ${result.toString().substring(0, 20)}");

    expect(result, isList);
    debugPrint("[MealCli] >>  t3 item: ${result.first}");
  });
}
