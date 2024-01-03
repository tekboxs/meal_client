// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CacheModel {
  late DateTime creationDate;
  final dynamic value;

  CacheModel({required this.value, DateTime? creation}) {
    creationDate = creation ?? DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'creationDate': creationDate.millisecondsSinceEpoch,
      'value': value,
    };
  }

  factory CacheModel.fromMap(Map<String, dynamic> map) {
    return CacheModel(
      creation: DateTime.fromMillisecondsSinceEpoch(map['creationDate'] as int),
      value: map['value'] as dynamic,
    );
  }

  factory CacheModel.fromJson(String source) =>
      CacheModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => json.encode(toMap());

  CacheModel copyWith({
    DateTime? creationDate,
    dynamic value,
  }) {
    return CacheModel(
      creation: creationDate ?? this.creationDate,
      value: value ?? this.value,
    );
  }
}
