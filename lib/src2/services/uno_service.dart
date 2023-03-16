import 'dart:convert';

import 'package:uno/uno.dart';

import '../../meal_client.dart';
import '../interceptors/meal_http_interceptors.dart';

abstract class IMealHttpInitializer {
  init();
  customInit();
}

class MealUnoInitializer implements IMealHttpInitializer {
  final MealHttpInterceptors _interceptors;

  MealUnoInitializer(this._interceptors);
  @override
  customInit() => Uno();

  @override
  init() => Uno()
    ..interceptors.request.use(
          (request) => _interceptors.onRequest(request),
          onError: (error) => _interceptors.onError(error),
        )
    ..interceptors.response.use(
          (response) => _interceptors.onResponse(response),
          onError: (error) => _interceptors.onError(error),
        );
}

class MealUnoClient implements MealHttpService {
  final String _baseUrl;
  final IMealHttpInitializer _initializer;

  MealUnoClient(this._baseUrl, this._initializer);

  @override
  deleteRequest(
    url, {
    bool isBaseUrl = false,
    Map<String, String> headers = const {},
  }) async {
    String _requestUrl = !isBaseUrl ? "$_baseUrl${url}" : url;
    final _client =
        headers.isEmpty ? _initializer.init() : _initializer.customInit();
    Response response = await _client.delete(_requestUrl, headers: headers);

    return response.data;
  }

  ///[defaultSelector] to expose content from: ["data": {...}]
  @override
  getRequest(
    url, {
    bool isBaseUrl = false,
    Map<String, String> headers = const {},
    ResponseType responseType = ResponseType.json,
    String defaultSelector = 'data',
    bool enableCache = false,
  }) async {
    String _requestUrl = !isBaseUrl ? "$_baseUrl${url}" : url;

    final _client =
        headers.isEmpty ? _initializer.init() : _initializer.customInit();
    try {
      Response response = await _client.get(
        _requestUrl,
        headers: headers,
        responseType: responseType,
      );
      if (defaultSelector != '') {
        //select value from raw response
        final data = response.data[defaultSelector];
        if (data.isEmpty) return MealCases.blank;
        return data;
      } else {
        //return value without expose
        return response.data;
      }
    } on UnoError {
      return;
    } catch (e) {
      throw '$e error is not UnoError';
    }
  }

  @override
  postRequest(
    url, {
    data,
    bool isBaseUrl = false,
    Map<String, String> headers = const {},
  }) async {
    String _requestUrl = !isBaseUrl ? "$_baseUrl${url}" : url;
    final _client = (headers.isEmpty && url != '/autenticar')
        ? _initializer.init()
        : _initializer.customInit();
    var response = await _client.post(_requestUrl,
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        },
        data: jsonEncode(data));

    return response.data;
  }

  @override
  putRequest(
    url, {
    data,
    bool isBaseUrl = false,
    Map<String, String> headers = const {},
  }) async {
    String _requestUrl = !isBaseUrl ? "$_baseUrl${url}" : url;
    final _client =
        headers.isEmpty ? _initializer.init() : _initializer.customInit();
    var response = await _client.put(_requestUrl,
        headers: headers, data: jsonEncode(data));

    return response.data;
  }
}





// abstract class MealUnoService2 extends MealHttpCache
//     implements MealHttpService {
//   final String _baseUrl;
//   final MealHttpInterceptors _interceptors;
//   final IMealAuthenticator _authenticator;
//   MealUnoService2(this._baseUrl, this._interceptors, this._authenticator);

//   Uno _initializer.customInit() => Uno();

//   Uno _initializer.init() => Uno()
//     ..interceptors.request.use(
//           (request) => _interceptors.onRequest(request),
//           onError: (error) => _interceptors.onError(error),
//         )
//     ..interceptors.response.use(
//           (response) => _interceptors.onResponse(response),
//           onError: (error) => _interceptors.onError(error),
//         );

//   @override
//   deleteRequest(
//     url, {
//     bool isBaseUrl = false,
//     Map<String, String> headers = const {},
//   }) async {
//     String _requestUrl = !isBaseUrl ? "$_baseUrl${url}" : url;
//     final _client = headers.isEmpty ? _initializer.init() : _initializer.customInit();
//     Response response = await _client.delete(_requestUrl, headers: headers);

//     return response.data;
//   }

//   ///[defaultSelector] to expose content from: ["data": {...}]
//   @override
//   getRequest(
//     url, {
//     bool isBaseUrl = false,
//     Map<String, String> headers = const {},
//     ResponseType responseType = ResponseType.json,
//     String defaultSelector = 'data',
//     bool enableCache = false,
//   }) async {
//     String _requestUrl = !isBaseUrl ? "$_baseUrl${url}" : url;

//     final _client = headers.isEmpty ? _initializer.init() : _initializer.customInit();
//     try {
//       Response response = await _client.get(
//         _requestUrl,
//         headers: headers,
//         responseType: responseType,
//       );
//       if (defaultSelector != '') {
//         //select value from raw response
//         final data = response.data[defaultSelector];
//         if (data.isEmpty) return MealCases.blank;
//         return data;
//       } else {
//         //return value without expose
//         return response.data;
//       }
//     } on UnoError {
//       return MealUnoInterceptors(_authenticator).onError(UnoError);
//     } catch (e) {
//       throw '$e error is not UnoError';
//     }
//   }

//   @override
//   postRequest(
//     url, {
//     data,
//     bool isBaseUrl = false,
//     Map<String, String> headers = const {},
//   }) async {
//     String _requestUrl = !isBaseUrl ? "$_baseUrl${url}" : url;
//     final _client =
//         (headers.isEmpty && url != '/autenticar') ? _initializer.init() : _initializer.customInit();
//     var response = await _client.post(_requestUrl,
//         headers: {
//           "Accept": "application/json",
//           "content-type": "application/json"
//         },
//         data: jsonEncode(data));

//     return response.data;
//   }

//   @override
//   putRequest(
//     url, {
//     data,
//     bool isBaseUrl = false,
//     Map<String, String> headers = const {},
//   }) async {
//     String _requestUrl = !isBaseUrl ? "$_baseUrl${url}" : url;
//     final _client = headers.isEmpty ? _initializer.init() : _initializer.customInit();
//     var response = await _client.put(_requestUrl,
//         headers: headers, data: jsonEncode(data));

//     return response.data;
//   }
// }
