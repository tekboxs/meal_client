// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CacheModel {
  final DateTime creationDate;
  final dynamic value;

  CacheModel({required this.creationDate, required this.value});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'creationDate': creationDate.millisecondsSinceEpoch,
      'value': value,
    };
  }

  factory CacheModel.fromMap(Map<String, dynamic> map) {
    return CacheModel(
      creationDate:
          DateTime.fromMillisecondsSinceEpoch(map['creationDate'] as int),
      value: map['value'] as dynamic,
    );
  }

  factory CacheModel.fromJson(String source) =>
      CacheModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => json.encode(toMap());
}
