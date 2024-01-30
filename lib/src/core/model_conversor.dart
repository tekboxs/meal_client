// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'constants.dart';

class ModelConversor<T> {
  final Map<String, dynamic> _binds;

  ModelConversor(this._binds);

  T convert(Json rawMap) {
    if (_binds[T.toString()] != null) {
      return _binds[T.toString()]!.fromMap();
    }

    throw Exception(
      '[ModelConversor]> _binds dont have ${T.toString()}\n $_binds',
    );
  }
}
