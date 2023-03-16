import 'package:db_commons/db_commons.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:meal_client/src/domain/meal/client_keys.dart';
import 'package:uno/uno.dart';

class MealAuthenticator {
  final String baseUrl;
  final String user;
  final String password;
  final String account;

  //define like this to avoid loop with initializer
  Uno client = Uno();

  MealAuthenticator({
    required this.baseUrl,
    required this.user,
    required this.password,
    required this.account,
  });

  _generateNewToken() async {
    try {
      var response = await client.post('$baseUrl/autenticar', data: {
        "usuario": user,
        "senha": password,
        "conta": account,
      }, headers: {
        "Content-Type": "application/json"
      });
      String token = response.data['data']['accessToken'];
      await MealDataBase().writeMethod(ClientKeys.token, token);
      debugPrint(">>new token saved");
      return token;
    } catch (e) {
      throw 'cant authenticate $e';
    }
  }

  getToken() async {
    String? token = await MealDataBase().readMethod(ClientKeys.token);
    if (token == null || JwtDecoder.isExpired(token)) {
      token = await _generateNewToken();
    }
    return {'Authorization': "Bearer $token"};
  }
}
