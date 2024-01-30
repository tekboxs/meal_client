// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'constants.dart';

class ModelConversor<T> {
  final Map<String, dynamic> _binds;

  ModelConversor(this._binds);

  bool get canConvert {
    String currentType = T.toString();

    if (currentType.startsWith('Map')) return false;

    if (currentType == 'dynamic') return false;

    if (currentType.contains('<')) {
      currentType = _extractListType(currentType);
    }

    return _binds[currentType] != null;
  }

  T convert(Json rawMap, [String? currentType]) {
    currentType ??= T.toString();

    if (_binds[currentType] != null) {
      return _binds[currentType]!.fromMap(rawMap);
    }

    throw Exception(
      '[ModelConversor]> _binds dont have $currentType\n $_binds',
    );
  }

  String _extractListType(String input) {
    final matchs = RegExp(r'<.*>').firstMatch(input);
    String result = matchs!.group(0)!;
    return result.substring(1, result.length - 1);
  }
}
