// ignore_for_file: public_member_api_docs, sort_constructors_first

class MealResponseModel<T> {
  final int? status;
  final String message;
  final T data;

  MealResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });
}
