import 'package:flutter/material.dart';
import 'package:meal_client/src/data/meal/meal_db_adapter.dart';
import 'package:retry/retry.dart';
import 'package:uno/uno.dart';

import '../../domain/meal/i_meal_client.dart';
import '../../domain/data_base/i_meal_db_adpter.dart';
import 'meal_uno_initializer.dart';

enum MealClientError { notFound, invalidResponse, auth }

class MealUnoApiClient implements IMealClient {
  final MealUnoInitializer initializer;
  IMealDBAdpter adapter = MealClientDBAdapter();

  MealUnoApiClient({required this.initializer});

  _defaultSelection(Response? response, String defaultKeySelector,
      {cacheData}) {
    if (response != null && response.data is Map) {
      if ((response.data as Map).containsKey(defaultKeySelector)) {
        return response.data[defaultKeySelector];
      }
    }

    if (cacheData != null && cacheData is Map) {
      if (cacheData.containsKey(defaultKeySelector)) {
        return cacheData[defaultKeySelector];
      }
    }
    debugPrint(">>default key not found");
    return response?.data ?? cacheData ?? MealClientError.invalidResponse;
  }

  _cacheHandle(url) async {
    if (url == null) return;
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
      final cachedData = await _cacheHandle(initializer.baseUrl + url);
      if (cachedData != null && cachedData is! MealDataBaseError) {
        return _defaultSelection(
          null,
          defaultKeySelector,
          cacheData: cachedData,
        );
      }
    }
    try {
      final response = await retry(
        () => initializer().get(
          url,
          responseType: responseType ?? ResponseType.json,
          headers: headers ?? {},
          timeout: const Duration(seconds: 5),
        ),
        maxAttempts: 3,
      );

      // Response handling
      if (defaultKeySelector.isNotEmpty) {
        return _defaultSelection(response, defaultKeySelector);
      } else {
        return response.data;
      }
    } catch (e) {
      final cachedData = await _cacheHandle(initializer.baseUrl + url);
      if (cachedData != null && cachedData is! MealDataBaseError) {
        return _defaultSelection(
          null,
          defaultKeySelector,
          cacheData: cachedData,
        );
      }
      return MealClientError.notFound;
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
