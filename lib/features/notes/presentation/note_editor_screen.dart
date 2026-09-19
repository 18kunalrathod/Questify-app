import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'models/note.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

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
  bool _isUploadingFile = false;

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

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final localPath = result.single.path!;
    final fileName = result.single.name;
    final storagePath = '$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    setState(() => _isUploadingFile = true);

    try {
      await Supabase.instance.client.storage
          .from('note-attachments')
          .upload(storagePath, File(localPath));

      setState(() {
        _attachedFiles.add(storagePath);
        _isUploadingFile = false;
      });
    } catch (e) {
      setState(() => _isUploadingFile = false);
      debugPrint('Upload failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  void _removeAttachment(String path) {
    setState(() => _attachedFiles.remove(path));
  }

  bool _isImageFile(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');
  }

  Future<void> _openAttachment(String storagePath) async {
    try {
      final signedUrl = await Supabase.instance.client.storage
          .from('note-attachments')
          .createSignedUrl(storagePath, 60);

      if (!mounted) return;

      if (_isImageFile(storagePath)) {
        showDialog(
          context: context,
          builder: (dialogContext) => Dialog(
            backgroundColor: Colors.transparent,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                InteractiveViewer(
                  child: Image.network(signedUrl),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
              ],
            ),
          ),
        );
      } else {
        await launchUrl(Uri.parse(signedUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file: $e')),
        );
      }
    }
  }

  void _saveAndExit() {
    if (_titleController.text.trim().isEmpty) return;

    final note = Note(
      id: widget.note?.id ?? '',
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
                    return GestureDetector(
                      onTap: () => _openAttachment(path),
                      child: Chip(
                        label: Text(fileName, style: const TextStyle(fontSize: 10)),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => _removeAttachment(path),
                        backgroundColor: cardColor,
                      ),
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
                        imageProviderBuilder: (context, imageUrl) {
                          if (imageUrl.startsWith('http')) {
                            return NetworkImage(imageUrl);
                          }
                          return FileImage(File(imageUrl.replaceFirst('file://', '')));
                        },
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
                    _isUploadingFile
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : IconButton(
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