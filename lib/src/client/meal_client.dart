import 'package:flutter/material.dart';
import 'package:meal_client/src/client/configs/meal_client_initializer.dart';
import 'package:meal_client/src/utils/memory_enum_keys.dart';
import 'package:retry/retry.dart';
import 'package:uno/uno.dart';

import '../models/meal_errors_model.dart';
import '../utils/response_types_enum.dart';

extension DurationConverter on int {
  Duration get milliseconds => Duration(seconds: this);
  Duration get seconds => Duration(seconds: this);
  Duration get minutes => Duration(minutes: this);
  Duration get hours => Duration(hours: this);
}

class MealClient {
  final MealClientInitializer initializer;
  MealClient({required this.initializer});

  static const int defaultRetryAmount = 3;
  static const int defaultTimeoutDuration = 5;

  Future<Target?> getMethod<Target>(
    String route, {
    Map<String, String>? headers,
    String exportKey = 'data',
    ResponseTypesEnum responseType = ResponseTypesEnum.json,
    bool enableWorkMemory = false,
    bool enableLongTermMemory = false,
  }) async {
    try {
      final start = DateTime.now();
      final response = await retry<Response>(
        () async {
          if (route.startsWith('http')) {
            ///complete route
            return initializer.customInit().get(
                  route,
                  headers: headers ?? {},
                  timeout: defaultTimeoutDuration.seconds,
                );
          } else {
            ///just end point
            return initializer().get(
              route,
              headers: headers ?? {},
              timeout: defaultTimeoutDuration.seconds,
            );
          }
        },
        maxAttempts: defaultRetryAmount,
      );

      debugPrint(
        '[$route]>> total time= \n${start.difference(DateTime.now())}\n\n',
      );

      final exportedData = _exportObjectData(response, exportKey);
      if (Target != dynamic) {
        if (Target == exportedData.runtimeType) {
          ///compare type before return
          throw ResponseError(
            statusCode: 404,
            message: '${exportedData.runtimeType} is not expected type $Target',
          );
        } else {
          return exportedData;
        }
      } else {
        return exportedData;
      }
    } catch (e) {
      if (e is UnoError) {
        if (e.request?.uri != null) {
          final cacheData = await _handleCache(e.request!.uri);

          if (cacheData != null) return cacheData;
        }
        debugPrint('[getMethod]>> error on GET $e');

        throw ResponseError(
          statusCode: e.response?.status,
          message: "error on GET $e",
        );
      } else {
        throw InternalError(
          message: "error on GET $e",
        );
      }
    }
  }

  dynamic _handleCache(Uri uri, {bool isWorkMemory = false}) async {
    try {
      final cacheData = await uri.memoryGet;

      if (cacheData == null) return;

      final currentTime = DateTime.now();
      final maxDuration = isWorkMemory ? 5.minutes : 8.hours;

      if (currentTime.difference(cacheData.creationDate) <= maxDuration) {
        return cacheData.value;
      } else {
        await uri.memoryRemove;
      }
    } catch (e) {
      debugPrint('[_handleCache]>> $e');
      throw MemoryError(message: '[_handleCache] $e');
    }
  }

  dynamic _exportObjectData(dynamic object, String exportKey) {
    ///not common object data, return all data
    if (exportKey.isEmpty) return object;

    ///normally response.data['data']
    if (object is Map && object.containsKey(exportKey)) {
      return object[exportKey];
    }

    ///cant find key means response has errors
    debugPrint(
      "[MealCliUtils] >> object ${object.toString().substring(0, 10)} NOT contais exportKey $exportKey",
    );

    throw MemoryError(message: '[MealCliUtils] $object');
  }
}
