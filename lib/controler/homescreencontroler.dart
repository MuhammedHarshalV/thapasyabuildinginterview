import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Homescreencontroler with ChangeNotifier {
  var students = FirebaseFirestore.instance.collection('interview');
  void onDelete(String id) {
    students.doc(id).delete();
  }

  void addStudent({
    required String identer,
    required String title,
    required String content,
  }) {
    students.add({"idshow": identer, "title": title, "content": content});
  }

  void update({
    required String id,
    required String ids,
    required String titles,
    required String contents,
  }) {
    final Map<String, dynamic> data = {};

    if (ids.isNotEmpty) {
      data['id'] = ids;
    }
    if (titles.isNotEmpty) {
      data['title'] = titles;
    }
    if (contents.isNotEmpty) {
      data['content'] = contents;
    }

    if (data.isNotEmpty) {
      students.doc(id).update(data);
    }
  }
}
