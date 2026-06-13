import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../models/social_media_post.dart';
import '../widgets/social_post_card.dart';
import '../widgets/social_media_filters.dart';

class SocialMediaScreen extends ConsumerStatefulWidget {
  const SocialMediaScreen({super.key});

  @override
  ConsumerState<SocialMediaScreen> createState() => _SocialMediaScreenState();
}

class _SocialMediaScreenState extends ConsumerState<SocialMediaScreen> {
  String _selectedPlatform = 'all';
  String _selectedSentiment = 'all';
  bool _showHazardRelatedOnly = false;

  // Mock data - replace with actual data from provider
  final List<SocialMediaPost> _posts = [
    SocialMediaPost(
      id: '1',
      platform: 'twitter',
      content: 'Just witnessed massive waves at Marina Beach! Stay safe everyone #OceanHazard #Chennai',
      author: 'John Doe',
      authorHandle: '@johndoe',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      likes: 45,
      shares: 12,
      comments: 8,
      latitude: 13.0475,
      longitude: 80.2837,
      location: 'Chennai, India',
      hashtags: ['OceanHazard', 'Chennai'],
      sentiment: SentimentType.urgent,
      confidence: 0.85,
      isHazardRelated: true,
      hazardKeywords: ['waves', 'ocean', 'hazard'],
    ),
    SocialMediaPost(
      id: '2',
      platform: 'facebook',
      content: 'Coastal flooding in our area. Water levels are rising rapidly. Please avoid low-lying areas.',
      author: 'Sarah Wilson',
      authorHandle: 'Sarah Wilson',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      likes: 23,
      shares: 15,
      comments: 5,
      latitude: 12.9716,
      longitude: 77.5946,
      location: 'Bangalore, India',
      hashtags: ['flooding', 'coastal'],
      sentiment: SentimentType.negative,
      confidence: 0.92,
      isHazardRelated: true,
      hazardKeywords: ['flooding', 'coastal', 'water'],
    ),
    SocialMediaPost(
      id: '3',
      platform: 'youtube',
      content: 'Amazing sunset at the beach today! The ocean looks so calm and peaceful.',
      author: 'Mike Johnson',
      authorHandle: 'MikeJ',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      likes: 156,
      shares: 8,
      comments: 23,
      latitude: 19.0760,
      longitude: 72.8777,
      location: 'Mumbai, India',
      hashtags: ['sunset', 'beach', 'ocean'],
      sentiment: SentimentType.positive,
      confidence: 0.78,
      isHazardRelated: false,
      hazardKeywords: [],
    ),
    SocialMediaPost(
      id: '4',
      platform: 'twitter',
      content: 'Storm surge warning issued for coastal areas. Please stay indoors and follow official guidance.',
      author: 'Weather Alert',
      authorHandle: '@weatheralert',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      likes: 89,
      shares: 45,
      comments: 12,
      latitude: 8.5241,
      longitude: 76.9366,
      location: 'Kochi, India',
      hashtags: ['StormSurge', 'WeatherAlert', 'Safety'],
      sentiment: SentimentType.urgent,
      confidence: 0.95,
      isHazardRelated: true,
      hazardKeywords: ['storm', 'surge', 'warning'],
    ),
  ];

  List<SocialMediaPost> get _filteredPosts {
    return _posts.where((post) {
      if (_showHazardRelatedOnly && !post.isHazardRelated) {
        return false;
      }
      
      if (_selectedPlatform != 'all' && post.platform != _selectedPlatform) {
        return false;
      }
      
      if (_selectedSentiment != 'all' && post.sentiment.toString().split('.').last != _selectedSentiment) {
        return false;
      }
      
      return true;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DetailAppBar(
        title: 'Social Media Monitoring',
        actions: [
          IconButton(
            icon: Icon(_showHazardRelatedOnly ? Icons.warning : Icons.warning_outlined),
            onPressed: () {
              setState(() => _showHazardRelatedOnly = !_showHazardRelatedOnly);
            },
            tooltip: 'Show Hazard Related Only',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          SocialMediaFilters(
            selectedPlatform: _selectedPlatform,
            selectedSentiment: _selectedSentiment,
            onPlatformChanged: (platform) {
              setState(() => _selectedPlatform = platform);
            },
            onSentimentChanged: (sentiment) {
              setState(() => _selectedSentiment = sentiment);
            },
          ),
          
          // Statistics
          _buildStatistics(),
          
          // Posts List
          Expanded(
            child: _filteredPosts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = _filteredPosts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SocialPostCard(
                          post: post,
                          onTap: () {
                            // TODO: Navigate to post details
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Post details: ${post.content.substring(0, 50)}...'),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    final hazardRelatedCount = _posts.where((post) => post.isHazardRelated).length;
    final urgentCount = _posts.where((post) => post.sentiment == SentimentType.urgent).length;
    final totalEngagement = _posts.fold(0, (sum, post) => sum + post.totalEngagement);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Hazard Related',
              hazardRelatedCount.toString(),
              Icons.warning,
              AppTheme.dangerColor,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Urgent Posts',
              urgentCount.toString(),
              Icons.priority_high,
              AppTheme.warningColor,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Total Engagement',
              totalEngagement.toString(),
              Icons.trending_up,
              AppTheme.successColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.social_distance,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No social media posts found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or check back later',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
