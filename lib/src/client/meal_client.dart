import 'package:meal_client/src/client/meal_auth_service.dart';
import 'package:meal_client/src/client/meal_http_service.dart';
import 'package:meal_client/src/client/meal_interceptors_service.dart';

class MealClient {
  final MealInterceptorsService interceptorsService;
  final MealHttpService httpService;
  final MealAuthService authService;

  MealClient(
    this.authService,
    this.interceptorsService,
    this.httpService,
  );
}
