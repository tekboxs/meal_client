import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'client_keys.dart';

class APIAuthenticator {
  final Dio _client = Dio();
  String? baseUrl, usuario, senha, conta;
  int authAttemps = 0;
  APIAuthenticator();

  ///Read DB to set auth fields
  ///should be used on [getToken] start
  _initFields() async {
    baseUrl = await ClientKeys.baseUrl.read;
    usuario = await ClientKeys.usuario.read;
    senha = await ClientKeys.senha.read;
    conta = await ClientKeys.conta.read;
  }

  ///return token used on auth and user identify
  Future<String?> getToken() async {
    try {
      await _initFields();
      String? token = await ClientKeys.token.read;

      token ??= await _generateNewToken();

      ///if here token generator cannot generate token with ClientKeys provided
      if (token == null) {
        debugPrint(
          "[APIauth] >> $usuario $senha $conta, CAN`T generate Token",
        );
        return null;
      }

      if (!JwtDecoder.isExpired(token)) {
        return token;
      } else {
        await ClientKeys.token.remove;
      }

      ///will try one more time to make sure that is not connection
      if (authAttemps == 0) {
        debugPrint(
          "[APIauth] >> current token is not valid repeating process",
        );
        authAttemps++;
        return await getToken();
      }

      debugPrint(
        "[APIauth] >> 2 attemps done, USER CANT BE VALIDATED, closing...",
      );
      return null;
    } catch (e) {
      return null;
    }
  }

  ///will use data base stored keys to get new valid token
  Future<String?> _generateNewToken() async {
    try {
      debugPrint("[APIauth] >> generating new Token");

      var response = await _client.post(
        '$baseUrl/autenticar',
        data: {"usuario": usuario, "senha": senha, "conta": conta},
        queryParameters: {"Content-Type": "application/json"},
      );

      String token = response.data['data']['accessToken'];

      await ClientKeys.token.write(token);

      debugPrint("[APIauth] >> new Token saved");
      return token;
    } catch (e) {
      await ClientKeys.token.remove;
      await ClientKeys.usuario.write('SUPERVISOR');
      await ClientKeys.senha.write('kx1892');

      throw Exception("[APIauth] >>! CANT generate new token\n$e");
    }
  }
}
