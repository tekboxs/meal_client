part of 'meal_api_client.dart';

class MealUnoApiUtils {
  IMealDBAdpter adapter = MealClientDBAdapter();

  dynamic _handleCache(String? url) async {
    if (url == null) return null;
    debugPrint("\n\n[MealCli] >> check data from cache\n\n");

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
    debugPrint("[MealCliUtils] >> object NOT contais exportKey");
    throw MealClientError.invalidResponse;
  }
}
