import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'autenticator.dart';
import 'client_keys.dart';

class APIClientInterceptors extends Interceptor {
  APIAuthenticator authenticator = APIAuthenticator();

  final Dio _client;
  final Function(String message)? onErrorDialog;
  APIClientInterceptors(
    Dio client,
    this.onErrorDialog,
  ) : _client = client;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.addAll({
      "Content-Type": "application/json",
    });

    if (!options.headers.containsKey('Authorization')) {
      final token = await authenticator.getToken();
      if (token == null) {
        debugPrint(
          "[Interceptor] >> recived [null token], continue without add",
        );
      } else {
        options.headers.addAll({
          "Authorization": "Bearer $token",
        });
      }
    }

    return super.onRequest(options, handler);
  }

  final int _attempts = 0;

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    await ClientKeys.token.remove;
    // if (err.response?.statusCode == 500 || err.response?.statusCode == 401) {
    //   if (_attempts < 2) {
    //     // Retry the request.
    //     try {
    //       await ClientKeys.token.remove;
    //       await Future.delayed(const Duration(milliseconds: 300));
    //       handler.resolve(await _retry(err.requestOptions));
    //       _attempts++;
    //     } on DioException catch (e) {
    //       if (_attempts < 2) {
    //         // If the request fails again, pass the error to the next interceptor in the chain.
    //         handler.next(e);
    //       } else {
    //         // If the request fails again and we have already tried twice, call the error dialog function.
    //         if (onErrorDialog != null) {
    //           onErrorDialog?.call(err.message ?? 'Erro desconhecido');
    //         }
    //       }
    //     }
    //     // Return to prevent the next interceptor in the chain from being executed.
    //     return;
    //   }
    // }

    // Pass the error to the next interceptor in the chain.
    handler.next(err);
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    // Create a new `RequestOptions` object with the same method, path, data, and query parameters as the original request.
    final token = await authenticator.getToken();

    final options = Options(
      method: requestOptions.method,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    // Retry the request with the new `RequestOptions` object.
    return _client.request<dynamic>(requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options);
  }
}
