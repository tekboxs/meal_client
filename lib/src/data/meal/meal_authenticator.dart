// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:meal_client/meal_client.dart';
import 'package:uno/uno.dart';

class _MealAuthenticatorDataBase {
  ///access database with token key, may be null on fist access
  static Future<String?> _readDataBaseToken() async {
    return await MealClientDBAdapter().adapterReadMethod(ClientKeys.token);
  }

  ///remove only cache, keep configs like baseUrl
  static Future _removeUserDataBase() async {
    debugPrint("[MealCli] >> removing USER cache");
    final memoryProvider = MealClientDBAdapter(
      enableWorkMemory: false,
      forceOverride: true,
    );

    final baseUrlHolder =
        await memoryProvider.adapterReadMethod(ClientKeys.baseUrl);
    final accountHolder =
        await memoryProvider.adapterReadMethod(ClientKeys.conta);
    final userHolder =
        await memoryProvider.adapterReadMethod(ClientKeys.usuario);
    final passwordHolder =
        await memoryProvider.adapterReadMethod(ClientKeys.senha);

    await memoryProvider.adapterClearLongTermMemory();
    await memoryProvider.adapterClearWorkMemory();

    await memoryProvider.adapterSaveMethod(ClientKeys.baseUrl, baseUrlHolder);
    await memoryProvider.adapterSaveMethod(ClientKeys.conta, accountHolder);
    await memoryProvider.adapterSaveMethod(ClientKeys.usuario, userHolder);
    await memoryProvider.adapterSaveMethod(ClientKeys.senha, passwordHolder);
  }
}

class MealAuthenticator {
  final Uno _client = Uno();
  String? baseUrl, usuario, senha, conta;
  int authAttemps = 0;
  MealAuthenticator();

  ///Read DB to set auth fields
  ///should be used on [getToken] start
  _initFields() async {
    baseUrl = await MealClientDBAdapter().adapterReadMethod(ClientKeys.baseUrl);
    usuario = await MealClientDBAdapter().adapterReadMethod(ClientKeys.usuario);
    senha = await MealClientDBAdapter().adapterReadMethod(ClientKeys.senha);
    conta = await MealClientDBAdapter().adapterReadMethod(ClientKeys.conta);
  }

  ///return token used on auth and user identify
  Future<String?> getToken() async {
    await _initFields();
    String? token = await _MealAuthenticatorDataBase._readDataBaseToken();

    token ??= await _generateNewToken();

    ///if here token generator cannot generate token with keys provided
    if (token == null) {
      debugPrint("[MealCli] >> $usuario $senha $conta, CAN`T generate Token");
      return null;
    }

    if (await _isValidToken(token)) return token;

    ///will try one more time to make sure that is not connection
    if (authAttemps == 0) {
      debugPrint("[MealCli] >> current token is not valid repeating process");
      authAttemps++;
      return await getToken();
    }

    debugPrint(
      "[MealCli] >> 2 attemps done, USER CANT BE VALIDATED, closing...",
    );
    return null;
  }

  ///verify if token is related to saved user
  ///and if token is valid
  Future<bool> _isValidToken(String token) async {
    final tokenData = JwtDecoder.decode(token);

    if (tokenData['groupsid'] == conta &&
        tokenData['nameid'] == usuario &&
        !JwtDecoder.isExpired(token)) return true;

    ///if not valid should remove other user data to avoid share
    if (tokenData['groupsid'] != conta) {
      debugPrint("[MealCli] >> ACCOUNT CHANGED, cache removal start");

      await _MealAuthenticatorDataBase._removeUserDataBase();
    } else if (tokenData['nameid'] != usuario) {
      debugPrint("[MealCli] >> USER CHANGED, cache removal start");

      await _MealAuthenticatorDataBase._removeUserDataBase();
    } else {
      debugPrint(
          "[MealCli] >> $usuario $senha $conta, NOT configure valid Token (expired: ${JwtDecoder.isExpired(token)})");
    }

    return false;
  }

  ///will use data base stored keys to get new valid token
  Future<String?> _generateNewToken() async {
    try {
      debugPrint("[MealCli] >> generating new Token");

      var response = await _client.post('$baseUrl/autenticar',
          data: {"usuario": usuario, "senha": senha, "conta": conta},
          headers: {"Content-Type": "application/json"});

      String token = response.data['data']['accessToken'];

      await MealClientDBAdapter().adapterSaveMethod(ClientKeys.token, token);

      debugPrint("[MealCli] >> new Token saved");
      return token;
    } catch (e) {
      throw Exception("[MealCli] >>! CANT generate new token\n$e");
    }
  }
}
