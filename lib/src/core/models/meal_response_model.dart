// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:meal_client/src/core/constants.dart';

class MealResponseModel<T> {
  final KStatusEnum status;
  final String message;
  final T data;

  MealResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });
}
