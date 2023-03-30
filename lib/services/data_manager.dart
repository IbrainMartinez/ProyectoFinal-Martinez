
import 'package:hive/hive.dart';

void addOrUpdateData(
  String category,
  dynamic key,
  dynamic value,
) {
  if (!Hive.isBoxOpen(category)) {
    Hive.openBox(category);
  }
  Hive.box(category).put(key, value);
}

Future getData(String category, dynamic key) async {
  if (!Hive.isBoxOpen(category)) {
    await Hive.openBox(category);
  }
  return Hive.box(category).get(key);
}


