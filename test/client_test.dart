// ignore_for_file: public_member_api_docs, sort_constructors_first

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

    debugPrint(">>request done, executing error");

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
  final authenticator = MealAuthenticator(
    baseUrl: baseUrl,
    user: user,
    password: password,
    account: account,
  );

  ///responsible to intercep request and respose to add
  ///headers for exemple and get auth token
  final interceptors = MealUnoInterceptors(authenticator: authenticator);

  ///will get interceptor and url to return a client, used in repositories
  final initializer = MealUnoInitializer(baseUrl, interceptors);

  test('should return a List', () async {
    MealClientRepository repo = MealClientRepository(
      MealUnoApiClient(initializer: initializer),
    );
    final result = await repo.getProducts();

    debugPrint(">> t1 res: ${result.toString().substring(0, 20)}");
    expect(result, isList);
    debugPrint(">> t1 item: ${result.first}");
  });

  test('should use cache', () async {
    MealClientRepository repo = MealClientRepository(
      MealUnoApiClient(initializer: initializer),
    );
    final result = await repo.getProductsWithCache();

    debugPrint(">> t2 res: ${result.toString().substring(0, 20)}");

    expect(result, isList);
    debugPrint(">> t2 item: ${result.first}");
  });

  test('should get cache when error', () async {
    MealClientRepository repo = MealClientRepository(
      MealUnoApiClient(initializer: initializer),
    );
    final result = await repo.getProductFromCacheOnError();

    debugPrint(">> t3 res: ${result.toString().substring(0, 20)}");

    expect(result, isList);
    debugPrint(">> t3 item: ${result.first}");
  });
}
