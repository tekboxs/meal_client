import 'package:uno/uno.dart';

abstract class IMealClient {
  getMethod(
    String url, {
    Map<String, String>? headers,
    ResponseType? responseType,
    bool enableCache = false,
  });
  postMethod(
    String url,
    dynamic data, {
    Map<String, String>? headers,
    ResponseType? responseType,
  });
}
