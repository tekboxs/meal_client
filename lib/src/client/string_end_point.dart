// ignore_for_file: unused_local_variable

import 'package:get_it/get_it.dart';
import 'package:meal_client/src/client/meal_client.dart';
import 'package:meal_client/src/core/models/meal_response_model.dart';
import 'package:meal_client/src/core/request_options.dart';

class Venda {}

xo() async {
  final x = await '/vendas/venda'.get<Venda>();
  Venda? venda = x.data;

  final y = await '/vendas_raw'.get();
  dynamic vendasRaw = y.data;

  final z = await '/vendas'.get<Venda>();
  List<Venda>? vendas = z.dataList;
}

extension EndPoint on String {
  Future<MealResponseModel<T>> get<T>({MealRequestOptions? options}) {
    final client = GetIt.I.get<MealClient>();

    return client.getMethod<T>(this, requestOptions: options);
  }
}
