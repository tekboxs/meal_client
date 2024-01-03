// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:db_commons/db_commons.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:meal_client/meal_client.dart' hide MealClientDBAdapter;
import 'package:uno/uno.dart';

const kDefaultErrorMessage =
    'Houve um erro inesperado, caso persistir contate o Gerente.';
const kDefaultConnectionMessage =
    'Verifique sua conexão, se o erro persistir contate o Gerente.';
const kDefaultGenericConnectonMessage =
    'Houve um erro de conexão por favor tente novamente.';

bool isSubtype<T1, T2>() => <T1>[] is List<T2>;
typedef JsonList = List<Map<String, dynamic>>;
typedef Json = Map<String, dynamic>;

class RequestOptions<T> {
  final dynamic dataToSend;
  final String? exportKey;
  final Map<String, String>? headers;
  final bool? ignoreResponse;
  final T Function(Json item)? fromMap;
  final Function(List<T>)? onMemory;
  final bool? enableWorkMemory;
  final ResponseType? responseType;
  RequestOptions({
    this.dataToSend,
    this.exportKey,
    this.headers,
    this.ignoreResponse,
    this.fromMap,
    this.onMemory,
    this.enableWorkMemory,
    this.responseType,
  });
}

extension EndPoint on String {
  Future<List<R>?> put<R>({required RequestOptions<R> options}) async {
    final client = GetIt.I.get<IMealClient>();

    Future clientMethod() => client.putMethod(
          this,
          options.dataToSend,
          responseType: options.responseType,
          exportKey: options.exportKey ?? 'data',
          ignoreResponse: options.ignoreResponse ?? true,
          headers: options.headers,
        );

    return await _request(options: options, clientMethod: clientMethod);
  }

  Future<List<R>?> delete<R>({RequestOptions<R>? options}) async {
    final client = GetIt.I.get<IMealClient>();

    Future clientMethod() => client.deleteMethod(
          this,
          responseType: options?.responseType,
          exportKey: options?.exportKey ?? 'data',
          ignoreResponse: options?.ignoreResponse ?? true,
          headers: options?.headers,
        );

    return await _request(options: options, clientMethod: clientMethod);
  }

  Future<List<R>?> post<R>({required RequestOptions<R> options}) async {
    final client = GetIt.I.get<IMealClient>();

    Future clientMethod() => client.postMethod(
          this,
          options.dataToSend,
          responseType: options.responseType,
          exportKey: options.exportKey ?? 'data',
          ignoreResponse: options.ignoreResponse ?? true,
          headers: options.headers,
        );

    return await _request(options: options, clientMethod: clientMethod);
  }

  Future<List<R>> get<R>({RequestOptions<R>? options}) async {
    final client = GetIt.I.get<IMealClient>();

    Future clientMethod() => client.getMethod(
          this,
          exportKey: options?.exportKey ?? 'data',
          headers: options?.headers,
          responseType: options?.responseType,
          enableWorkMemory: options?.enableWorkMemory ?? false,
        );

    return await _request(options: options, clientMethod: clientMethod) ?? [];
  }

  Future<List<R>?> _request<R>({
    required Future Function() clientMethod,
    RequestOptions<R>? options,
  }) async {
    final handler = HandleRequestResponse<R>();
    try {
      throwIf(
        await Connectivity().checkConnectivity() == ConnectivityResult.none,
        Exception('No connection'),
      );

      final data = await clientMethod();
      return handler.convertTypes(data, options?.fromMap);
    } catch (e) {
      if (e is RequestError) rethrow;
      return await handler.readMemoryBeforeError(e, options?.onMemory);
    }
  }
}

class HandleRequestResponse<R> {
  List<R> convertTypes(
    dynamic data,
    R Function(Map<String, dynamic> item)? fromMap,
  ) {
    if (isSubtype<R, JsonList>() || isSubtype<R, Json>()) {
      return data;
    }

    if (fromMap != null) {
      if (data is List) {
        return data.map<R>((e) => fromMap(e)).toList();
      } else {
        return [fromMap(data)];
      }
    }

    debugPrint('[handle]>> return data as special type ${data.runtimeType}');
    if (data is List<R>) return data;

    return [data];
  }

  Future<List<R>> readMemoryBeforeError(e, onMemory) async {
    //try memory before error
    if (!isSubtype<R, JsonList>() && !isSubtype<R, Json>()) {
      final memory2 = HiveCustomService<R>(
        boxName:
            '${R.toString()[0].toLowerCase() + R.toString().substring(1)}-offline',
      );
      final data2 = await memory2.getAllItems();
      if (data2.isNotEmpty) {
        debugPrint('[memoryHandle]>> WARNING \n$this\n from memory ---->');
        return onMemory?.call(data2) ?? data2;
      }
    }

    throw ConnectionError(
      message: kDefaultConnectionMessage,
      debugMessage: e.toString(),
    );
  }
}

class RequestError {
  final String? message;
  final String? debugMessage;

  RequestError({
    this.message,
    this.debugMessage,
  });
}

class ConnectionError {
  final String? message;
  final String? debugMessage;

  ConnectionError({
    this.message,
    this.debugMessage,
  });
}

class TypeConversionError {
  final String? message;
  final String? debugMessage;

  TypeConversionError({
    this.message,
    this.debugMessage,
  });
}
