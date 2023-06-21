import 'package:flutter/material.dart';
import 'package:meal_client/src/data/meal/meal_db_adapter.dart';
import 'package:retry/retry.dart';
import 'package:uno/uno.dart';

import '../../domain/meal/i_meal_client.dart';

import 'meal_uno_initializer.dart';

part 'meal_api_utils.dart';

enum MealClientError {
  cantReciveData,
  cantSendData,
  cantExportData,
  unknow,
  emptyCache;
}

class MealUnoApiClient extends MealUnoApiUtils implements IMealClient {
  final MealUnoInitializer initializer;

  MealUnoApiClient({required this.initializer});

  static const int defaultRetryAmount = 3;
  static const int defaultTimeoutDuration = 5;

  ///[exportKey] used to expose contents of constant key
  @override
  Future getMethod(
    String url, {
    Map<String, String>? headers,
    ResponseType? responseType,
    String exportKey = 'data',
    bool disableCacheOnError = false,
    bool enableWorkMemory = true,
  }) async {
    try {
      ///return data instead of request
      if (enableWorkMemory) {
        dynamic urlKey;

        if (url.startsWith('http')) {
          urlKey = url;
        } else {
          urlKey = "${initializer.baseUrl}$url";
        }

        final memoryData = await _handleWorkCache(urlKey);
        if (memoryData != null) return _exportObjectData(memoryData, exportKey);
      }

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
          "\n\n[MealCli getMethod] >>WARNING cache disabled on error\nError: $e\n\n",
        );
        throw Exception(MealClientError.emptyCache);
      }

      final dynamic cachedData;

      if (url.startsWith('http')) {
        ///already full address
        cachedData = await _handleCache(url);
      } else {
        ///merge urls to get full address
        cachedData = await _handleCache(initializer.baseUrl + url);
      }

      if (cachedData != null) {
        debugPrint(
            "\n\n[MealCli getMethod] >>WARNING reponse from cache\nError: $e\n\n");
        return _exportObjectData(cachedData, exportKey);
      }

      ///at this point have not response or cache

      if (e is UnoError) {
        debugPrint("[MealCli getMethod] >> UNO ERROR \n${e.data}");
        throw Exception(MealClientError.cantReciveData);
      } else {
        debugPrint("[MealCli getMethod] >> INTERNAL ERROR \n$e");
        throw Exception(MealClientError.unknow);
      }
    }
  }

  @override
  postMethod(
    String url,
    data, {
    Map<String, String>? headers,
    String exportKey = 'data',
    ResponseType? responseType,
    bool ignoreResponse = true,
  }) async {
    try {
      Response response = await retry<Response>(
        () async {
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
              timeout: const Duration(seconds: defaultTimeoutDuration * 2),
              responseType: responseType ?? ResponseType.json,
            );
          }
        },
        maxAttempts: defaultRetryAmount,
      );

      if (!ignoreResponse) return _exportObjectData(response.data, exportKey);
    } catch (e) {
      debugPrint("\n\n[MealCli postMethod]>> $url cant send post $e\n\n");
      if (e is UnoError) {
        throw Exception(MealClientError.cantSendData);
      } else {
        throw Exception(MealClientError.unknow);
      }
    }
  }

  @override
  deleteMethod(
    String url, {
    Map<String, String>? headers,
    ResponseType? responseType,
    bool ignoreResponse = true,
    String exportKey = 'data',
  }) async {
    try {
      Response response = await retry<Response>(() async {
        if (url.startsWith('http')) {
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
            timeout: const Duration(seconds: defaultTimeoutDuration),
            responseType: responseType ?? ResponseType.json,
          );
        }
      }, maxAttempts: defaultRetryAmount);

      if (!ignoreResponse) return _exportObjectData(response.data, exportKey);
    } catch (e) {
      debugPrint("\n\n[MealCli deleteMethod]>> $url cant delete $e\n\n");
      if (e is UnoError) {
        throw Exception(MealClientError.cantSendData);
      } else {
        throw Exception(MealClientError.unknow);
      }
    }
  }

  @override
  putMethod(
    String url,
    data, {
    Map<String, String>? headers,
    ResponseType? responseType,
    bool ignoreResponse = true,
    String exportKey = 'data',
  }) async {
    try {
      Response response = await retry<Response>(
        () async {
          if (url.startsWith('http')) {
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
              timeout: const Duration(seconds: defaultTimeoutDuration),
              responseType: responseType ?? ResponseType.json,
            );
          }
        },
        maxAttempts: defaultRetryAmount,
      );

      if (!ignoreResponse) return _exportObjectData(response.data, exportKey);
    } catch (e) {
      debugPrint("\n\n>>[MealClient put] cant send PUT$e\n\n");
      if (e is UnoError) {
        throw Exception(MealClientError.cantSendData);
      } else {
        throw Exception(MealClientError.unknow);
      }
    }
  }
}
