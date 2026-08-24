import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'models/note.dart';
import 'note_editor_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/ambient_glow_background.dart';

final List<Note> _notes = [
  Note(
    id: 'n1',
    title: 'Flutter riverpod notes',
    category: NoteCategory.programming,
    content: quill.Document()..insert(0, 'StateProvider vs StateNotifier — use the latter for complex logic.'),
    updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Note(
    id: 'n2',
    title: 'Push day routine',
    category: NoteCategory.gym,
    content: quill.Document()..insert(0, 'Bench press 4x8, Incline dumbbell press 3x10'),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Note(
    id: 'n3',
    title: 'App feature ideas',
    category: NoteCategory.ideas,
    content: quill.Document()..insert(0, 'Widget for home screen showing today\'s quests.'),
    updatedAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
];

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  NoteCategory? _selectedCategory;

  List<Note> get _filteredNotes {
    if (_selectedCategory == null) return _notes;
    return _notes.where((n) => n.category == _selectedCategory).toList();
  }

  void _openNote(Note? note) async {
    final result = await Navigator.of(context).push<Note>(MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)));
    if (result == null) return;
    setState(() {
      final index = _notes.indexWhere((n) => n.id == result.id);
      if (index == -1) {
        _notes.insert(0, result);
      } else {
        _notes[index] = result;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardTheme.color;

    return Scaffold(
      appBar: AppBar(title: Text('The Ledger', style: AppTextStyles.headline(context, size: 18))),
      body: AmbientGlowBackground(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    _CategoryChip(label: 'All', isSelected: _selectedCategory == null, accent: accent, onTap: () => setState(() => _selectedCategory = null)),
                    ...NoteCategory.values.map((c) => _CategoryChip(
                          label: c.label,
                          isSelected: _selectedCategory == c,
                          accent: accent,
                          onTap: () => setState(() => _selectedCategory = c),
                        )),
                  ],
                ),
              ),
              Expanded(
                child: _filteredNotes.isEmpty
                    ? Center(child: Text('No notes yet.', style: TextStyle(color: mutedColor, fontSize: 13)))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        itemCount: _filteredNotes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final note = _filteredNotes[index];
                          return GestureDetector(
                            onTap: () => _openNote(note),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(note.title, style: AppTextStyles.headline(context, size: 14))),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: accent.withOpacity(0.12), borderRadius: BorderRadius.circular(99)),
                                        child: Text(note.category.label, style: TextStyle(fontSize: 9, color: accent, fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(note.preview, style: TextStyle(fontSize: 11, color: mutedColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 6),
                                  Text(_relativeTime(note.updatedAt), style: TextStyle(fontSize: 9, color: mutedColor)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNote(null),
        backgroundColor: accent,
        child: Icon(Icons.add, color: Theme.of(context).scaffoldBackgroundColor),
      ),
    );
  }

  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
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