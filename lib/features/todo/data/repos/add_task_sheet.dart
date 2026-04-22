import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glass_kit/glass_kit.dart';
import '../../../../core/global_widgets/vibe_widgets.dart';
import '../../../../core/theme/vibe_theme.dart';
import 'todo_repository.dart';


class AddTaskBottomSheet extends StatefulWidget {
  const AddTaskBottomSheet({super.key, required this.repository});
  final TodoRepository repository;

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _reminderAt;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickReminder() async {
    // First pick relative duration
    final result = await showDialog<Duration>(
      context: context,
      builder: (_) => const _ReminderDurationDialog(),
    );
    if (result != null) {
      setState(() => _reminderAt = DateTime.now().add(result));
    }
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);

    await widget.repository.addTodo(
      _titleController.text,
      reminderAt: _reminderAt,
      notes: _notesController.text,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: VibeColors.surface,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(VibeRadius.xxl)),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + VibeSpacing.lg,
        left: VibeSpacing.lg,
        right: VibeSpacing.lg,
        top: VibeSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: VibeSpacing.lg),
          Text('مهمة جديدة',
              style: VibeTypography.headlineMedium,
              textDirection: TextDirection.rtl),
          const SizedBox(height: VibeSpacing.md),
          // Title field
          _SheetTextField(
            controller: _titleController,
            placeholder: 'عنوان المهمة...',
            autofocus: true,
          ),
          const SizedBox(height: VibeSpacing.sm),
          // Notes field
          _SheetTextField(
            controller: _notesController,
            placeholder: 'ملاحظات (اختياري)',
            maxLines: 2,
          ),
          const SizedBox(height: VibeSpacing.md),
          // Reminder row
          GestureDetector(
            onTap: _pickReminder,
            child: GlassContainer.frostedGlass(
              height: 48,
              borderRadius: BorderRadius.circular(VibeRadius.md),
              blur: 8,
              gradient: LinearGradient(
                colors: [
                  (_reminderAt != null
                          ? VibeColors.primaryPurple
                          : Colors.white)
                      .withOpacity(0.08),
                  Colors.white.withOpacity(0.02),
                ],
              ),
              borderGradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.12),
                  Colors.white.withOpacity(0.04),
                ],
              ),
              borderWidth: 1,
              // isFrostedGlass: true,
              frostedOpacity: 0.01,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: VibeSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_reminderAt != null)
                      GestureDetector(
                        onTap: () => setState(() => _reminderAt = null),
                        child: const Icon(Icons.close_rounded,
                            color: VibeColors.textMuted, size: 16),
                      ),
                    const SizedBox(width: VibeSpacing.sm),
                    Text(
                      _reminderAt != null
                          ? _formatReminder(_reminderAt!)
                          : 'إضافة تذكير',
                      style: VibeTypography.bodyMedium.copyWith(
                        color: _reminderAt != null
                            ? VibeColors.textAccent
                            : VibeColors.textMuted,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(width: VibeSpacing.sm),
                    Icon(
                      _reminderAt != null
                          ? Icons.alarm_on_rounded
                          : Icons.add_alarm_rounded,
                      color: _reminderAt != null
                          ? VibeColors.accentViolet
                          : VibeColors.textMuted,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: VibeSpacing.lg),
          VibePrimaryButton(
            label: 'حفظ المهمة',
            onPressed: _save,
            isLoading: _isSaving,
            icon: Icons.check_rounded,
          ),
        ],
      ).animate().slideY(begin: 0.2, end: 0).fadeIn(),
    );
  }

  String _formatReminder(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.inDays > 0) return 'بعد ${diff.inDays} يوم';
    if (diff.inHours > 0) return 'بعد ${diff.inHours} ساعة';
    return 'بعد ${diff.inMinutes} دقيقة';
  }
}

class _SheetTextField extends StatelessWidget {
  const _SheetTextField({
    required this.controller,
    required this.placeholder,
    this.maxLines = 1,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String placeholder;
  final int maxLines;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      maxLines: maxLines,
      textDirection: TextDirection.rtl,
      style: VibeTypography.bodyLarge.copyWith(color: VibeColors.textPrimary),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: VibeTypography.bodyMedium.copyWith(color: VibeColors.textMuted),
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: VibeSpacing.md, vertical: VibeSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VibeRadius.md),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VibeRadius.md),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VibeRadius.md),
          borderSide: BorderSide(
              color: VibeColors.accentViolet.withOpacity(0.6), width: 1.5),
        ),
      ),
    );
  }
}

class _ReminderDurationDialog extends StatefulWidget {
  const _ReminderDurationDialog();

  @override
  State<_ReminderDurationDialog> createState() =>
      _ReminderDurationDialogState();
}

class _ReminderDurationDialogState extends State<_ReminderDurationDialog> {
  int _value = 30;
  _Unit _unit = _Unit.minutes;

  Duration get _duration {
    switch (_unit) {
      case _Unit.minutes:
        return Duration(minutes: _value);
      case _Unit.hours:
        return Duration(hours: _value);
      case _Unit.days:
        return Duration(days: _value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: VibeColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VibeRadius.xl)),
        child: Padding(
          padding: const EdgeInsets.all(VibeSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('حدد موعد التذكير',
                  style: VibeTypography.headlineMedium),
              const SizedBox(height: VibeSpacing.lg),
              // Value selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => setState(() {
                      if (_value > 1) _value--;
                    }),
                    icon: const Icon(Icons.remove_circle_outline_rounded,
                        color: VibeColors.textMuted),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '$_value',
                      style: VibeTypography.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _value++),
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        color: VibeColors.accentViolet),
                  ),
                ],
              ),
              // Unit selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _Unit.values.map((u) {
                  final isSelected = u == _unit;
                  return GestureDetector(
                    onTap: () => setState(() => _unit = u),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: VibeSpacing.md, vertical: VibeSpacing.xs),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(VibeRadius.full),
                        gradient:
                            isSelected ? VibeColors.primaryGradient : null,
                        color: isSelected
                            ? null
                            : Colors.white.withOpacity(0.06),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        u.label,
                        style: VibeTypography.labelMedium.copyWith(
                          color: isSelected
                              ? Colors.white
                              : VibeColors.textMuted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: VibeSpacing.lg),
              VibePrimaryButton(
                label: 'تأكيد',
                onPressed: () => Navigator.pop(context, _duration),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Unit {
  minutes('دقائق'),
  hours('ساعات'),
  days('أيام');

  const _Unit(this.label);
  final String label;
}