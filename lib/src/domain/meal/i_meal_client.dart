import 'package:uno/uno.dart';

abstract class IMealClient {
  getMethod(
    String url, {
    Map<String, String>? headers,
    ResponseType? responseType,
    bool disableCacheOnError = false,
    bool enableWorkMemory = false,
    String exportKey = 'data',
  });
  postMethod(
    String url,
    dynamic data, {
    Map<String, String>? headers,
    ResponseType? responseType,
    bool ignoreResponse = true,
    String exportKey = 'data',
  });
  putMethod(
    String url,
    dynamic data, {
    Map<String, String>? headers,
    ResponseType? responseType,
    bool ignoreResponse = true,
    String exportKey = 'data',
  });
  deleteMethod(
    String url, {
    Map<String, String>? headers,
    ResponseType? responseType,
    bool ignoreResponse = true,
    String exportKey = 'data',
  });
}
