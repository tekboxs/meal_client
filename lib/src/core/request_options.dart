// ignore_for_file: public_member_api_docs, sort_constructors_first

class MealRequestOptions<T> {
  final dynamic dataToSend;
  final Map<String, String>? headers;
  final Function(List<T>)? onMemory;
  final bool? shouldExportJson;
  final bool? ignoreResponse;
  final bool? enableFastCacheMemory;

  MealRequestOptions({
    this.dataToSend,
    this.headers,
    this.onMemory,
    this.shouldExportJson,
    this.ignoreResponse,
    this.enableFastCacheMemory,
  });
}
