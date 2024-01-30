// ignore_for_file: public_member_api_docs, sort_constructors_first

class MealResponseModel<T> {
  final int? status;
  final String message;
  final T? data;
  final List<T>? dataList;
  final dynamic rawData;

  MealResponseModel({
    required this.status,
    required this.message,
    this.data,
    this.dataList,
    this.rawData,
  });

  MealResponseModel<T> copyWith({
    int? status,
    String? message,
    T? data,
    List<T>? dataList,
    dynamic rawData,
  }) {
    return MealResponseModel<T>(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
      dataList: dataList ?? this.dataList,
      rawData: rawData ?? this.rawData,
    );
  }
}
