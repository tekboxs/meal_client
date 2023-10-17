import 'package:flutter/material.dart';
import 'package:meal_client/meal_client.dart';
import 'package:uno/uno.dart';

class MealUnoInterceptors {
  MealAuthenticator? authenticator;
  MealClientDBAdapter adapter = MealClientDBAdapter();
  MealUnoInterceptors({required this.authenticator});

  onResponse(Response response) {
    if (response.request.method == 'get') {
      //save on database in different thread
      adapter.adapterSaveMethod(response.request.uri, response.data);
    }
    return response;
  }

  onRequest(Request request) async {
    if ((request.headers.isEmpty || request.method != 'get') &&
        authenticator != null) {
      //delegate to client
      final token = await authenticator!.getToken();
      if (token == null) {
        debugPrint("[MealCli] >> recived [null token], continue without add");
      } else {
        request.headers.addAll({'Authorization': 'Bearer $token'});
      }
    }

    return request;
  }

  onError(error) {
    // implementação do interceptor de erro
  }
}
