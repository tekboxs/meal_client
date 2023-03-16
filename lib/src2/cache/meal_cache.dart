// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:meal_client/src2/data/storage.dart';

class MealCacheModel {
  final dynamic content;
  final DateTime duration;

  MealCacheModel({
    required this.content,
    required this.duration,
  });

  Map<String, dynamic> toMap([String? customDuration]) {
    return <String, dynamic>{
      'content': content,
      'duration': customDuration ?? duration.toString(),
    };
  }

  static DateTime _parseDurationString(String rawDuration) {
    return DateTime.parse(rawDuration.replaceAll(' ', 'T'));
  }

  factory MealCacheModel.fromMap(Map<String, dynamic> map) {
    return MealCacheModel(
      content: map['content'] as dynamic,
      duration: _parseDurationString(map['duration']),
    );
  }

  String toJson() => json.encode(toMap());
  String toJsonWithDuration(String customDuration) =>
      json.encode(toMap(customDuration));

  factory MealCacheModel.fromJson(String source) =>
      MealCacheModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

abstract class MealHttpCache {
  final Duration cacheDuration;
  MealHttpCache({this.cacheDuration = const Duration(hours: 4)});
  Future<bool> writeRequestData(String key, dynamic content) async {
    try {
      MealCacheModel localModel = MealCacheModel(
          content: content, duration: DateTime.now().add(cacheDuration));
      String _content = localModel.toJson();
      await Storage.write(key, _content);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future getRequestData(String key) async {
    try {
      var rawMemory = await Storage.read(key) as String?;

      if (rawMemory == null) return null;
      MealCacheModel memory = MealCacheModel.fromJson(rawMemory);

      if (DateTime.now().isBefore(memory.duration)) {
        return memory.content;
      } else {
        //expired data
        await removeRequestCache(key);
        return null;
      }
    } catch (e) {
      throw e;
    }
  }

  Future<bool> removeRequestCache(String key) async {
    await Storage.remove(key);
    return true;
  }
}
