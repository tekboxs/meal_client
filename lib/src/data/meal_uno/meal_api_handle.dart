import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:meal_client/meal_client.dart';

import '../meal_errors.dart';

typedef MealRespose<T> = Future<Either<MealErrors, T>>;

class ApiHandler {
  final String route;
  final Map<String, String>? headers;
  final IMealClient client;
  final bool debugMode;
  final Duration debugFetchDuration;
  ApiHandler(
    this.route, {
    this.headers,
    required this.client,
    this.debugMode = kDebugMode,
    this.debugFetchDuration = const Duration(seconds: 1),
  });

  MealRespose<T> fetchData<T>({
    required T Function(dynamic data) castResult,
    bool Function(T)? isEmptyValidation,
    T Function(dynamic error)? onError,
    T Function()? onEmpty,
    Future<T> Function(T data)? onData,
    dynamic debugMockResponse,
    dynamic debugForceError,
  }) async {
    try {
      isEmptyValidation ??= (data) {
        if (data is List) {
          if (data.isEmpty) return true;
          return false;
        } else if (data is Map) {
          if (data.isEmpty) return true;
          return false;
        } else {
          throw Exception('$data is not a valid type ${data.runtimeType}');
        }
      };
      final dynamic data;
      if (debugMode) {
        await Future.delayed(debugFetchDuration);
        data = debugMockResponse;
        if (debugForceError != null) throw (Exception(debugForceError));
      } else {
        data = await client.getMethod(route, headers: headers);
      }

      if (data == null) {
        return onEmpty != null
            ? Right(onEmpty())
            : Left(MealErrors(errorKey: KDefaultErrors.emptyData));
      }

      if (isEmptyValidation(data)) {
        return onEmpty != null
            ? Right(onEmpty())
            : Left(MealErrors(errorKey: KDefaultErrors.emptyData));
      }
      if (onData != null) {
        return Right(await onData(castResult(data)));
      } else {
        return Right(castResult(data));
      }
    } catch (e) {
      return onError != null
          ? Right(onError(e))
          : Left(MealErrors(debugMessage: e));
    }
  }
}
