import 'package:logger/logger.dart';

final logger = Logger();
ko() {
  logger.d('message');
}

k2o() {
  logger.w('message  2');
}

void main() {
  ko();
  k2o();
}
