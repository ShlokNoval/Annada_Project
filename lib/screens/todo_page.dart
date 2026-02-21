import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _controller = TextEditingController();

  // Get current logged-in user ID
  String get userId => FirebaseAuth.instance.currentUser!.uid;

  // Reference to user's task collection
  CollectionReference get _taskCollection =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tasks');

  // ================= ADD TASK =================
  Future<void> _addTask() async {
    if (_controller.text.trim().isEmpty) return;

    await _taskCollection.add({
      'title': _controller.text.trim(),
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _controller.clear();
  }

  // ================= TOGGLE COMPLETE =================
  Future<void> _toggleTask(
      String docId,
      bool currentStatus,
      ) async {
    await _taskCollection.doc(docId).update({
      'completed': !currentStatus,
    });
  }

  // ================= DELETE TASK =================
  Future<void> _deleteTask(String docId) async {
    await _taskCollection.doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To-Do List"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ================= ADD TASK FIELD =================
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Add a new task...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ================= TASK LIST =================
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _taskCollection
                    .orderBy('createdAt', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No tasks yet. Add your first task.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  final tasks = snapshot.data!.docs;

                  final pending = tasks
                      .where((doc) => doc['completed'] == false)
                      .toList();

                  final completed = tasks
                      .where((doc) => doc['completed'] == true)
                      .toList();

                  return ListView(
                    children: [

                      // ================= UPCOMING =================
                      const Text(
                        "Upcoming Tasks",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      ...pending.map((doc) {
                        return Card(
                          child: ListTile(
                            title: Text(doc['title']),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              onPressed: () =>
                                  _toggleTask(doc.id, false),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 20),

                      // ================= COMPLETED =================
                      if (completed.isNotEmpty)
                        const Text(
                          "Completed Tasks",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      ...completed.map((doc) {
                        return Card(
                          color: Colors.green.shade50,
                          child: ListTile(
                            title: Text(
                              doc['title'],
                              style: const TextStyle(
                                decoration:
                                TextDecoration.lineThrough,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  _deleteTask(doc.id),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}