import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/presentation/profile_screen.dart' show LevelTier;
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/ambient_glow_background.dart';
import '../../../shared/widgets/app_icons.dart';
import '../../../core/models/quest.dart';
import '../../../core/providers/quest_provider.dart';

class QuestBoardScreen extends ConsumerStatefulWidget {
  const QuestBoardScreen({super.key});

  @override
  ConsumerState<QuestBoardScreen> createState() => _QuestBoardScreenState();
}

class _QuestBoardScreenState extends ConsumerState<QuestBoardScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  QuestCategory? _selectedCategory;

  static const _currentLevel = 12;
  static const _currentXp = 2450;
  static const _xpForNextLevel = 5000;
  static const _xpThisMonth = 2750;
  static const _completedThisMonth = 6;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Quest> _questsForCurrentTab() {
    final allQuests = ref.watch(questProvider);
    final period = switch (_tabController.index) {
      0 => QuestPeriod.daily,
      1 => QuestPeriod.weekly,
      _ => QuestPeriod.monthly,
    };
    final source = allQuests.where((q) => q.period == period).toList();
    if (_selectedCategory == null) return source;
    return source.where((q) => q.category == _selectedCategory).toList();
  }

  Future<void> _showCreateQuestSheet() async {
    final titleController = TextEditingController();
    QuestCategory selectedCategory = QuestCategory.personal;
    QuestPeriod selectedPeriod = switch (_tabController.index) {
      0 => QuestPeriod.daily,
      1 => QuestPeriod.weekly,
      _ => QuestPeriod.monthly,
    };
    int xp = 30;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 20),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              final accent = Theme.of(context).colorScheme.primary;
              final mutedColor = Theme.of(context).textTheme.bodySmall?.color;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('New quest', style: AppTextStyles.headline(context, size: 17)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Meal prep for the week'),
                  ),
                  const SizedBox(height: 16),
                  Text('Category', style: TextStyle(fontSize: 11, color: mutedColor)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: QuestCategory.values.map((category) {
                      final isSelected = selectedCategory == category;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedCategory = category),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? accent : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            category.label,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Theme.of(context).scaffoldBackgroundColor : mutedColor),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('Period', style: TextStyle(fontSize: 11, color: mutedColor)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: QuestPeriod.values.map((period) {
                      final isSelected = selectedPeriod == period;
                      final label = switch (period) {
                        QuestPeriod.daily => 'Daily',
                        QuestPeriod.weekly => 'Weekly',
                        QuestPeriod.monthly => 'Monthly',
                      };
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedPeriod = period),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? accent : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Theme.of(context).scaffoldBackgroundColor : mutedColor),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('XP reward', style: TextStyle(fontSize: 11, color: mutedColor)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 20),
                            onPressed: () => setSheetState(() => xp = (xp - 10).clamp(10, 500)),
                          ),
                          SizedBox(width: 40, child: Text('$xp', textAlign: TextAlign.center, style: AppTextStyles.stat(context, size: 15))),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, size: 20),
                            onPressed: () => setSheetState(() => xp = (xp + 10).clamp(10, 500)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) return;
                        ref.read(questProvider.notifier).addQuest(
                              title: titleController.text.trim(),
                              xp: xp,
                              category: selectedCategory,
                              period: selectedPeriod,
                            );
                        Navigator.of(sheetContext).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                      ),
                      child: const Text('Create quest', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardTheme.color;
    final tier = LevelTier.forLevel(_currentLevel);

    return Scaffold(
      body: AmbientGlowBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quest Board', style: AppTextStyles.headline(context, size: 22)),
                        Text('Complete quests. Earn XP. Level up.', style: TextStyle(color: mutedColor, fontSize: 11)),
                      ],
                    ),
                    IconButton(
                      onPressed: _showCreateQuestSheet,
                      icon: Icon(Icons.add_circle, color: accent, size: 28),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: tier.color.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(18),
                    color: cardColor?.withOpacity(0.4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: tier.color.withOpacity(0.12),
                              border: Border.all(color: tier.color.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Text('$_currentLevel', style: AppTextStyles.stat(context, size: 16, color: tier.color)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tier.name, style: AppTextStyles.headline(context, size: 15)),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: SizedBox(
                                  width: 90,
                                  child: LinearProgressIndicator(
                                    value: _currentXp / _xpForNextLevel,
                                    minHeight: 4,
                                    backgroundColor: Colors.white.withOpacity(0.08),
                                    color: tier.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('THIS MONTH', style: TextStyle(fontSize: 9, letterSpacing: 0.5, color: mutedColor)),
                          Text('$_xpThisMonth XP', style: AppTextStyles.stat(context, size: 15, color: accent)),
                          Text('$_completedThisMonth completed', style: TextStyle(fontSize: 9, color: mutedColor)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              TabBar(
                controller: _tabController,
                onTap: (_) => setState(() {}),
                labelColor: accent,
                unselectedLabelColor: mutedColor,
                indicatorColor: accent,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                tabs: const [Tab(text: 'Daily'), Tab(text: 'Weekly'), Tab(text: 'Monthly')],
              ),

              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    _CategoryChip(label: 'All', isSelected: _selectedCategory == null, accent: accent, onTap: () => setState(() => _selectedCategory = null)),
                    ...QuestCategory.values.map((c) => _CategoryChip(
                          label: c.label,
                          isSelected: _selectedCategory == c,
                          accent: accent,
                          onTap: () => setState(() => _selectedCategory = c),
                        )),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              Expanded(
                child: Builder(builder: (context) {
                  final quests = _questsForCurrentTab();
                  if (quests.isEmpty) {
                    return Center(child: Text('No quests here yet.', style: TextStyle(color: mutedColor, fontSize: 13)));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: quests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final quest = quests[index];
                      final card = quest.progress != null
                          ? _GoalQuestCard(quest: quest, cardColor: cardColor, accent: accent, mutedColor: mutedColor)
                          : _SimpleQuestCard(quest: quest, cardColor: cardColor, accent: accent, mutedColor: mutedColor);
                      return GestureDetector(
                        onTap: () => ref.read(questProvider.notifier).toggleComplete(quest.id),
                        child: card,
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.isSelected, required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: isSelected ? accent : Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(99)),
          child: Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).textTheme.bodySmall?.color),
          ),
        ),
      ),
    );
  }
}

class _SimpleQuestCard extends StatelessWidget {
  final Quest quest;
  final Color? cardColor;
  final Color accent;
  final Color? mutedColor;

  const _SimpleQuestCard({required this.quest, required this.cardColor, required this.accent, required this.mutedColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: (quest.completed ? mutedColor : accent)!.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Center(child: AppIconWidget(icon: quest.category.icon, size: 16, color: quest.completed ? mutedColor! : accent)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    decoration: quest.completed ? TextDecoration.lineThrough : null,
                    color: quest.completed ? mutedColor : null,
                  ),
                ),
                const SizedBox(height: 3),
                Text(quest.category.label, style: TextStyle(color: mutedColor, fontSize: 11)),
              ],
            ),
          ),
          Text('+${quest.xp} XP', style: AppTextStyles.stat(context, size: 12, color: quest.completed ? accent : mutedColor)),
        ],
      ),
    );
  }
}

