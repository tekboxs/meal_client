import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:meal_client/src/domain/data_base/i_meal_db_initializer.dart';
import 'package:path_provider/path_provider.dart';

class MealHiveInitializer implements IMealDbInitializer {
  @override
  init() async {
    Directory dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);
  }
}
