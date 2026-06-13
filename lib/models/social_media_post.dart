import 'package:geolocator/geolocator.dart';

enum SocialMediaPlatform {
  twitter,
  facebook,
  youtube,
  instagram,
  other,
}

enum SentimentType {
  positive,
  negative,
  neutral,
  urgent,
}

class SocialMediaPost {
  final String id;
  final String platform;
  final String content;
  final String author;
  final String? authorHandle;
  final String? authorProfileImage;
  final DateTime createdAt;
  final int likes;
  final int shares;
  final int comments;
  final double? latitude;
  final double? longitude;
  final String? location;
  final List<String> hashtags;
  final List<String> mentions;
  final List<String> mediaUrls;
  final SentimentType sentiment;
  final double confidence;
  final bool isHazardRelated;
  final List<String> hazardKeywords;
  final String? language;
  final Map<String, dynamic>? metadata;

  SocialMediaPost({
    required this.id,
    required this.platform,
    required this.content,
    required this.author,
    this.authorHandle,
    this.authorProfileImage,
    required this.createdAt,
    this.likes = 0,
    this.shares = 0,
    this.comments = 0,
    this.latitude,
    this.longitude,
    this.location,
    this.hashtags = const [],
    this.mentions = const [],
    this.mediaUrls = const [],
    this.sentiment = SentimentType.neutral,
    this.confidence = 0.0,
    this.isHazardRelated = false,
    this.hazardKeywords = const [],
    this.language,
    this.metadata,
  });

  factory SocialMediaPost.fromJson(Map<String, dynamic> json) {
    return SocialMediaPost(
      id: json['id'] as String,
      platform: json['platform'] as String,
      content: json['content'] as String,
      author: json['author'] as String,
      authorHandle: json['authorHandle'] as String?,
      authorProfileImage: json['authorProfileImage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likes: json['likes'] as int? ?? 0,
      shares: json['shares'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      location: json['location'] as String?,
      hashtags: List<String>.from(json['hashtags'] ?? []),
      mentions: List<String>.from(json['mentions'] ?? []),
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      sentiment: SentimentType.values.firstWhere(
        (e) => e.toString() == 'SentimentType.${json['sentiment']}',
        orElse: () => SentimentType.neutral,
      ),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      isHazardRelated: json['isHazardRelated'] as bool? ?? false,
      hazardKeywords: List<String>.from(json['hazardKeywords'] ?? []),
      language: json['language'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platform': platform,
      'content': content,
      'author': author,
      'authorHandle': authorHandle,
      'authorProfileImage': authorProfileImage,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'shares': shares,
      'comments': comments,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'hashtags': hashtags,
      'mentions': mentions,
      'mediaUrls': mediaUrls,
      'sentiment': sentiment.toString().split('.').last,
      'confidence': confidence,
      'isHazardRelated': isHazardRelated,
      'hazardKeywords': hazardKeywords,
      'language': language,
      'metadata': metadata,
    };
  }

  Position? get position {
    if (latitude != null && longitude != null) {
      return Position(
        latitude: latitude!,
        longitude: longitude!,
        timestamp: createdAt,
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        headingAccuracy: 0,
        
      );
    }
    return null;
  }

  String get sentimentDisplayName {
    switch (sentiment) {
      case SentimentType.positive:
        return 'Positive';
      case SentimentType.negative:
        return 'Negative';
      case SentimentType.neutral:
        return 'Neutral';
      case SentimentType.urgent:
        return 'Urgent';
    }
  }

  String get platformDisplayName {
    switch (platform.toLowerCase()) {
      case 'twitter':
        return 'Twitter';
      case 'facebook':
        return 'Facebook';
      case 'youtube':
        return 'YouTube';
      case 'instagram':
        return 'Instagram';
      default:
        return 'Other';
    }
  }

  int get totalEngagement => likes + shares + comments;

  bool get hasLocation => latitude != null && longitude != null;
}