class _GoalQuestCard extends StatelessWidget {
  final Quest quest;
  final Color? cardColor;
  final Color accent;
  final Color? mutedColor;

  const _GoalQuestCard({required this.quest, required this.cardColor, required this.accent, required this.mutedColor});

  @override
  Widget build(BuildContext context) {
    final isEpic = quest.rarity == QuestRarity.epic;
    final tagColor = isEpic ? accent : mutedColor!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: tagColor.withOpacity(0.35), width: 1.5)),
            alignment: Alignment.center,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(shape: BoxShape.circle, color: tagColor.withOpacity(0.1)),
              child: Center(child: AppIconWidget(icon: quest.category.icon, size: 16, color: tagColor)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: tagColor.withOpacity(0.12), borderRadius: BorderRadius.circular(99)),
                      child: Text(isEpic ? 'EPIC' : 'COMMON', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: tagColor, letterSpacing: 0.5)),
                    ),
                    Text('+${quest.xp} XP', style: AppTextStyles.stat(context, size: 11, color: tagColor)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(quest.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                if (quest.description != null) ...[
                  const SizedBox(height: 3),
                  Text(quest.description!, style: TextStyle(fontSize: 10, color: mutedColor)),
                ],
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(value: quest.progress, minHeight: 5, backgroundColor: Colors.white.withOpacity(0.06), color: tagColor),
                ),
                const SizedBox(height: 6),
                Text('${quest.dueLabel ?? ''} · ${((quest.progress ?? 0) * 100).round()}%', style: TextStyle(fontSize: 9, color: mutedColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}