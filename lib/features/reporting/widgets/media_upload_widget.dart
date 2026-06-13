import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/storage_service.dart';

class MediaUploadWidget extends StatefulWidget {
  final List<String> mediaUrls;
  final ValueChanged<List<String>> onMediaChanged;
  final int maxFiles;

  const MediaUploadWidget({
    super.key,
    required this.mediaUrls,
    required this.onMediaChanged,
    this.maxFiles = 5,
  });

  @override
  State<MediaUploadWidget> createState() => _MediaUploadWidgetState();
}

class _MediaUploadWidgetState extends State<MediaUploadWidget> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    if (widget.mediaUrls.length >= widget.maxFiles) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum ${widget.maxFiles} files allowed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // Upload image to Firebase Storage
        try {
          final downloadUrl = await StorageService.uploadImage(
            imagePath: image.path,
          );
          final newUrls = [...widget.mediaUrls, downloadUrl];
          widget.onMediaChanged(newUrls);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload image: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    if (widget.mediaUrls.length >= widget.maxFiles) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum ${widget.maxFiles} files allowed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 2),
      );

      if (video != null) {
        // Upload video to Firebase Storage
        try {
          final downloadUrl = await StorageService.uploadVideo(
            videoPath: video.path,
          );
          final newUrls = [...widget.mediaUrls, downloadUrl];
          widget.onMediaChanged(newUrls);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload video: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick video: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _removeMedia(int index) {
    final newUrls = List<String>.from(widget.mediaUrls);
    newUrls.removeAt(index);
    widget.onMediaChanged(newUrls);
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Library'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Record Video'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Video Library'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Media Grid
        if (widget.mediaUrls.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount:
                widget.mediaUrls.length +
                (widget.mediaUrls.length < widget.maxFiles ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == widget.mediaUrls.length) {
                // Add button
                return _buildAddButton();
              }

              // Media item
              return _buildMediaItem(index);
            },
          )
        else
          _buildEmptyState(),

        // Upload Progress
        if (_isUploading)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  'Uploading media...',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Add Photos or Videos',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Help others understand the situation better',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showImageSourceDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Media'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey[300]!,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 32, color: Colors.grey[600]),
            const SizedBox(height: 4),
            Text(
              'Add',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaItem(int index) {
    final mediaUrl = widget.mediaUrls[index];
    final isVideo =
        mediaUrl.toLowerCase().contains('.mp4') ||
        mediaUrl.toLowerCase().contains('.mov') ||
        mediaUrl.toLowerCase().contains('.avi');

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isVideo
                ? _buildVideoThumbnail(mediaUrl)
                : _buildImageThumbnail(mediaUrl),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeMedia(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
        if (isVideo)
          const Positioned(
            bottom: 4,
            right: 4,
            child: Icon(
              Icons.play_circle_filled,
              color: Colors.white,
              size: 24,
            ),
          ),
      ],
    );
  }

  Widget _buildImageThumbnail(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      // Firebase Storage URL or any HTTP URL
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) =>
            Container(color: Colors.grey[200], child: const Icon(Icons.error)),
      );
    } else {
      // Local file (for preview before upload)
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Container(color: Colors.grey[200], child: const Icon(Icons.error)),
      );
    }
  }

  Widget _buildVideoThumbnail(String videoUrl) {
    // TODO: Implement video thumbnail generation
    return Container(
      color: Colors.grey[200],
      child: const Center(child: Icon(Icons.videocam, size: 32)),
    );
  }
}
