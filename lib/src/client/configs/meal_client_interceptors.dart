import 'package:flutter/material.dart';
import 'package:meal_client/src/models/meal_errors_model.dart';
import 'package:meal_client/src/utils/memory_enum_keys.dart';
import 'package:uno/uno.dart';

import 'meal_api_auth.dart';

class MealClientInterceptors {
  MealApiAuth? authenticator;
  MealClientInterceptors({required this.authenticator});

  Response onResponse(Response response) {
    if (response.request.method == 'get') {
      //save on database in different thread
      response.request.uri.memoryAdd(response.data);
    }
    return response;
  }

  Future<Request> onRequest(Request request) async {
    if ((request.headers.isEmpty || request.method != 'get') &&
        authenticator != null) {
      final token = await authenticator!.authProcess();
      if (token == null) {
        debugPrint("[MealCli] >> recived [null token], continue without add");
      } else {
        request.headers.addAll({'Authorization': 'Bearer $token'});
      }
    }

    return request;
  }

  void onError(error) {
    if (error is UnoError) {
      throw ResponseError(
        statusCode: error.response?.status,
        message: 'Interceptor $error',
      );
    } else {
      throw InternalError(message: 'Interceptor $error');
    }
  }
}
