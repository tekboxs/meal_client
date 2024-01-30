// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:meal_client/src/client/meal_auth_service.dart';
import 'package:meal_client/src/client/meal_http_service.dart';
import 'package:meal_client/src/client/meal_interceptors_service.dart';
import 'package:meal_client/src/core/constants.dart';
import 'package:meal_client/src/core/initialization_options.dart';
import 'package:meal_client/src/core/models/meal_response_model.dart';
import 'package:meal_client/src/core/request_options.dart';

class MealClient {
  final MealInterceptorsService interceptorsService;
  final MealHttpService httpService;
  final MealAuthService authService;
  final InitializationOptions options;

  MealClient({
    required this.interceptorsService,
    required this.httpService,
    required this.authService,
    required this.options,
  });

  Future<MealResponseModel<T>> getMethod<T>(
    String route, {
    MealRequestOptions? requestOptions,
  }) async {
    if (options.$conversor != null) {}

    return MealResponseModel(
      status: KStatusEnum.ok.getStatus,
      message: 'message',
      data: {} as T,
    );
  }
}
