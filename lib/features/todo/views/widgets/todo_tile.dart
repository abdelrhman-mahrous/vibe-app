import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glass_kit/glass_kit.dart';
import '../../../../core/theme/vibe_theme.dart';
import '../../data/models/todo_model.dart';

class TodoTile extends StatelessWidget {
  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.index,
  });

  final TodoModel todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.startToEnd,
      background: _DismissBackground(),
      onDismissed: (_) => onDelete(),
      child: GlassContainer.frostedGlass(
        width: double.infinity,
        height: 60.h,

        borderRadius: BorderRadius.circular(VibeRadius.lg),
        blur: 10,
        gradient: LinearGradient(
          colors: todo.isCompleted
              ? [
                  VibeColors.success.withOpacity(0.08),
                  Colors.white.withOpacity(0.02),
                ]
              : [
                  Colors.white.withOpacity(0.06),
                  Colors.white.withOpacity(0.02),
                ],
        ),
        borderGradient: LinearGradient(
          colors: todo.isCompleted
              ? [
                  VibeColors.success.withOpacity(0.3),
                  VibeColors.success.withOpacity(0.1),
                ]
              : [
                  Colors.white.withOpacity(0.12),
                  Colors.white.withOpacity(0.04),
                ],
        ),
        borderWidth: 1,
        // isFrostedGlass: true,
        frostedOpacity: 0.01,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: VibeSpacing.md,
            vertical: VibeSpacing.sm + 2,
          ),
          child: Row(
            children: [
              // Delete
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 28.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: VibeColors.error.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: VibeColors.error,
                    size: 15,
                  ),
                ),
              ),
              const SizedBox(width: VibeSpacing.sm),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: 45.h,
                        maxWidth: 200.w,
                      ),
                      child: Text(
                        todo.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: VibeTypography.bodyLarge.copyWith(
                          color: todo.isCompleted
                              ? VibeColors.textMuted
                              : VibeColors.textPrimary,
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: VibeColors.textMuted,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                    if (todo.hasReminder) ...[
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            todo.isReminderPast
                                ? Icons.alarm_off_rounded
                                : Icons.alarm_rounded,
                            size: 12,
                            color: todo.isReminderPast
                                ? VibeColors.textMuted
                                : VibeColors.accentViolet,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatReminderText(todo.reminderAt!),
                            style: VibeTypography.caption.copyWith(
                              color: todo.isReminderPast
                                  ? VibeColors.textMuted
                                  : VibeColors.textAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: VibeSpacing.sm),
              // Checkbox
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: todo.isCompleted
                        ? LinearGradient(
                            colors: [
                              VibeColors.success,
                              VibeColors.success.withOpacity(0.7),
                            ],
                          )
                        : null,
                    color: todo.isCompleted ? null : Colors.transparent,
                    border: todo.isCompleted
                        ? null
                        : Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 1.5,
                          ),
                    boxShadow: todo.isCompleted
                        ? [
                            BoxShadow(
                              color: VibeColors.success.withOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: todo.isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ).animate(delay: (index * 60).ms).fadeIn().slideX(begin: 0.1, end: 0),
    );
  }

  String _formatReminderText(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now);
    if (diff.isNegative) return 'انتهى الموعد';
    if (diff.inDays > 0) return 'بعد ${diff.inDays} يوم';
    if (diff.inHours > 0) return 'بعد ${diff.inHours} ساعة';
    if (diff.inMinutes > 0) return 'بعد ${diff.inMinutes} دقيقة';
    return 'الآن';
  }
}

class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: VibeSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(VibeRadius.lg),
        color: VibeColors.error.withOpacity(0.15),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: VibeSpacing.lg),
      child: const Icon(Icons.delete_rounded, color: VibeColors.error),
    );
  }
}
