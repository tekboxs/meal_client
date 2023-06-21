part of 'meal_api_client.dart';

class MealUnoApiUtils {
  MealClientDBAdapter adapter = MealClientDBAdapter();

  ///if [working memory] availble return instead of request
  ///have a small duration, used to avoid multiple request
  ///in short times
  dynamic _handleWorkCache(String url) async {
    final memoryItem = await adapter.read(
      Uri.parse(url),
      ignoreWorkCache: false,
    );

    return memoryItem;
  }

  dynamic _handleCache(String? url) async {
    if (url == null) return null;

    return await adapter.read(Uri.parse(url), ignoreCache: false);
  }

  dynamic _exportObjectData(dynamic object, String exportKey) {
    ///not common object data, return all data
    if (exportKey.isEmpty) return object;

    ///normally response.data['data']
    if (object is Map && object.containsKey(exportKey)) {
      return object[exportKey];
    }

    ///cant find key means response has errors
    debugPrint(
        "[MealCliUtils] >> object ${object.toString().substring(0, 10)} NOT contais exportKey $exportKey");
    throw Exception(MealClientError.cantExportData);
  }
}
