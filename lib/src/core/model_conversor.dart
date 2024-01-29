// ignore_for_file: public_member_api_docs, sort_constructors_first

class ModelConversor<T> {
  T Function(Map<String, dynamic> item)? fromMap;

  List<T> call(rawData) {
    return [];
  }
}
