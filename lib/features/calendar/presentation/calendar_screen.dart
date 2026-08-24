import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/ambient_glow_background.dart';

enum CalendarView { month, week, day }

class CalendarEvent {
  final String id;
  final DateTime date;
  final String title;
  final String time;
  final bool isQuestDeadline;

  const CalendarEvent({
    required this.id,
    required this.date,
    required this.title,
    required this.time,
    this.isQuestDeadline = false,
  });

  CalendarEvent copyWith({DateTime? date, String? title, String? time}) {
    return CalendarEvent(
      id: id,
      date: date ?? this.date,
      title: title ?? this.title,
      time: time ?? this.time,
      isQuestDeadline: isQuestDeadline,
    );
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarView _view = CalendarView.week;
  DateTime _selectedDate = DateTime(2026, 8, 17);
  DateTime _visibleMonth = DateTime(2026, 8, 1);

  final List<CalendarEvent> _events = [
    CalendarEvent(id: 'e1', date: DateTime(2026, 8, 17, 9), title: 'Focus session', time: '9:00 AM'),
    CalendarEvent(id: 'e2', date: DateTime(2026, 8, 17, 14), title: 'Ship Questify v1 due', time: '2:00 PM', isQuestDeadline: true),
    CalendarEvent(id: 'e3', date: DateTime(2026, 8, 17, 18), title: 'Gym session', time: '6:00 PM'),
    CalendarEvent(id: 'e4', date: DateTime(2026, 8, 18, 10), title: 'Read 20 pages', time: '10:00 AM'),
    CalendarEvent(id: 'e5', date: DateTime(2026, 8, 20, 15), title: 'Run a 5K due', time: '3:00 PM', isQuestDeadline: true),
  ];

  List<CalendarEvent> get _eventsForSelectedDate {
    return _events.where((e) =>
        e.date.year == _selectedDate.year && e.date.month == _selectedDate.month && e.date.day == _selectedDate.day).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  bool _hasEventsOn(DateTime date) {
    return _events.any((e) => e.date.year == date.year && e.date.month == date.month && e.date.day == date.day);
  }

  List<DateTime> get _currentWeekDays {
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday % 7));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  void _addEvent(String title, TimeOfDay time) {
    setState(() {
      _events.add(CalendarEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, time.hour, time.minute),
        title: title,
        time: time.format(context),
      ));
    });
  }

  void _updateEvent(String id, String title, TimeOfDay time) {
    setState(() {
      final index = _events.indexWhere((e) => e.id == id);
      if (index == -1) return;
      _events[index] = _events[index].copyWith(
        title: title,
        time: time.format(context),
        date: DateTime(_events[index].date.year, _events[index].date.month, _events[index].date.day, time.hour, time.minute),
      );
    });
  }

  void _deleteEvent(String id) {
    setState(() => _events.removeWhere((e) => e.id == id));
  }

  Future<void> _showEventSheet({CalendarEvent? existingEvent}) async {
    final isEditing = existingEvent != null;
    final titleController = TextEditingController(text: existingEvent?.title ?? '');
    TimeOfDay pickedTime = existingEvent != null
        ? TimeOfDay(hour: existingEvent.date.hour, minute: existingEvent.date.minute)
        : TimeOfDay.now();

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
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isEditing ? 'Edit event' : 'New event', style: AppTextStyles.headline(context, size: 17)),
                      if (isEditing)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () {
                            _deleteEvent(existingEvent.id);
                            Navigator.of(sheetContext).pop();
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    autofocus: !isEditing,
                    decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Doctor appointment'),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final result = await showTimePicker(context: context, initialTime: pickedTime);
                      if (result != null) setSheetState(() => pickedTime = result);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                      decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.15)), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 18),
                          const SizedBox(width: 10),
                          Text(pickedTime.format(context)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) return;
                        if (isEditing) {
                          _updateEvent(existingEvent.id, titleController.text.trim(), pickedTime);
                        } else {
                          _addEvent(titleController.text.trim(), pickedTime);
                        }
                        Navigator.of(sheetContext).pop();
                      },
                      child: Text(isEditing ? 'Save changes' : 'Add event'),
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

    return Scaffold(
      appBar: AppBar(title: Text('Calendar', style: AppTextStyles.headline(context, size: 18))),
      body: AmbientGlowBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: CalendarView.values.map((view) {
                      final isActive = _view == view;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _view = view),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(color: isActive ? accent : Colors.transparent, borderRadius: BorderRadius.circular(9)),
                            alignment: Alignment.center,
                            child: Text(
                              view.name[0].toUpperCase() + view.name.substring(1),
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isActive ? Theme.of(context).scaffoldBackgroundColor : mutedColor),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Expanded(
                child: switch (_view) {
                  CalendarView.month => _MonthView(
                      visibleMonth: _visibleMonth,
                      selectedDate: _selectedDate,
                      hasEvents: _hasEventsOn,
                      onDaySelected: (date) => setState(() => _selectedDate = date),
                      onMonthChanged: (date) => setState(() => _visibleMonth = date),
                    ),
                  CalendarView.week => _WeekView(
                      weekDays: _currentWeekDays,
                      selectedDate: _selectedDate,
                      hasEvents: _hasEventsOn,
                      onDaySelected: (date) => setState(() => _selectedDate = date),
                      events: _eventsForSelectedDate,
                      onEventTap: (event) => _showEventSheet(existingEvent: event),
                    ),
                  CalendarView.day => _DayView(
                      selectedDate: _selectedDate,
                      events: _eventsForSelectedDate,
                      onEventTap: (event) => _showEventSheet(existingEvent: event),
                    ),
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventSheet(),
        backgroundColor: accent,
        child: Icon(Icons.add, color: Theme.of(context).scaffoldBackgroundColor),
      ),
    );
  }
}

