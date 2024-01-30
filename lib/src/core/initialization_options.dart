// ignore_for_file: public_member_api_docs, sort_constructors_first
class InitializationOptions {
  final String? defaultExportDataKey;
  final String? baseUrl;
  final String? defaultExportMessageKey;
  final List<Object>? objectBinds;
  InitializationOptions({
    this.defaultExportDataKey,
    this.baseUrl,
    this.defaultExportMessageKey,
    this.objectBinds,
  }) {
    if (objectBinds != null) _registerBinds;
  }

  Map<String, Object> $binds = {};

  void get _registerBinds {
    for (final item in objectBinds!) {
      $binds[item.runtimeType.toString()] = item;
    }
  }
}
