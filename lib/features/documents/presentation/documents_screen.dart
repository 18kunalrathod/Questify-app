import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'document_provider.dart';
import 'models/document.dart';

class DocumentsTab extends ConsumerStatefulWidget {
  const DocumentsTab({super.key});

  @override
  ConsumerState<DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends ConsumerState<DocumentsTab> {
  bool _isUploading = false;

  Future<void> _uploadDocument() async {
    final result = await FilePicker.pickFiles(allowMultiple: false);
    if (result.isEmpty) return;

    final localPath = result.single.path!;
    final fileName = result.single.name;
    final fileSize = await File(localPath).length();

    setState(() => _isUploading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final storagePath =
          '$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      await Supabase.instance.client.storage
          .from('documents')
          .upload(storagePath, File(localPath));

      await ref.read(documentProvider.notifier).uploadDocument(
            fileName: fileName,
            storagePath: storagePath,
            fileSizeBytes: fileSize,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _openDocument(Document doc) async {
    try {
      final signedUrl = await Supabase.instance.client.storage
          .from('documents')
          .createSignedUrl(doc.storagePath, 60);

      await launchUrl(Uri.parse(signedUrl), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file: $e')),
        );
      }
    }
  }

  Future<void> _deleteDocument(Document doc) async {
    try {
      await Supabase.instance.client.storage
          .from('documents')
          .remove([doc.storagePath]);
      await ref.read(documentProvider.notifier).deleteDocument(doc.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  IconData _iconForExtension(String ext) {
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image_outlined;
      case 'xls':
      case 'xlsx':
        return Icons.grid_on_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  String _formattedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final documents = ref.watch(documentProvider);
    final accent = Theme.of(context).colorScheme.primary;

    return Stack(
      children: [
        documents.isEmpty
            ? const Center(
                child: Text(
                  'No documents yet.\nTap + to upload your first file.',
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final doc = documents[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Icon(_iconForExtension(doc.fileExtension)),
                      title: Text(
                        doc.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${doc.formattedSize} · ${_formattedDate(doc.createdAt)}',
                      ),
                      onTap: () => _openDocument(doc),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteDocument(doc),
                      ),
                    ),
                  );
                },
              ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _isUploading ? null : _uploadDocument,
            backgroundColor: accent,
            child: _isUploading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  )
                : Icon(
                    Icons.add,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
          ),
        ),
      ],
    );
  }
}