import 'package:flutter/material.dart';
import 'package:meal_client/src/data/meal/meal_db_adapter.dart';
import 'package:retry/retry.dart';
import 'package:uno/uno.dart';

import '../../domain/meal/i_meal_client.dart';
import '../../domain/data_base/i_meal_db_adpter.dart';
import 'meal_uno_initializer.dart';

part 'meal_api_utils.dart';

enum MealClientError { notFound, invalidResponse, auth, cantSendData }

class MealUnoApiClient extends MealUnoApiUtils implements IMealClient {
  final MealUnoInitializer initializer;

  MealUnoApiClient({required this.initializer});

  static const int defaultRetryAmount = 2;
  static const int defaultTimeoutDuration = 2;

  ///[exportKey] used to expose contents of constant key
  @override
  Future getMethod(
    String url, {
    Map<String, String>? headers,
    ResponseType? responseType,
    String exportKey = 'data',
    bool disableCacheOnError = false,
  }) async {
    try {
      Response response = await retry<Response>(
        () {
          if (url.startsWith('http')) {
            ///recived full url
            return initializer.customInit().get(
                  url,
                  responseType: responseType ?? ResponseType.json,
                  headers: headers ?? {},
                  timeout: const Duration(seconds: defaultTimeoutDuration),
                );
          } else {
            ///recived only end-point
            return initializer().get(
              url,
              responseType: responseType ?? ResponseType.json,
              headers: headers ?? {},
              timeout: const Duration(seconds: defaultTimeoutDuration),
            );
          }
        },
        maxAttempts: defaultRetryAmount,
      );
      return _exportObjectData(response.data, exportKey);
    } catch (e) {
      if (disableCacheOnError) {
        debugPrint(
          "\n\n[MealCli] >>WARNING cache disabled on error\nError: $e\n\n",
        );
        throw MealClientError.notFound;
      }

      ///merge urls to get full address
      final cachedData = await _handleCache(initializer.baseUrl + url);
      if (cachedData != null) {
        debugPrint("\n\n[MealCli] >>WARNING reponse from cache\nError: $e\n\n");
        return _exportObjectData(cachedData, exportKey);
      }

      ///at this point have not response or cache

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
    String exportKey = 'data',
    ResponseType? responseType,
  }) async {
    Response response = await retry<Response>(() async {
      if (url.startsWith('http|https')) {
        ///recived full url
        return await initializer.customInit().post(
              url,
              data: data,
              headers: headers ?? {},
              timeout: const Duration(seconds: defaultTimeoutDuration * 2),
              responseType: responseType ?? ResponseType.json,
            );
      } else {
        ///recived only end-point
        return await initializer().post(
          url,
          data: data,
          headers: headers ?? {},
          responseType: responseType ?? ResponseType.json,
        );
      }
    });

    return _exportObjectData(response.data, exportKey);
  }

  @override
  deleteMethod(
    String url, {
    Map<String, String>? headers,
    ResponseType? responseType,
    bool ignoreResponse = true,
    String exportKey = 'data',
  }) async {
    Response response = await retry<Response>(() async {
      if (url.startsWith('http|https')) {
        ///recived full url
        return await initializer.customInit().delete(
              url,
              headers: headers ?? {},
              timeout: const Duration(seconds: defaultTimeoutDuration * 2),
              responseType: responseType ?? ResponseType.json,
            );
      } else {
        ///recived only end-point
        return await initializer().delete(
          url,
          headers: headers ?? {},
          responseType: responseType ?? ResponseType.json,
        );
      }
    });

    return _exportObjectData(response.data, exportKey);
  }

  @override
  putMethod(String url, data,
      {Map<String, String>? headers,
      ResponseType? responseType,
      bool ignoreResponse = true,
      String exportKey = 'data'}) async {
    try {
      Response response = await retry<Response>(() async {
        if (url.startsWith('http|https')) {
          ///recived full url
          return await initializer.customInit().put(
                url,
                data: data,
                headers: headers ?? {},
                timeout: const Duration(seconds: defaultTimeoutDuration * 2),
                responseType: responseType ?? ResponseType.json,
              );
        } else {
          ///recived only end-point
          return await initializer().put(
            url,
            data: data,
            headers: headers ?? {},
            responseType: responseType ?? ResponseType.json,
          );
        }
      });

      return _exportObjectData(response.data, exportKey);
    } catch (e) {
      debugPrint("\n\n>>[MealClient] cant send PUT$e\n\n");
      throw MealClientError.cantSendData;
    }
  }
}
