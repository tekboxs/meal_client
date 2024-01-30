import 'model_conversor.dart';

class InitializationOptions {
  final String? defaultExportDataKey;
  final String? defaultExportMessageKey;
  final List<Object>? objectBinds;
  InitializationOptions({
    this.defaultExportDataKey,
    this.defaultExportMessageKey,
    this.objectBinds,
  }) {
    if (objectBinds != null) _registerBinds;
  }

  Map<String, Object> $binds = {};
  ModelConversor? $conversor;

  void get _registerBinds {
    for (final item in objectBinds!) {
      $binds[item.runtimeType.toString()] = item;
    }

    $conversor = ModelConversor($binds);
  }
}
