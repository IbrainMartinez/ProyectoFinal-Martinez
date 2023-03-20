import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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

void deleteData(String category, dynamic key) {
  if (!Hive.isBoxOpen(category)) {
    Hive.openBox(category);
  }
  Hive.box(category).delete(key);
}

void clearCache() async {
  if (!Hive.isBoxOpen('cache')) {
    await Hive.openBox('cache');
  }
  await Hive.box('cache').clear();
}

Future backupData(BuildContext context) async {
  final boxNames = ['user', 'settings'];
  final dlPath = await FilePicker.platform.getDirectoryPath();

  if (dlPath == null) {
    return 'CORRIENDO!';
  }

  for (var i = 0; i < boxNames.length; i++) {
    await Hive.openBox(boxNames[i]);
    try {
      await File(Hive.box(boxNames[i]).path!)
          .copy('$dlPath/${boxNames[i]}Data.hive');
    } catch (e) {
      await File(Hive.box(boxNames[i]).path!)
          .copy('$dlPath/${boxNames[i]}Data.hive');
      return 'PROBLEMA!';
    }
  }
  return 'LISTO!';
}

Future restoreData(context) async {
  final boxNames = ['user', 'settings'];
  final uplPath = await FilePicker.platform.getDirectoryPath();

  if (uplPath == null) {
    return 'CORRIENDO!';
  }

  for (var i = 0; i < boxNames.length; i++) {
    await Hive.openBox(boxNames[i]);
    try {
      final box = await Hive.openBox(boxNames[i]);
      final boxPath = box.path;
      await File('$uplPath/${boxNames[i]}Data.hive').copy(boxPath!);
    } catch (e) {
      return 'PROBLEMA!';
    }
  }

  return ';LSITO!';
}
