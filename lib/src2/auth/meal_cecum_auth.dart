import 'package:meal_client/src2/auth/interface_meal_auth.dart';

import '../data/storage.dart';
import '../interceptors/meal_http_interceptors.dart';

abstract class MealCecumAuthenticator extends IMealAuthenticator {
  final MealHttpService _httpService;
  MealCecumAuthenticator(
    this._httpService, {
    required super.defaultuser,
    required super.defaultpassword,
    required super.defaultaccount,
  });

  @override
  doDefaultAuth() async {
    try {
      var response = await _httpService.postRequest('/autenticar', data: {
        "usuario": defaultuser,
        "senha": defaultpassword,
        "conta": defaultaccount,
      });
      Map data = response['data'] as Map;

      await Storage.write('token', data['accessToken']);
      print('Nem token was saved');
      return data['accessToken'];
    } catch (e) {
      throw '>>auth user not found\n\n$e';
    }
  }
}
