import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'progress_photo_provider.dart';
import 'models/progress_photo.dart';

class PhotosTab extends ConsumerStatefulWidget {
  const PhotosTab({super.key});

  @override
  ConsumerState<PhotosTab> createState() => _PhotosTabState();
}

class _PhotosTabState extends ConsumerState<PhotosTab> {
  bool _isUploading = false;
  final Map<String, String> _signedUrlCache = {};

  Future<void> _uploadPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final fileName = pickedFile.name;
      final storagePath =
          '$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final file = File(pickedFile.path);
      final fileSize = await file.length();

      await Supabase.instance.client.storage
          .from('progress-photos')
          .upload(storagePath, file);

      await ref.read(progressPhotoProvider.notifier).uploadPhoto(
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

  Future<String> _getSignedUrl(String storagePath) async {
    if (_signedUrlCache.containsKey(storagePath)) {
      return _signedUrlCache[storagePath]!;
    }
    final signedUrl = await Supabase.instance.client.storage
        .from('progress-photos')
        .createSignedUrl(storagePath, 300);
    _signedUrlCache[storagePath] = signedUrl;
    return signedUrl;
  }

  Future<void> _deletePhoto(ProgressPhoto photo) async {
    try {
      await Supabase.instance.client.storage
          .from('progress-photos')
          .remove([photo.storagePath]);
      await ref.read(progressPhotoProvider.notifier).deletePhoto(photo.id);
      _signedUrlCache.remove(photo.storagePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  void _showFullPhoto(ProgressPhoto photo) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            FutureBuilder<String>(
              future: _getSignedUrl(photo.storagePath),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return InteractiveViewer(
                  child: Image.network(snapshot.data!),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            Positioned(
              bottom: 8,
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _deletePhoto(photo);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photos = ref.watch(progressPhotoProvider);
    final accent = Theme.of(context).colorScheme.primary;

    return Stack(
      children: [
        photos.isEmpty
            ? const Center(
                child: Text(
                  'No progress photos yet.\nTap + to add your first one.',
                  textAlign: TextAlign.center,
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  return GestureDetector(
                    onTap: () => _showFullPhoto(photo),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FutureBuilder<String>(
                        future: _getSignedUrl(photo.storagePath),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container(
                              color: Theme.of(context).cardTheme.color,
                              child: const Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              ),
                            );
                          }
                          return Image.network(
                            snapshot.data!,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _isUploading ? null : _uploadPhoto,
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