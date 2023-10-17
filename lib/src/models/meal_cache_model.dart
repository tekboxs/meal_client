// ignore_for_file: public_member_api_docs, sort_constructors_first
class MealCacheModel {
  final DateTime creation;
  final dynamic data;

  MealCacheModel({
    required this.creation,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'creation': creation.millisecondsSinceEpoch,
      'data': data,
    };
  }

  factory MealCacheModel.fromMap(Map<String, dynamic> map) {
    return MealCacheModel(
      creation: DateTime.fromMillisecondsSinceEpoch(map['creation'] as int),
      data: map['data'] as dynamic,
    );
  }

  MealCacheModel copyWith({
    DateTime? creation,
    dynamic data,
  }) {
    return MealCacheModel(
      creation: creation ?? this.creation,
      data: data ?? this.data,
    );
  }
}
