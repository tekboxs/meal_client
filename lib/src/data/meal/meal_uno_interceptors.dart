import 'package:meal_client/src/data/meal/meal_db_adapter.dart';
import 'package:uno/uno.dart';

import 'meal_authenticator.dart';

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
      request.headers.addAll(await authenticator!.getToken());
    }

    return request;
  }

  onError(error) {
    // implementação do interceptor de erro
  }
}
