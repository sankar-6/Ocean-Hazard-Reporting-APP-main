import 'package:flutter/material.dart';

class SocialMediaFilters extends StatelessWidget {
  final String selectedPlatform;
  final String selectedSentiment;
  final ValueChanged<String> onPlatformChanged;
  final ValueChanged<String> onSentimentChanged;

  const SocialMediaFilters({
    super.key,
    required this.selectedPlatform,
    required this.selectedSentiment,
    required this.onPlatformChanged,
    required this.onSentimentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Platform Filters
          Text(
            'Platform',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, 'all', 'All', Icons.all_inclusive),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'twitter',
                  'Twitter',
                  Icons.alternate_email,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'facebook',
                  'Facebook',
                  Icons.facebook,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'youtube',
                  'YouTube',
                  Icons.play_circle,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'instagram',
                  'Instagram',
                  Icons.camera_alt,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sentiment Filters
          Text(
            'Sentiment',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSentimentChip(
                  context,
                  'all',
                  'All',
                  Icons.all_inclusive,
                  Colors.grey,
                ),
                const SizedBox(width: 8),
                _buildSentimentChip(
                  context,
                  'positive',
                  'Positive',
                  Icons.sentiment_satisfied,
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _buildSentimentChip(
                  context,
                  'negative',
                  'Negative',
                  Icons.sentiment_dissatisfied,
                  Colors.red,
                ),
                const SizedBox(width: 8),
                _buildSentimentChip(
                  context,
                  'neutral',
                  'Neutral',
                  Icons.sentiment_neutral,
                  Colors.grey,
                ),
                const SizedBox(width: 8),
                _buildSentimentChip(
                  context,
                  'urgent',
                  'Urgent',
                  Icons.priority_high,
                  Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final isSelected = selectedPlatform == value;

    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onPlatformChanged(value);
        }
      },
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selectedColor: Theme.of(context).primaryColor,
      checkmarkColor: Colors.white,
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildSentimentChip(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = selectedSentiment == value;

    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onSentimentChanged(value);
        }
      },
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : color),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selectedColor: color,
      checkmarkColor: Colors.white,
      backgroundColor: color.withOpacity(0.1),
    );
  }
}
