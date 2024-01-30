import 'package:meal_client/src/core/request_options.dart';

import 'meal_response_model.dart';

abstract class HttpInterface {
  Future<MealResponseModel<T>> get<T>(
    String route,
    MealRequestOptions options,
  );
  Future<MealResponseModel<T>> post<T>(
    String route,
    MealRequestOptions options,
  );
  Future<MealResponseModel<T>> put<T>(
    String route,
    MealRequestOptions options,
  );
  Future<MealResponseModel<T>> delete<T>(
    String route,
    MealRequestOptions options,
  );
}
