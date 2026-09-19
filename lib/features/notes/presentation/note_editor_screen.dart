import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'models/note.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note; // null = creating a new note

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final quill.QuillController _quillController;
  late NoteCategory _category;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _quillController = quill.QuillController(
      document: widget.note?.content ?? quill.Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _category = widget.note?.category ?? NoteCategory.personal;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  void _saveAndExit() {
    if (_titleController.text.trim().isEmpty) return;

    final note = Note(
      id: widget.note?.id ?? '',
      title: _titleController.text.trim(),
      category: _category,
      content: _quillController.document,
      updatedAt: DateTime.now(),
      attachedFilePaths: widget.note?.attachedFilePaths ?? const [],
    );

    Navigator.of(context).pop(note);
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardTheme.color;
    final categoryColor = _category.accentColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit note' : 'New note'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveAndExit),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _category.icon,
                      size: 28,
                      color: categoryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    decoration: const InputDecoration(
                      hintText: 'Note title',
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: NoteCategory.values.map((cat) {
                        final isSelected = _category == cat;
                        final chipColor = cat.accentColor;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _category = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected ? chipColor : cardColor,
                                border: isSelected
                                    ? null
                                    : Border.all(color: Colors.white.withOpacity(0.08)),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                cat.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Theme.of(context).scaffoldBackgroundColor
                                      : mutedColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: quill.QuillEditor.basic(
                  controller: _quillController,
                ),
              ),
            ),

            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cardColor,
                  border: const Border(top: BorderSide(color: Colors.transparent)),
                ),
                child: quill.QuillSimpleToolbar(
                  controller: _quillController,
                  config: quill.QuillSimpleToolbarConfig(
                    showFontFamily: false,
                    showFontSize: false,
                    showColorButton: false,
                    showBackgroundColorButton: false,
                    showClearFormat: false,
                    showAlignmentButtons: false,
                    showQuote: false,
                    showLink: false,
                    showUnderLineButton: false,
                    showItalicButton: false,
                    showBoldButton: false,
                    showListNumbers: false,
                    showSearchButton: false,
                    showCodeBlock: false,
                    showInlineCode: false,
                    showSubscript: false,
                    showSuperscript: false,
                    showIndent: false,
                    showHeaderStyle: false,
                    showDividers: false,
                    embedButtons: const [],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}