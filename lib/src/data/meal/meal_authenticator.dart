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
      MealClientDBAdapter().save(ClientKeys.token, token);
      debugPrint("[MealCli] >> new token saved");
      return token;
    } catch (e) {
      debugPrint("[MealCli] >> ! cant auth $e");
      return MealClientError.auth;
    }
  }

  ///when change company all settings should be removed
  _removeAllDatabase() async {
    await MealDataBase(boxName: 'clientBox').clearMemory();
  }

  ///remove when change user only cache need to be replaced
  _removeOnlyCache() async {
    final baseUrl = await MealClientDBAdapter().read(ClientKeys.baseUrl);
    final account = await MealClientDBAdapter().read(ClientKeys.conta);

    await MealDataBase(boxName: 'clientBox').clearMemory();

    MealClientDBAdapter().save(ClientKeys.baseUrl, baseUrl);
    MealClientDBAdapter().save(ClientKeys.conta, account);
  }

  getToken() async {
    await _initFields();

    dynamic token = await MealClientDBAdapter().read(ClientKeys.token);

    if (token is MealDataBaseError) {
      debugPrint("[MealCli] >> token not found in DB");
      token = null;
    }

    ///check for token of another account
    if (token != null) {
      final tokenData = JwtDecoder.decode(token);
      if (tokenData['groupsid'] != conta) {
        token = null;
        await _removeAllDatabase();
      } else if (tokenData['nameid'] != usuario) {
        debugPrint("[MealCli] >> Removed old storage");
        token = null;
        await _removeOnlyCache();
      }
    }

    if (token == null || JwtDecoder.isExpired(token)) {
      token = await _generateNewToken();
    }

    if (token is MealClientError) return token;

    return {'Authorization': "Bearer $token"};
  }
}
