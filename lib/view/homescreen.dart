import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thapasya_interview_nov14/controler/homescreencontroler.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  TextEditingController idcontroler = TextEditingController();
  TextEditingController titlecontroler = TextEditingController();
  TextEditingController contentcontroler = TextEditingController();

  @override
  void dispose() {
    idcontroler.dispose();
    titlecontroler.dispose();
    contentcontroler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Students App')),
      body: StreamBuilder(
        stream: context.watch<Homescreencontroler>().students.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available'));
          }

          var studentDocuments = snapshot.data!.docs;

          if (studentDocuments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No students found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // Access second document if it exists
          if (studentDocuments.length >= 2) {
            final secondStudent = studentDocuments[1]; // Index 1 = second item
            final secondDocId = secondStudent.id;
            final secondData = secondStudent.data() as Map<String, dynamic>;

            print('Second Document ID: $secondDocId');
            print('Second Document Data: $secondData');
            print('Second Document ID Field: ${secondData['idshow']}');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: studentDocuments.length,
            itemBuilder: (context, index) {
              final student = studentDocuments[index];
              final docId = student.id; // Get document ID
              final data = student.data();

              final idscreen = data['idshow'] ?? 'No ID';
              final titlescreen = data['title'] ?? 'No Title';
              final contentscreen = data['content'] ?? 'No Content';

              // Show which index this is
              final displayIndex = index + 1;
              log('Document $displayIndex ID: $docId');

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Show position and document ID
                            _shows('ID: $idscreen', Colors.white),
                            const SizedBox(height: 8),
                            _shows('Title: $titlescreen', Colors.white),
                            const SizedBox(height: 8),
                            Expanded(
                              child: _shows(
                                'Content: $contentscreen',
                                Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          // Edit Button
                          IconButton(
                            onPressed: () {
                              _showEditBottomSheet(
                                context,
                                docId,
                                idscreen,
                                titlescreen,
                                contentscreen,
                              );

                              log(docId);
                            },
                            icon: const Icon(Icons.edit, color: Colors.blue),
                          ),
                          // Delete Button
                          IconButton(
                            onPressed: () {
                              context.read<Homescreencontroler>().onDelete(
                                docId,
                              );
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBottomSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Show Add Bottom Sheet
  void _showAddBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add New Student',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: idcontroler,
              decoration: const InputDecoration(
                labelText: 'Enter ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titlecontroler,
              decoration: const InputDecoration(
                labelText: 'Enter TITLE',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentcontroler,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Enter CONTENT',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (idcontroler.text.isNotEmpty &&
                      titlecontroler.text.isNotEmpty &&
                      contentcontroler.text.isNotEmpty) {
                    context.read<Homescreencontroler>().addStudent(
                      identer: idcontroler.text,
                      title: titlecontroler.text,
                      content: contentcontroler.text,
                    );

                    // Clear controllers
                    idcontroler.clear();
                    titlecontroler.clear();
                    contentcontroler.clear();

                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text(
                  'SAVE',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showEditBottomSheet(
    BuildContext context,
    String docId,
    String currentId,
    String currentTitle,
    String currentContent,
  ) {
    idcontroler.text = currentId;
    titlecontroler.text = currentTitle;
    contentcontroler.text = currentContent;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Edit Student',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Document ID: $docId',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: idcontroler,

              decoration: const InputDecoration(
                labelText: 'Enter ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: titlecontroler,
              decoration: const InputDecoration(
                labelText: 'Enter TITLE',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentcontroler,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Enter CONTENT',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (idcontroler.text.isNotEmpty &&
                      titlecontroler.text.isNotEmpty &&
                      contentcontroler.text.isNotEmpty) {
                    context.read<Homescreencontroler>().update(
                      id: docId,
                      ids: currentId,
                      titles: currentTitle,
                      contents: currentContent,
                    );
                    // Clear controllers
                    // idcontroler.clear();
                    // titlecontroler.clear();
                    // contentcontroler.clear();

                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text(
                  'UPDATE',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Text _shows(String text, Color color) {
    return Text(
      text,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
