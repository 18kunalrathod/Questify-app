import '../models/quest.dart';

class DailyQuestTemplate {
  final String title;
  final int xp;
  final QuestCategory category;

  const DailyQuestTemplate({
    required this.title,
    required this.xp,
    required this.category,
  });
}

const dailyQuestTemplates = [
  DailyQuestTemplate(title: '20 push-ups', xp: 40, category: QuestCategory.fitness),
  DailyQuestTemplate(title: '15-minute walk', xp: 30, category: QuestCategory.fitness),
  DailyQuestTemplate(title: '5-minute stretch routine', xp: 20, category: QuestCategory.fitness),
  DailyQuestTemplate(title: '30 bodyweight squats', xp: 35, category: QuestCategory.fitness),
  DailyQuestTemplate(title: 'Drink 2L of water today', xp: 25, category: QuestCategory.fitness),
  DailyQuestTemplate(title: '10-minute jog', xp: 40, category: QuestCategory.fitness),

  DailyQuestTemplate(title: '25-minute deep work session', xp: 45, category: QuestCategory.focus),
  DailyQuestTemplate(title: 'No phone for 1 hour while working', xp: 40, category: QuestCategory.focus),
  DailyQuestTemplate(title: 'Clear your inbox to zero', xp: 30, category: QuestCategory.focus),
  DailyQuestTemplate(title: "Plan tomorrow's top 3 priorities", xp: 25, category: QuestCategory.focus),
  DailyQuestTemplate(title: '15 minutes of distraction-free reading', xp: 30, category: QuestCategory.focus),
  DailyQuestTemplate(title: "Finish one task you've been avoiding", xp: 50, category: QuestCategory.focus),

  DailyQuestTemplate(title: 'Read 10 pages of a book', xp: 30, category: QuestCategory.knowledge),
  DailyQuestTemplate(title: 'Watch one educational video (15+ min)', xp: 35, category: QuestCategory.knowledge),
  DailyQuestTemplate(title: 'Learn one new word and use it in a sentence', xp: 15, category: QuestCategory.knowledge),
  DailyQuestTemplate(title: "Read a long-form article on a topic you don't know well", xp: 40, category: QuestCategory.knowledge),
  DailyQuestTemplate(title: 'Write a 3-sentence summary of something you learned recently', xp: 20, category: QuestCategory.knowledge),
  DailyQuestTemplate(title: 'Listen to one podcast episode', xp: 30, category: QuestCategory.knowledge),

  DailyQuestTemplate(title: 'Write in a journal for 5 minutes', xp: 20, category: QuestCategory.personal),
  DailyQuestTemplate(title: "Call or message someone you haven't talked to in a while", xp: 25, category: QuestCategory.personal),
  DailyQuestTemplate(title: 'Tidy one area of your space for 10 minutes', xp: 25, category: QuestCategory.personal),
  DailyQuestTemplate(title: "Do one thing you've been procrastinating on", xp: 45, category: QuestCategory.personal),
  DailyQuestTemplate(title: 'Take a 10-minute break with no screens', xp: 15, category: QuestCategory.personal),
  DailyQuestTemplate(title: 'Say one genuine compliment to someone today', xp: 20, category: QuestCategory.personal),
];