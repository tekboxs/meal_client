import 'package:meal_client/src/core/models/http_interface_model.dart';
import 'package:meal_client/src/core/models/meal_response_model.dart';

class MealHttpService implements HttpInterface {
  @override
  Future<MealResponseModel<T>> delete<T>() {
    throw UnimplementedError();
  }

  @override
  Future<MealResponseModel<T>> get<T>() {
    throw UnimplementedError();
  }

  @override
  Future<MealResponseModel<T>> post<T>() {
    throw UnimplementedError();
  }

  @override
  Future<MealResponseModel<T>> put<T>() {
    throw UnimplementedError();
  }
}
