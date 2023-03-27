import 'package:db_commons/db_commons.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:meal_client/meal_client.dart';
import 'package:uno/uno.dart';

class MealAuthenticator {
  //define like this to avoid loop with initializer
  Uno client = Uno();

  MealAuthenticator();

  late String? baseUrl;
  late String? usuario;
  late String? senha;
  late String? conta;

  _initFields() async {
    //read fields, used to more control with changes
    baseUrl = await MealClientDBAdapter().read(
      ClientKeys.baseUrl,
    );
    usuario = await MealClientDBAdapter().read(
      ClientKeys.usuario,
    );
    senha = await MealClientDBAdapter().read(
      ClientKeys.senha,
    );
    conta = await MealClientDBAdapter().read(
      ClientKeys.conta,
    );
  }

  _generateNewToken() async {
    try {
      //REVIEW - implement crypto
      var response = await client.post('$baseUrl/autenticar', data: {
        "usuario": usuario,
        "senha": senha,
        "conta": conta,
      }, headers: {
        "Content-Type": "application/json"
      });
      String token = response.data['data']['accessToken'];
      await MealDataBase().writeMethod(ClientKeys.token, token);
      debugPrint("[MealCli] >> new token saved");
      return token;
    } catch (e) {
      debugPrint("[MealCli] >> ! cant auth $e");
      return MealClientError.auth;
    }
  }

  _removeOldDataBase() async {
    await MealDataBase().clearMemory();
  }

  getToken() async {
    await _initFields();

    dynamic token = await MealDataBase().readMethod(ClientKeys.token);

    ///check for token of another account
    if (token != null) {
      final tokenData = JwtDecoder.decode(token);
      if (tokenData['nameid'] != usuario || tokenData['groupsid'] != conta) {
        debugPrint("[MealCli] >> Removed old storage");
        token = null;
        await _removeOldDataBase();
      }
    }

    if (token == null || JwtDecoder.isExpired(token)) {
      token = await _generateNewToken();
    }

    if (token is MealClientError) return token;

    return {'Authorization': "Bearer $token"};
  }
}
