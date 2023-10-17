// ignore_for_file: public_member_api_docs, sort_constructors_first
class MealReponseModel {
  final dynamic data;
  final String? route;
  final DateTime? executionTime;

  MealReponseModel({
    required this.data,
    this.route,
    this.executionTime,
  });

  get unWarp => data;
}
