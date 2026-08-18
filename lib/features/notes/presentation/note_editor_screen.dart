import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
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
  late List<String> _attachedFiles;

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
    _attachedFiles = List.from(widget.note?.attachedFilePaths ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  Future<void> _attachFile() async {
   final result = await FilePicker.pickFiles(allowMultiple: false);
    if (result == null || result.single.path == null) return;
    setState(() => _attachedFiles.add(result.single.path!));
  }

  void _removeAttachment(String path) {
    setState(() => _attachedFiles.remove(path));
  }

  void _saveAndExit() {
    if (_titleController.text.trim().isEmpty) return;

    final note = Note(
      id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      category: _category,
      content: _quillController.document,
      updatedAt: DateTime.now(),
      attachedFilePaths: _attachedFiles,
    );

    Navigator.of(context).pop(note);
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardTheme.color;

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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    decoration: const InputDecoration(hintText: 'Note title', border: InputBorder.none),
                  ),
                  const SizedBox(height: 8),
                  // Category picker
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: NoteCategory.values.map((cat) {
                        final isSelected = _category == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () => setState(() => _category = cat),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isSelected ? accent.withOpacity(0.15) : cardColor,
                                border: isSelected ? Border.all(color: accent) : null,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              alignment: Alignment.center,
                              child: Text(cat.label, style: TextStyle(fontSize: 10, color: isSelected ? accent : mutedColor)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Attached files, shown as a horizontal chip row if any exist
            if (_attachedFiles.isNotEmpty)
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _attachedFiles.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final path = _attachedFiles[index];
                    final fileName = path.split('/').last;
                    return Chip(
                      label: Text(fileName, style: const TextStyle(fontSize: 10)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => _removeAttachment(path),
                      backgroundColor: cardColor,
                    );
                  },
                ),
              ),

            const Divider(height: 1),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: quill.QuillEditor.basic(
                  controller: _quillController,
                  config: quill.QuillEditorConfig(
                    embedBuilders: FlutterQuillEmbeds.editorBuilders(
                      imageEmbedConfig: QuillEditorImageEmbedConfig(
                        imageProviderBuilder: (context, imageUrl) => NetworkImage(imageUrl),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: cardColor, border: const Border(top: BorderSide(color: Colors.transparent))),
                child: Row(
                  children: [
                    Expanded(
                      child: quill.QuillSimpleToolbar(
                        controller: _quillController,
                        config: quill.QuillSimpleToolbarConfig(
                          embedButtons: FlutterQuillEmbeds.toolbarButtons(),
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
                          showListNumbers: false,
                          showSearchButton: false,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file, size: 20),
                      onPressed: _attachFile,
                      tooltip: 'Attach file',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}