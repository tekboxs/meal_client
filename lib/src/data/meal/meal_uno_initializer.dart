import 'package:uno/uno.dart';

import 'meal_uno_interceptors.dart';

class MealUnoInitializer {
  final String baseUrl;
  final MealUnoInterceptors interceptors;
  MealUnoInitializer(this.baseUrl, this.interceptors);

  Uno call() => Uno(baseURL: baseUrl)
    ..interceptors.response.use(
          (p0) => interceptors.onResponse(p0),
          onError: interceptors.onError,
        )
    ..interceptors.request.use(
          (p0) async => await interceptors.onRequest(p0),
          onError: interceptors.onError,
        );

  Uno customInit() => Uno();
}
