import 'dart:async';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:meal_client/src2/auth/interface_meal_auth.dart';
import 'package:uno/uno.dart';

import '../../meal_client.dart';
import '../cache/meal_cache.dart';
import '../data/storage.dart';
import 'meal_http_interceptors.dart';

class MealUnoInterceptors extends MealHttpCache
    implements MealHttpInterceptors {
  final IMealAuthenticator _authenticator;

  MealUnoInterceptors(this._authenticator)
      : super(cacheDuration: Duration(hours: 1));

  Future<Map<String, String>> tokenGenerator() async {
    String? token = await Storage.read('token');
    if (token == null || JwtDecoder.isExpired(token)) {
      token = await _authenticator.doDefaultAuth();
    }
    return {'Authorization': "Bearer $token"};
  }

  @override
  FutureOr<Request> onRequest(TRequest) async {
    if (TRequest is Request) {
      Map<String, String> token = await tokenGenerator();
      Request request = TRequest..headers.addAll(token);
      return request;
    } else {
      throw 'unexpected type';
    }
  }

  @override
  FutureOr<Response> onResponse(TResponse) async {
    Response response = TResponse;

    return TResponse;
  }

  @override
  MealErrors onError(TError) {
    if (TError is UnoError) {
      UnoError error = TError;
      switch (error.response?.status) {
        case 404:
          return MealErrors.timeout;
        case 400:
          return MealErrors.route;
        case 401:
          return MealErrors.auth;
        case 500:
          return MealErrors.serverInternal;
        default:
          return MealErrors.unknown;
      }
    } else {
      return MealErrors.unknown;
    }
  }
}
