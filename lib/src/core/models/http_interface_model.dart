import 'meal_response_model.dart';

abstract class HttpInterface {
  Future<MealResponseModel<T>> get<T>();
  Future<MealResponseModel<T>> post<T>();
  Future<MealResponseModel<T>> put<T>();
  Future<MealResponseModel<T>> delete<T>();
}
