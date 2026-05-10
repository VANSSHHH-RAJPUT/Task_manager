import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskService {
  final CollectionReference _taskCollection =
      FirebaseFirestore.instance.collection('tasks');

  // Stream of tasks for a specific user
  Stream<List<TaskModel>> getTasks(String userId) {
    return _taskCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    });
  }

  // Add a new task
  Future<void> addTask(TaskModel task) async {
    await _taskCollection.add(task.toFirestore());
  }

  // Update an existing task
  Future<void> updateTask(TaskModel task) async {
    await _taskCollection.doc(task.id).update(task.toFirestore());
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    await _taskCollection.doc(taskId).delete();
  }

  // Toggle task completion status
  Future<void> toggleTaskStatus(String taskId, bool isCompleted) async {
    await _taskCollection.doc(taskId).update({
      'isCompleted': isCompleted,
    });
  }
}
