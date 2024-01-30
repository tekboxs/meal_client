import 'package:dio/dio.dart';
import 'package:meal_client/src/core/models/http_interface_model.dart';
import 'package:meal_client/src/core/models/meal_response_model.dart';
import 'package:meal_client/src/core/request_options.dart';

class MealHttpService implements HttpInterface {
  final Dio _dio = Dio();

  @override
  Future<MealResponseModel<T>> get<T>(
    String route,
    MealRequestOptions options,
  ) async {
    final response = await _dio.get(
      route,
      options: Options(headers: options.headers),
    );

    return MealResponseModel(
      status: response.statusCode,
      message: 'message',
      data: response.data,
    );
  }

  @override
  Future<MealResponseModel<T>> delete<T>(
    String route,
    MealRequestOptions options,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<MealResponseModel<T>> post<T>(
    String route,
    MealRequestOptions options,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<MealResponseModel<T>> put<T>(
    String route,
    MealRequestOptions options,
  ) {
    throw UnimplementedError();
  }
}
