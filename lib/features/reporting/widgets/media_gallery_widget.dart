import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

class MediaGalleryWidget extends StatefulWidget {
  final List<String> imageUrls;
  final List<String> videoUrls;

  const MediaGalleryWidget({
    super.key,
    required this.imageUrls,
    required this.videoUrls,
  });

  @override
  State<MediaGalleryWidget> createState() => _MediaGalleryWidgetState();
}

class _MediaGalleryWidgetState extends State<MediaGalleryWidget> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> allMedia = [...widget.imageUrls, ...widget.videoUrls];
    
    if (allMedia.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Media viewer
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[100],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: allMedia.length,
              itemBuilder: (context, index) {
                final String mediaUrl = allMedia[index];
                final bool isVideo = widget.videoUrls.contains(mediaUrl);

                return GestureDetector(
                  onTap: () => _openFullScreenMedia(mediaUrl, isVideo),
                  child: isVideo
                      ? _buildVideoThumbnail(mediaUrl)
                      : _buildImageWidget(mediaUrl),
                );
              },
            ),
          ),
        ),

        // Media indicators
        if (allMedia.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              allMedia.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300],
                ),
              ),
            ),
          ),
        ],

        // Media thumbnails
        if (allMedia.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: allMedia.length,
              itemBuilder: (context, index) {
                final String mediaUrl = allMedia[index];
                final bool isVideo = widget.videoUrls.contains(mediaUrl);
                final bool isSelected = _currentIndex == index;

                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          isVideo
                              ? _buildVideoThumbnail(mediaUrl, isSmall: true)
                              : _buildImageWidget(mediaUrl, isSmall: true),
                          if (isVideo)
                            const Center(
                              child: Icon(
                                Icons.play_circle_filled,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageWidget(String imageUrl, {bool isSmall = false}) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              color: Colors.grey[400],
              size: isSmall ? 24 : 48,
            ),
            if (!isSmall) ...[
              const SizedBox(height: 8),
              Text(
                'Failed to load image',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail(String videoUrl, {bool isSmall = false}) {
    // For now, show a placeholder with play icon
    // TODO: Implement actual video thumbnail generation
    return Container(
      color: Colors.grey[800],
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.videocam,
              color: Colors.white,
              size: isSmall ? 24 : 48,
            ),
          ),
          Center(
            child: Icon(
              Icons.play_circle_filled,
              color: Colors.white,
              size: isSmall ? 32 : 64,
            ),
          ),
          if (!isSmall)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'VIDEO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openFullScreenMedia(String mediaUrl, bool isVideo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenMediaViewer(
          mediaUrl: mediaUrl,
          isVideo: isVideo,
        ),
      ),
    );
  }
}

class FullScreenMediaViewer extends StatefulWidget {
  final String mediaUrl;
  final bool isVideo;

  const FullScreenMediaViewer({
    super.key,
    required this.mediaUrl,
    required this.isVideo,
  });

  @override
  State<FullScreenMediaViewer> createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl));
      await _videoController!.initialize();
      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () {
              // TODO: Implement download functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download functionality coming soon')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: widget.isVideo
            ? _buildVideoPlayer()
            : _buildFullScreenImage(),
      ),
    );
  }

  Widget _buildFullScreenImage() {
    return InteractiveViewer(
      panEnabled: true,
      boundaryMargin: const EdgeInsets.all(20),
      minScale: 0.5,
      maxScale: 4.0,
      child: CachedNetworkImage(
        imageUrl: widget.mediaUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        errorWidget: (context, url, error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image,
                color: Colors.grey[400],
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load image',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (!_isVideoInitialized || _videoController == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Stack(
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        ),
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (_videoController!.value.isPlaying) {
                  _videoController!.pause();
                } else {
                  _videoController!.play();
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _videoController!.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: VideoProgressIndicator(
            _videoController!,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: Theme.of(context).primaryColor,
              bufferedColor: Colors.grey,
              backgroundColor: Colors.grey[800]!,
            ),
          ),
        ),
      ],
    );
  }
}
