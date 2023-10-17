import 'package:uno/uno.dart';

import 'meal_client_interceptors.dart';

class MealClientInitializer {
  final String baseUrl;
  final MealClientInterceptors interceptors;
  MealClientInitializer(this.baseUrl, this.interceptors);

  Uno call() => Uno(baseURL: baseUrl)
    ..interceptors.response.use(
          (p0) => interceptors.onResponse(p0),
          onError: interceptors.onError,
        )
    ..interceptors.request.use(
          (p0) async => await interceptors.onRequest(p0),
          onError: interceptors.onError,
        );

  Uno customInit() => Uno()
    ..interceptors.request.use(
          (p0) async => await interceptors.onRequest(p0),
          onError: interceptors.onError,
        );
}
