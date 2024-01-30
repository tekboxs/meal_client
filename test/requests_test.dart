import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:meal_client/src/client/meal_auth_service.dart';
import 'package:meal_client/src/client/meal_client.dart';
import 'package:meal_client/src/client/meal_http_service.dart';
import 'package:meal_client/src/client/meal_interceptors_service.dart';
import 'package:meal_client/src/core/initialization_options.dart';

import 'keys.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final auth = MealAuthService();

  final initialization = InitializationOptions(
    baseUrl: baseUrl,
  );

  final http = MealHttpService();

  final interceptors = MealInterceptorsService();

  final client = MealClient(
    interceptorsService: interceptors,
    httpService: http,
    authService: auth,
    options: initialization,
  );
  final getIt = GetIt.instance;

  getIt.registerSingleton(client);
}
