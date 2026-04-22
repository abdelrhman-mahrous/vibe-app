import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/notification_service.dart';
import '../models/todo_model.dart';

abstract class TodoRepository {
  ValueListenable<Box<TodoModel>> get listenableBox;
  List<TodoModel> getAllTodos();
  List<TodoModel> getTodosForDate(DateTime date);
  Future<TodoModel> addTodo(String title, {DateTime? reminderAt, String notes});
  Future<void> toggleComplete(String id);
  Future<void> deleteTodo(String id);
  Future<void> updateReminder(String id, DateTime? reminderAt);
  Map<String, int> getStats();
}

class TodoRepositoryImpl implements TodoRepository {
  TodoRepositoryImpl({Box<TodoModel>? box})
      : _box = box ?? Hive.box<TodoModel>('todos');

  final Box<TodoModel> _box;
  static const _uuid = Uuid();

  @override
  ValueListenable<Box<TodoModel>> get listenableBox => _box.listenable();

  @override
  List<TodoModel> getAllTodos() {
    return _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  List<TodoModel> getTodosForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _box.values
        .where((t) =>
            t.createdAt.isAfter(start) && t.createdAt.isBefore(end))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<TodoModel> addTodo(
    String title, {
    DateTime? reminderAt,
    String notes = '',
  }) async {
    final todo = TodoModel(
      id: _uuid.v4(),
      title: title.trim(),
      createdAt: DateTime.now(),
      reminderAt: reminderAt,
      notes: notes,
    );

    await _box.put(todo.id, todo);

    if (reminderAt != null) {
      await NotificationService.instance.scheduleTaskReminder(
        notificationId: NotificationService.idFromTaskId(todo.id),
        taskTitle: todo.title,
        scheduledAt: reminderAt,
        payload: todo.id,
      );
    }

    return todo;
  }

  @override
  Future<void> toggleComplete(String id) async {
    final todo = _box.get(id);
    if (todo == null) return;
    todo.isCompleted = !todo.isCompleted;
    await todo.save();
  }

  @override
  Future<void> deleteTodo(String id) async {
    await NotificationService.instance
        .cancelNotification(NotificationService.idFromTaskId(id));
    await _box.delete(id);
  }

  @override
  Future<void> updateReminder(String id, DateTime? reminderAt) async {
    final todo = _box.get(id);
    if (todo == null) return;

    // Cancel old notification
    await NotificationService.instance
        .cancelNotification(NotificationService.idFromTaskId(id));

    todo.reminderAt = reminderAt;
    await todo.save();

    // Schedule new one
    if (reminderAt != null) {
      await NotificationService.instance.scheduleTaskReminder(
        notificationId: NotificationService.idFromTaskId(id),
        taskTitle: todo.title,
        scheduledAt: reminderAt,
        payload: id,
      );
    }
  }

  @override
  Map<String, int> getStats() {
    final all = _box.values.toList();
    return {
      'total': all.length,
      'completed': all.where((t) => t.isCompleted).length,
      'pending': all.where((t) => !t.isCompleted).length,
    };
  }
}