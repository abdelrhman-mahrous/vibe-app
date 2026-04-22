import 'package:hive_ce/hive.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
class TodoModel extends HiveObject {
  TodoModel({
    required this.id,
    required this.title,
    required this.createdAt,
    this.isCompleted = false,
    this.reminderAt,
    this.notes = '',
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime? reminderAt;

  @HiveField(5)
  String notes;

  /// Whether a reminder has been scheduled but not yet dismissed
  bool get hasReminder => reminderAt != null;

  bool get isReminderPast =>
      reminderAt != null && reminderAt!.isBefore(DateTime.now());

  bool get isReminderUpcoming =>
      reminderAt != null && reminderAt!.isAfter(DateTime.now());

  TodoModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? reminderAt,
    String? notes,
    bool clearReminder = false,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      reminderAt: clearReminder ? null : (reminderAt ?? this.reminderAt),
      notes: notes ?? this.notes,
    );
  }
}