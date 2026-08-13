import 'package:flutter/material.dart';

enum QuestCategory { fitness, focus, knowledge, personal }

extension QuestCategoryX on QuestCategory {
  String get label {
    switch (this) {
      case QuestCategory.fitness:
        return 'Fitness';
      case QuestCategory.focus:
        return 'Focus';
      case QuestCategory.knowledge:
        return 'Knowledge';
      case QuestCategory.personal:
        return 'Personal';
    }
  }

  IconData get icon {
    switch (this) {
      case QuestCategory.fitness:
        return Icons.fitness_center;
      case QuestCategory.focus:
        return Icons.code;
      case QuestCategory.knowledge:
        return Icons.menu_book_outlined;
      case QuestCategory.personal:
        return Icons.self_improvement;
    }
  }
}

class Quest {
  final String title;
  final int xp;
  final QuestCategory category;
  final bool completed;

  const Quest({
    required this.title,
    required this.xp,
    required this.category,
    this.completed = false,
  });
}

const _dailyQuests = [
  Quest(title: 'Morning workout', xp: 50, category: QuestCategory.fitness, completed: true),
  Quest(title: 'Read 20 pages', xp: 30, category: QuestCategory.knowledge),
  Quest(title: 'Flutter deep work', xp: 80, category: QuestCategory.focus),
  Quest(title: 'Evening walk', xp: 20, category: QuestCategory.personal),
];

const _weeklyQuests = [
  Quest(title: 'Finish portfolio homepage', xp: 200, category: QuestCategory.focus),
  Quest(title: '4 gym sessions this week', xp: 150, category: QuestCategory.fitness, completed: true),
  Quest(title: 'Finish one book chapter', xp: 60, category: QuestCategory.knowledge),
];

const _monthlyQuests = [
  Quest(title: 'Ship Questify v1', xp: 500, category: QuestCategory.focus),
  Quest(title: 'Run a 5K', xp: 300, category: QuestCategory.fitness),
];

class QuestBoardScreen extends StatefulWidget {
  const QuestBoardScreen({super.key});

  @override
  State<QuestBoardScreen> createState() => _QuestBoardScreenState();
}

class _QuestBoardScreenState extends State<QuestBoardScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  QuestCategory? _selectedCategory; // null = show all categories

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
    final source = switch (_tabController.index) {
      0 => _dailyQuests,
      1 => _weeklyQuests,
      _ => _monthlyQuests,
    };
    if (_selectedCategory == null) return source;
    return source.where((q) => q.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardTheme.color;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quest Board',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: () {}, // wired up when we build "Create Quest"
                    icon: Icon(Icons.add_circle, color: accent, size: 28),
                  ),
                ],
              ),
            ),

            // Daily / Weekly / Monthly tabs
            TabBar(
              controller: _tabController,
              onTap: (_) => setState(() {}),
              labelColor: accent,
              unselectedLabelColor: mutedColor,
              indicatorColor: accent,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(text: 'Daily'),
                Tab(text: 'Weekly'),
                Tab(text: 'Monthly'),
              ],
            ),

            // Category filter chips
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _CategoryChip(
                    label: 'All',
                    isSelected: _selectedCategory == null,
                    accent: accent,
                    onTap: () => setState(() => _selectedCategory = null),
                  ),
                  ...QuestCategory.values.map((category) => _CategoryChip(
                        label: category.label,
                        isSelected: _selectedCategory == category,
                        accent: accent,
                        onTap: () => setState(() => _selectedCategory = category),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Quest list for the active tab + filter
            Expanded(
              child: Builder(
                builder: (context) {
                  final quests = _questsForCurrentTab();
                  if (quests.isEmpty) {
                    return Center(
                      child: Text('No quests here yet.', style: TextStyle(color: mutedColor, fontSize: 13)),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: quests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final quest = quests[index];
                      return _QuestCard(quest: quest, cardColor: cardColor, accent: accent, mutedColor: mutedColor);
                    },
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? accent : Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Theme.of(context).scaffoldBackgroundColor
                  : Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  final Quest quest;
  final Color? cardColor;
  final Color accent;
  final Color? mutedColor;

  const _QuestCard({
    required this.quest,
    required this.cardColor,
    required this.accent,
    required this.mutedColor,
  });

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
            decoration: BoxDecoration(
              color: (quest.completed ? mutedColor : accent)!.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(quest.category.icon, size: 18, color: quest.completed ? mutedColor : accent),
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
          Text(
            '+${quest.xp} XP',
            style: TextStyle(color: quest.completed ? accent : mutedColor, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}