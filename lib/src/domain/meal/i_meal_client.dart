import 'package:uno/uno.dart';

abstract class IMealClient {
  getMethod(
    String url, {
    Map<String, String>? headers,
    ResponseType? responseType,
    bool enableCache = false,
    String defaultSelector = 'data',
  });
  postMethod(
    String url,
    dynamic data, {
    Map<String, String>? headers,
    ResponseType? responseType,
    String defaultSelector = 'data',
  });
}
