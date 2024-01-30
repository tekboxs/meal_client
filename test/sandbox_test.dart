// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:meal_client/src/core/initialization_options.dart';

class Fuba {
  fo() => 'yey';
}

class Test<T> {
  final InitializationOptions options;
  Test({
    required this.options,
  });

  T get instance => options.result[T.toString()];
}

void main() {
  final options = InitializationOptions(
    defaultExportDataKey: 'data',
    objectBinds: [Fuba()],
  );

  final x = Test<Fuba>(options: options).instance.fo();
  print(x);
}
