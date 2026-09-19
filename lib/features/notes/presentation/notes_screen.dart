import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import 'models/note.dart';
import 'note_editor_screen.dart';
import 'note_provider.dart';

class NotesTab extends ConsumerStatefulWidget {
  const NotesTab({super.key});

  @override
  ConsumerState<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends ConsumerState<NotesTab> {
  NoteCategory? _selectedCategory;

  List<Note> _filteredNotes(List<Note> notes) {
    if (_selectedCategory == null) return notes;

    return notes
        .where((note) => note.category == _selectedCategory)
        .toList();
  }

  Future<void> _openNote(Note? note) async {
    final result = await Navigator.of(context).push<Note>(
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(note: note),
      ),
    );

    if (result == null) return;

    try {
      await ref.read(noteProvider.notifier).saveNote(result);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save this note. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardTheme.color;
    final notes = ref.watch(noteProvider);
    final filteredNotes = _filteredNotes(notes);

    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    _CategoryChip(
                      label: 'All notes',
                      isSelected: _selectedCategory == null,
                      accent: accent,
                      onTap: () => setState(() {
                        _selectedCategory = null;
                      }),
                    ),
                    ...NoteCategory.values.map(
                      (category) => _CategoryChip(
                        label: category.label,
                        isSelected: _selectedCategory == category,
                        accent: accent,
                        onTap: () => setState(() {
                          _selectedCategory = category;
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredNotes.isEmpty
                    ? Center(
                        child: Text(
                          'No notes yet.',
                          style: TextStyle(
                            color: mutedColor,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                        itemCount: filteredNotes.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final note = filteredNotes[index];
                          final categoryColor = note.category.accentColor;

                          return GestureDetector(
                            onTap: () => _openNote(note),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cardColor,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.06),
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: categoryColor.withOpacity(0.12),
                                      borderRadius:
                                          BorderRadius.circular(11),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      note.category.icon,
                                      size: 18,
                                      color: categoryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          note.title,
                                          style: AppTextStyles.headline(
                                            context,
                                            size: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          note.preview,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: mutedColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _relativeTime(note.updatedAt),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: mutedColor?.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () => _openNote(null),
            backgroundColor: accent,
            child: Icon(
              Icons.add,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
        ),
      ],
    );
  }

  String _relativeTime(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    }

    if (difference.inDays == 1) return 'Yesterday';

    return '${difference.inDays} days ago';
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
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected ? accent : Theme.of(context).cardTheme.color,
            border: isSelected
                ? null
                : Border.all(color: Colors.white.withOpacity(0.08)),
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