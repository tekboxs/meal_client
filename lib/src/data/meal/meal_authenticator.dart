// ignore_for_file: unused_element

import 'package:db_commons/db_commons.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:meal_client/meal_client.dart';
import 'package:uno/uno.dart';

class _MealAuthenticatorDataBase {
  ///access database with token key, may be null on fist access
  static Future<String?> _readDataBaseToken() async {
    return await MealClientDBAdapter().read(ClientKeys.token);
  }

  ///remove only cache, keep configs like baseUrl
  static Future _removeUserDataBase() async {
    debugPrint("[MealCli] >> removing USER cache");

    final baseUrlHolder = await MealClientDBAdapter().read(ClientKeys.baseUrl);
    final accountHolder = await MealClientDBAdapter().read(ClientKeys.conta);

    await MealDataBase(boxName: 'clientBox').clearMemory();

    await MealClientDBAdapter().save(ClientKeys.baseUrl, baseUrlHolder);
    await MealClientDBAdapter().save(ClientKeys.conta, accountHolder);
  }

  ///remove all data and configs, used on company change
  static Future _removeAllDataBase() async {
    debugPrint("[MealCli] >> clearing ALL data base");

    await MealDataBase(boxName: 'clientBox').clearMemory();
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
    baseUrl = await MealClientDBAdapter().read(ClientKeys.baseUrl);
    usuario = await MealClientDBAdapter().read(ClientKeys.usuario);
    senha = await MealClientDBAdapter().read(ClientKeys.senha);
    conta = await MealClientDBAdapter().read(ClientKeys.conta);
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
        "[MealCli] >> 2 attemps done, USER CANT BE VALIDATED, closing...");
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

      await _MealAuthenticatorDataBase._removeAllDataBase();
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

      await MealClientDBAdapter().save(ClientKeys.token, token);

      debugPrint("[MealCli] >> new Token saved");
      return token;
    } catch (e) {
      throw "[MealCli] >>! CANT generate new token\n$e";
    }
  }
}

// class MealAuthenticator2 {
//   //define like this to avoid loop with initializer
//   Uno client = Uno();

//   MealAuthenticator2();

//   late String? baseUrl;
//   late String? usuario;
//   late String? senha;
//   late String? conta;

//   _initFields() async {
//     //read fields, used to more control with changes
//     baseUrl = await MealClientDBAdapter().read(
//       ClientKeys.baseUrl,
//     );
//     usuario = await MealClientDBAdapter().read(
//       ClientKeys.usuario,
//     );
//     senha = await MealClientDBAdapter().read(
//       ClientKeys.senha,
//     );
//     conta = await MealClientDBAdapter().read(
//       ClientKeys.conta,
//     );
//   }

//   _generateNewToken() async {
//     try {
//       //REVIEW - implement crypto
//       var response = await client.post('$baseUrl/autenticar', data: {
//         "usuario": usuario,
//         "senha": senha,
//         "conta": conta,
//       }, headers: {
//         "Content-Type": "application/json"
//       });
//       String token = response.data['data']['accessToken'];
//       MealClientDBAdapter().save(ClientKeys.token, token);
//       debugPrint("[MealCli] >> new token saved");
//       return token;
//     } catch (e) {
//       debugPrint("[MealCli] >> ! cant auth $e");
//       return MealClientError.auth;
//     }
//   }

//   ///when change company all settings should be removed
//   _removeAllDatabase() async {
//     await MealDataBase(boxName: 'clientBox').clearMemory();
//   }

//   ///remove when change user only cache need to be replaced
//   _removeOnlyCache() async {
//     final baseUrl = await MealClientDBAdapter().read(ClientKeys.baseUrl);
//     final account = await MealClientDBAdapter().read(ClientKeys.conta);

//     await MealDataBase(boxName: 'clientBox').clearMemory();

//     MealClientDBAdapter().save(ClientKeys.baseUrl, baseUrl);
//     MealClientDBAdapter().save(ClientKeys.conta, account);
//   }

//   getToken() async {
//     await _initFields();

//     dynamic token = await MealClientDBAdapter().read(ClientKeys.token);

//     if (token is MealDataBaseError) {
//       debugPrint("[MealCli] >> token not found in DB");
//       token = null;
//     }

//     ///check for token of another account
//     if (token != null) {
//       final tokenData = JwtDecoder.decode(token);
//       if (tokenData['groupsid'] != conta) {
//         token = null;
//         await _removeAllDatabase();
//       } else if (tokenData['nameid'] != usuario) {
//         debugPrint("[MealCli] >> Removed old storage");
//         token = null;
//         await _removeOnlyCache();
//       }
//     }

//     if (token == null) {
//       ///here remove cache to avoid user share
//       ///cache
//       await _removeOnlyCache();
//       token = await _generateNewToken();
//     } else if (JwtDecoder.isExpired(token)) {
//       ///should be same user only expired
//       token = await _generateNewToken();
//     }

//     if (token is MealClientError) return token;

//     return {'Authorization': "Bearer $token"};
//   }
// }
