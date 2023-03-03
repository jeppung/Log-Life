
import 'package:hive_flutter/adapters.dart';

class Database {
  List notes = [];

  final box = Hive.box('log');

  void loadData() {
    notes = box.get('data') ?? [];
  }

  void updateDatabase() {
    box.put('data', notes);
  }
}
