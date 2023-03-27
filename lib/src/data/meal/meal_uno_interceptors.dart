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
      adapter.save(response.request.uri, response.data);
    }
    return response;
  }

  onRequest(Request request) async {
    if (request.headers.isEmpty && authenticator != null) {
      //delegate to client
      final authResponse = await authenticator!.getToken();
      if (authResponse is MealClientError) {
        debugPrint("[MealCli] >>  auth fail!!");
      } else {
        request.headers.addAll(authResponse);
      }
    }

    return request;
  }

  onError(error) {
    // implementação do interceptor de erro
  }
}
