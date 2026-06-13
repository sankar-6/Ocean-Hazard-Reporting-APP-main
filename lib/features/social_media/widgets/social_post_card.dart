import 'package:flutter/material.dart';

import '../../../models/social_media_post.dart';
import '../../../core/theme/app_theme.dart';

class SocialPostCard extends StatelessWidget {
  final SocialMediaPost post;
  final VoidCallback? onTap;

  const SocialPostCard({
    super.key,
    required this.post,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Platform Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getPlatformColor(post.platform).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getPlatformIcon(post.platform),
                      size: 20,
                      color: _getPlatformColor(post.platform),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Author Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (post.authorHandle != null)
                          Text(
                            post.authorHandle!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Sentiment Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getSentimentColor(post.sentiment).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getSentimentIcon(post.sentiment),
                          size: 14,
                          color: _getSentimentColor(post.sentiment),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          post.sentimentDisplayName,
                          style: TextStyle(
                            color: _getSentimentColor(post.sentiment),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Content
              Text(
                post.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              
              // Hashtags
              if (post.hashtags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: post.hashtags.map((hashtag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$hashtag',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Location and Time
              Row(
                children: [
                  if (post.hasLocation) ...[
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        post.location ?? 'Unknown location',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimeAgo(post.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Engagement Stats
              Row(
                children: [
                  _buildEngagementItem(Icons.favorite, post.likes.toString()),
                  const SizedBox(width: 16),
                  _buildEngagementItem(Icons.share, post.shares.toString()),
                  const SizedBox(width: 16),
                  _buildEngagementItem(Icons.comment, post.comments.toString()),
                  
                  const Spacer(),
                  
                  // Hazard Related Badge
                  if (post.isHazardRelated)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.dangerColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning,
                            size: 14,
                            color: AppTheme.dangerColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Hazard Related',
                            style: TextStyle(
                              color: AppTheme.dangerColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEngagementItem(IconData icon, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'twitter':
        return Colors.blue;
      case 'facebook':
        return Colors.indigo;
      case 'youtube':
        return Colors.red;
      case 'instagram':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'twitter':
        return Icons.alternate_email;
      case 'facebook':
        return Icons.facebook;
      case 'youtube':
        return Icons.play_circle;
      case 'instagram':
        return Icons.camera_alt;
      default:
        return Icons.social_distance;
    }
  }

  Color _getSentimentColor(SentimentType sentiment) {
    switch (sentiment) {
      case SentimentType.positive:
        return AppTheme.successColor;
      case SentimentType.negative:
        return AppTheme.dangerColor;
      case SentimentType.neutral:
        return Colors.grey;
      case SentimentType.urgent:
        return AppTheme.warningColor;
    }
  }

  IconData _getSentimentIcon(SentimentType sentiment) {
    switch (sentiment) {
      case SentimentType.positive:
        return Icons.sentiment_satisfied;
      case SentimentType.negative:
        return Icons.sentiment_dissatisfied;
      case SentimentType.neutral:
        return Icons.sentiment_neutral;
      case SentimentType.urgent:
        return Icons.priority_high;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
