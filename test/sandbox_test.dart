import 'package:uno/uno.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test name', () async {
    final uno = Uno();

    await uno
        .get('http://cecum.com.br:5000/estoque/produto2',
            responseType: ResponseType.plain)
        .then((response) {
      //response handle
    }).catchError((error) {
      error.data;
    });
  });
}