class _MonthView extends StatelessWidget {
  final DateTime visibleMonth;
  final DateTime selectedDate;
  final bool Function(DateTime) hasEvents;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onMonthChanged;

  const _MonthView({
    required this.visibleMonth,
    required this.selectedDate,
    required this.hasEvents,
    required this.onDaySelected,
    required this.onMonthChanged,
  });

  static const _monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    final firstOfMonth = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final daysInMonth = DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
    final leadingEmptyDays = firstOfMonth.weekday % 7;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => onMonthChanged(DateTime(visibleMonth.year, visibleMonth.month - 1))),
            Text('${_monthNames[visibleMonth.month - 1]} ${visibleMonth.year}', style: AppTextStyles.headline(context, size: 15)),
            IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => onMonthChanged(DateTime(visibleMonth.year, visibleMonth.month + 1))),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
          itemCount: leadingEmptyDays + daysInMonth,
          itemBuilder: (context, index) {
            if (index < leadingEmptyDays) return const SizedBox();
            final day = index - leadingEmptyDays + 1;
            final date = DateTime(visibleMonth.year, visibleMonth.month, day);
            final isSelected = date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day;

            return GestureDetector(
              onTap: () => onDaySelected(date),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(color: isSelected ? accent : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$day', style: TextStyle(fontSize: 12, color: isSelected ? Theme.of(context).scaffoldBackgroundColor : null)),
                    if (hasEvents(date) && !isSelected)
                      Container(width: 4, height: 4, margin: const EdgeInsets.only(top: 2), decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _WeekView extends StatelessWidget {
  final List<DateTime> weekDays;
  final DateTime selectedDate;
  final bool Function(DateTime) hasEvents;
  final ValueChanged<DateTime> onDaySelected;
  final List<CalendarEvent> events;
  final ValueChanged<CalendarEvent> onEventTap;

  const _WeekView({
    required this.weekDays,
    required this.selectedDate,
    required this.hasEvents,
    required this.onDaySelected,
    required this.events,
    required this.onEventTap,
  });

  static const _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardTheme.color;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Row(
          children: weekDays.asMap().entries.map((entry) {
            final date = entry.value;
            final isSelected = date.day == selectedDate.day && date.month == selectedDate.month;
            return Expanded(
              child: GestureDetector(
                onTap: () => onDaySelected(date),
                child: Column(
                  children: [
                    Text(_dayLabels[entry.key], style: TextStyle(fontSize: 9, color: mutedColor)),
                    const SizedBox(height: 6),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: isSelected ? accent : Colors.transparent, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text('${date.day}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Theme.of(context).scaffoldBackgroundColor : null)),
                    ),
                    const SizedBox(height: 4),
                    if (hasEvents(date)) Container(width: 4, height: 4, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        if (events.isEmpty)
          Padding(padding: const EdgeInsets.only(top: 30), child: Center(child: Text('No events this day', style: TextStyle(color: mutedColor, fontSize: 12))))
        else
          ...events.map((event) => _EventTile(event: event, cardColor: cardColor, accent: accent, mutedColor: mutedColor, onTap: () => onEventTap(event))),
      ],
    );
  }
}

class _DayView extends StatelessWidget {
  final DateTime selectedDate;
  final List<CalendarEvent> events;
  final ValueChanged<CalendarEvent> onEventTap;

  const _DayView({required this.selectedDate, required this.events, required this.onEventTap});

  static const _monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardTheme.color;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Text('${_monthNames[selectedDate.month - 1]} ${selectedDate.day}, ${selectedDate.year}', style: AppTextStyles.headline(context, size: 17)),
        const SizedBox(height: 16),
        if (events.isEmpty)
          Padding(padding: const EdgeInsets.only(top: 30), child: Center(child: Text('No events this day', style: TextStyle(color: mutedColor, fontSize: 12))))
        else
          ...events.map((event) => _EventTile(event: event, cardColor: cardColor, accent: accent, mutedColor: mutedColor, onTap: () => onEventTap(event))),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  final CalendarEvent event;
  final Color? cardColor;
  final Color accent;
  final Color? mutedColor;
  final VoidCallback onTap;

  const _EventTile({required this.event, required this.cardColor, required this.accent, required this.mutedColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: event.isQuestDeadline ? accent.withOpacity(0.1) : cardColor,
          border: event.isQuestDeadline ? Border.all(color: accent) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(width: 3, height: 30, decoration: BoxDecoration(color: event.isQuestDeadline ? accent : mutedColor, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: event.isQuestDeadline ? accent : null)),
                  const SizedBox(height: 2),
                  Text(event.time, style: TextStyle(fontSize: 10, color: mutedColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}