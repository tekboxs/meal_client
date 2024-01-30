// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:meal_client/src/client/meal_auth_service.dart';
import 'package:meal_client/src/client/meal_http_service.dart';
import 'package:meal_client/src/client/meal_interceptors_service.dart';
import 'package:meal_client/src/core/initialization_options.dart';
import 'package:meal_client/src/core/model_conversor.dart';
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

  MealResponseModel<T> _tryConvertBeforeReturn<T>(
    MealResponseModel<T> mealResponse,
  ) {
    if (options.$binds.isNotEmpty) {
      ModelConversor<T> conversor = ModelConversor<T>(options.$binds);
      final rawData = mealResponse.rawData;

      if (conversor.canConvert) {
        if (rawData is List) {
          final convertedData = rawData.map((e) => conversor.convert(e));

          mealResponse = mealResponse.copyWith(
            dataList: convertedData.toList(),
          );

          return mealResponse;
        }

        mealResponse = mealResponse.copyWith(
          data: conversor.convert(mealResponse.rawData),
        );

        return mealResponse;
      }
    }
    return mealResponse;
  }

  Future<MealResponseModel<T>> getMethod<T>(
    String route, {
    MealRequestOptions? requestOptions,
  }) async {
    requestOptions ??= MealRequestOptions();

    MealResponseModel<T> mealResponse = await httpService.get(
      route,
      requestOptions,
    );

    return _tryConvertBeforeReturn(mealResponse);
  }
}
