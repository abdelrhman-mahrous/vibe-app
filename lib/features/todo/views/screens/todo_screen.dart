import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../../../../core/theme/vibe_theme.dart';
import '../../data/models/todo_model.dart';
import '../../data/repos/add_task_sheet.dart';
import '../../data/repos/todo_repository.dart';
import '../widgets/todo_tile.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  late final TodoRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = TodoRepositoryImpl();
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskBottomSheet(repository: _repo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _AnimBg(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _TodoHeader(onAdd: _openAddSheet).animate().fadeIn(),
            const SizedBox(height: VibeSpacing.md),
            _StatsRow(repo: _repo).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: VibeSpacing.md),
            Expanded(
              child: ValueListenableBuilder<Box<TodoModel>>(
                valueListenable: _repo.listenableBox,
                builder: (context, box, _) {
                  final todos = _repo.getAllTodos();
                  if (todos.isEmpty) return _EmptyState(onAdd: _openAddSheet);
                  return _TodoList(todos: todos, repo: _repo);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimBg extends StatelessWidget {
  const _AnimBg({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0D0D2B), Color(0xFF070714)],
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _TodoHeader extends StatelessWidget {
  const _TodoHeader({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          VibeSpacing.lg, VibeSpacing.lg, VibeSpacing.lg, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: VibeColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: VibeColors.primaryPurple.withOpacity(0.4),
                    blurRadius: 12,
                  )
                ],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('قائمة المهام', style: VibeTypography.headlineLarge,
                  textDirection: TextDirection.rtl),
              Text('نظم مهامك وحقق أهدافك',
                  style: VibeTypography.bodyMedium,
                  textDirection: TextDirection.rtl),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.repo});
  final TodoRepository repo;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<TodoModel>>(
      valueListenable: repo.listenableBox,
      builder: (_, __, ___) {
        final stats = repo.getStats();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: VibeSpacing.lg),
          child: GlassContainer.frostedGlass(
            height: 64,
            borderRadius: BorderRadius.circular(VibeRadius.lg),
            blur: 12,
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.06),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatChip(
                    value: '${stats['total']}', label: 'إجمالي',
                    color: VibeColors.textAccent),
                _Divider(),
                _StatChip(
                    value: '${stats['pending']}', label: 'متبقية',
                    color: VibeColors.warning),
                _Divider(),
                _StatChip(
                    value: '${stats['completed']}', label: 'مكتملة',
                    color: VibeColors.success),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 28,
        color: Colors.white.withOpacity(0.08));
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.value,
    required this.label,
    required this.color,
  });
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value,
            style: VibeTypography.headlineMedium.copyWith(color: color)),
        Text(label,
            style: VibeTypography.caption,
            textDirection: TextDirection.rtl),
      ],
    );
  }
}

class _TodoList extends StatelessWidget {
  const _TodoList({required this.todos, required this.repo});
  final List<TodoModel> todos;
  final TodoRepository repo;

  @override
  Widget build(BuildContext context) {
    // Group by completion
    final pending = todos.where((t) => !t.isCompleted).toList();
    final completed = todos.where((t) => t.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          VibeSpacing.lg, 0, VibeSpacing.lg, 120),
      children: [
        if (pending.isNotEmpty) ...[
          _SectionHeader(title: 'قيد الإنجاز', count: pending.length),
          ...pending.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: VibeSpacing.sm),
            child: TodoTile(
              todo: e.value,
              index: e.key,
              onToggle: () => repo.toggleComplete(e.value.id),
              onDelete: () => repo.deleteTodo(e.value.id),
            ),
          )),
          const SizedBox(height: VibeSpacing.md),
        ],
        if (completed.isNotEmpty) ...[
          _SectionHeader(title: 'مكتملة', count: completed.length),
          ...completed.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: VibeSpacing.sm),
            child: TodoTile(
              todo: e.value,
              index: e.key,
              onToggle: () => repo.toggleComplete(e.value.id),
              onDelete: () => repo.deleteTodo(e.value.id),
            ),
          )),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: VibeSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: VibeSpacing.sm, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(VibeRadius.full),
              color: Colors.white.withOpacity(0.08),
            ),
            child: Text('$count',
                style: VibeTypography.caption.copyWith(
                  color: VibeColors.textMuted,
                )),
          ),
          const SizedBox(width: VibeSpacing.sm),
          Text(title,
              style: VibeTypography.labelLarge.copyWith(
                color: VibeColors.textMuted,
              ),
              textDirection: TextDirection.rtl),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('✨', style: TextStyle(fontSize: 56)),
          const SizedBox(height: VibeSpacing.md),
          Text('لا توجد مهام بعد',
              style: VibeTypography.headlineMedium,
              textDirection: TextDirection.rtl),
          const SizedBox(height: VibeSpacing.sm),
          Text('ابدأ بإضافة مهمتك الأولى',
              style: VibeTypography.bodyMedium,
              textDirection: TextDirection.rtl),
          const SizedBox(height: VibeSpacing.xl),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: VibeSpacing.xl, vertical: VibeSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(VibeRadius.full),
                gradient: VibeColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: VibeColors.primaryPurple.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Text('أضف مهمة',
                  style: VibeTypography.labelLarge.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700,
                  ),
                  textDirection: TextDirection.rtl),
            ),
          ),
        ],
      ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
    );
  }
}