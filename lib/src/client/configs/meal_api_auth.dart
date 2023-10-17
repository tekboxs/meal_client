// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:meal_client/src/memory/memory_manager.dart';
import 'package:meal_client/src/models/meal_errors_model.dart';
import 'package:meal_client/src/models/meal_reponse_model.dart';
import 'package:meal_client/src/utils/memory_enum_keys.dart';
import 'package:meal_client/src/utils/typedefs.dart';
import 'package:uno/uno.dart';

enum TokenValidationActions { removeUserCache, pass }

///[ClientConfigEnumKeys.token] must be filled by custom
///if used
class MealApiAuth {
  final String authRoute;

  final String exportResponseKey;
  final TokenValidationActions Function(Json token) validateToken;

  ///dont inject to avoid circular dependency
  final Uno _localClient = Uno();

  // ignore: prefer_final_fields
  int _authAttemps = 0;

  MealApiAuth({
    required this.validateToken,
    required this.authRoute,
    required this.exportResponseKey,
  });

  Future<String?> get _getTokenWhenValid async {
    final token = await ClientConfigEnumKeys.token.read;

    final tokenData = JwtDecoder.decode(token);

    if (JwtDecoder.isExpired(token)) return null;

    switch (validateToken(tokenData)) {
      case TokenValidationActions.pass:
        return token;
      case TokenValidationActions.removeUserCache:
        await MemoryManager.customService.clear();
        await ClientConfigEnumKeys.token.remove;
        debugPrint('[_getTokenWhenValid]>> Cache and token cleared');
        return null;
    }
  }

  Future<Json?> get _getMemoryConfigMap async {
    try {
      final Json dataMap = {};

      final keysToRecover = [
        ClientConfigEnumKeys.conta,
        ClientConfigEnumKeys.usuario,
        ClientConfigEnumKeys.senha,
      ];

      for (final item in keysToRecover) {
        dataMap[item.name] = await item.read;
      }

      return dataMap;
    } catch (e) {
      debugPrint('[buildMemoryMap]>> $e');
      throw MemoryError(message: e.toString());
    }
  }

  Future<MealReponseModel?> get _getNewToken async {
    try {
      final data = await _getMemoryConfigMap;

      final response = await _localClient.post(
        data: data,
        authRoute,
      );

      await ClientConfigEnumKeys.token.write(response.data[exportResponseKey]);
      return response.data[exportResponseKey];
    } catch (e) {
      if (e is UnoError) {
        debugPrint('[getNewToken]>> bad request $e');
        throw ResponseError(
          statusCode: e.response?.status,
          message: 'getNewToken ${e.response?.data}',
        );
      } else {
        debugPrint('[getNewToken]>> interal error $e');
        throw InternalError(message: 'getNewToken $e');
      }
    }
  }

  Future<String?> authProcess() async {
    try {
      String? token = await _getTokenWhenValid;
      token ??= (await _getNewToken)?.unWarp;

      return token;
    } catch (e) {
      _authAttemps++;
      debugPrint('[authProcess]>> error $e on $_authAttemps try');

      if (_authAttemps == 2) {
        debugPrint('[authProcess]>> max tries on auth, continue with error');
        rethrow;
      }

      return await authProcess();
    }
  }
}
