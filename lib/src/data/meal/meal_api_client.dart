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

  _defaultSelection(Response? response, String defaultSelector, {cacheData}) {
    if (response != null && response.data is Map) {
      if ((response.data as Map).containsKey(defaultSelector)) {
        return response.data[defaultSelector];
      }
    }

    if (cacheData != null && cacheData is Map) {
      if (cacheData.containsKey(defaultSelector)) {
        return cacheData[defaultSelector];
      }
    }
    debugPrint("[MealCli] >> default key not found");
    return response?.data ?? cacheData ?? MealClientError.invalidResponse;
  }

  _cacheHandle(url) async {
    if (url == null) return;
    final data = await adapter.read(Uri.parse(url), ignoreCache: false);

    if (data != null) {
      //if not errors mean key is valid
      debugPrint("[MealCli] >>  send data from cache");

      return data;
    }
    return;
  }

  ///[defaultSelector] used to expose contents of constant key
  @override
  Future getMethod(
    String url, {
    Map<String, String>? headers,
    ResponseType? responseType,
    String defaultSelector = 'data',
    bool enableCache = false,
  }) async {
    String completeUrl = '';
    if (!url.startsWith('http')) {
      completeUrl = initializer.baseUrl + url;
    } else {
      completeUrl = url;
    }

    // Cache verification
    if (enableCache) {
      final cachedData = await _cacheHandle(completeUrl);
      if (cachedData != null && cachedData is! MealDataBaseError) {
        return _defaultSelection(
          null,
          defaultSelector,
          cacheData: cachedData,
        );
      }
    }
    try {
      final Response? response;
      if (url.startsWith('http')) {
        response = await retry(
          () => initializer.customInit().get(
                url,
                responseType: responseType ?? ResponseType.json,
                headers: headers ?? {},
                timeout: const Duration(seconds: 5),
              ),
          maxAttempts: 2,
        );
      } else {
        response = await retry(
          () => initializer().get(
            url,
            responseType: responseType ?? ResponseType.json,
            headers: headers ?? {},
            timeout: const Duration(seconds: 5),
          ),
          maxAttempts: 2,
        );
      }

      // Response handling
      if (defaultSelector.isNotEmpty) {
        return _defaultSelection(response, defaultSelector);
      } else {
        return response?.data;
      }
    } catch (e) {
      final cachedData = await _cacheHandle(initializer.baseUrl + url);
      if (cachedData != null && cachedData is! MealDataBaseError) {
        return _defaultSelection(
          null,
          defaultSelector,
          cacheData: cachedData,
        );
      }

      if (e is UnoError) {
        debugPrint("[MealCli] >> Error NOT FOUND\n${e.data}");
      } else {
        debugPrint("[MealCli] >> INTERNAL ERROR \n$e");
      }

      throw MealClientError.notFound;
    }
  }

  @override
  postMethod(
    String url,
    data, {
    Map<String, String>? headers,
    String defaultSelector = 'data',
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
