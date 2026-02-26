import 'package:hive/hive.dart';

class ProgressLocalService {
  final Box box = Hive.box('progressBox');

  void saveChapter(String key, Map<String, dynamic> data) {
    box.put(key, data);
  }

  Map<String, dynamic>? getChapter(String key) {
    return box.get(key);
  }

  List<Map> getAllChapters() {
    return box.values.cast<Map>().toList();
  }
}