import 'package:flutter/material.dart';
import 'package:meal_client/src/data/meal/meal_db_adapter.dart';
import 'package:retry/retry.dart';
import 'package:uno/uno.dart';

import '../../domain/meal/i_meal_client.dart';
import '../../domain/meal/i_meal_db_adpter.dart';
import 'meal_uno_initializer.dart';

class MealUnoApiClient implements IMealClient {
  final MealUnoInitializer initializer;
  IMealDBAdpter adapter = MealClientDBAdapter();

  MealUnoApiClient({required this.initializer});

  _defaultSelection(Response response, String defaultKeySelector) {
    if (response.data is Map) {
      if ((response.data as Map).containsKey(defaultKeySelector)) {
        return response.data[defaultKeySelector];
      }
    }
    debugPrint(">>default key not found");
    return response.data;
  }

  _cacheHandle(url) async {
    final data = await adapter.read(Uri.parse(url), ignoreCache: false);

    if (data is! MealDataBaseError) {
      //if not errors mean key is valid
      debugPrint(">> send data from cache");
      return data;
    }
    return;
  }

  ///[defaultKeySelector] used to expose contents of constant key
  @override
  Future getMethod(
    String url, {
    Map<String, String>? headers,
    ResponseType? responseType,
    String defaultKeySelector = 'data',
    bool enableCache = false,
  }) async {
    // Cache verification
    if (enableCache) {
      final cachedData = await _cacheHandle(url);
      if (cachedData != null && cachedData is! MealDataBaseError) {
        return cachedData;
      }
    }

    // HTTP request
    final response = await retry(
      () => initializer()
          .get(
            url,
            responseType: responseType ?? ResponseType.json,
            headers: headers ?? {},
          )
          .timeout(const Duration(seconds: 5)),
    );

    // Response handling
    if (defaultKeySelector.isNotEmpty) {
      return _defaultSelection(response, defaultKeySelector);
    } else {
      return response.data;
    }
  }

  @override
  postMethod(
    String url,
    data, {
    Map<String, String>? headers,
    ResponseType? responseType,
  }) async {
    return await initializer().post(
      url,
      data: data,
      headers: headers ?? {},
      responseType: responseType ?? ResponseType.json,
    );
  }
}
