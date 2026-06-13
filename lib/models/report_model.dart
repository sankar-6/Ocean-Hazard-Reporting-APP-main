import 'package:geolocator/geolocator.dart';

enum HazardType {
  tsunami,
  stormSurge,
  highWaves,
  coastalFlooding,
  abnormalTides,
  coastalErosion,
  other,
}

enum ReportStatus {
  pending,
  verified,
  rejected,
  underReview,
}

enum ReportSeverity {
  low,
  medium,
  high,
  critical,
}

class ReportModel {
  final String id;
  final String userId;
  final String userName;
  final HazardType hazardType;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String? address;
  final List<String> mediaUrls;
  final ReportStatus status;
  final ReportSeverity severity;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final String? verificationNotes;
  final Map<String, dynamic>? metadata;
  final bool isOffline;

  ReportModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.hazardType,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.address,
    this.mediaUrls = const [],
    this.status = ReportStatus.pending,
    this.severity = ReportSeverity.medium,
    required this.createdAt,
    this.updatedAt,
    this.verifiedBy,
    this.verifiedAt,
    this.verificationNotes,
    this.metadata,
    this.isOffline = false,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      hazardType: HazardType.values.firstWhere(
        (e) => e.toString() == 'HazardType.${json['hazardType']}',
        orElse: () => HazardType.other,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      status: ReportStatus.values.firstWhere(
        (e) => e.toString() == 'ReportStatus.${json['status']}',
        orElse: () => ReportStatus.pending,
      ),
      severity: ReportSeverity.values.firstWhere(
        (e) => e.toString() == 'ReportSeverity.${json['severity']}',
        orElse: () => ReportSeverity.medium,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      verifiedBy: json['verifiedBy'] as String?,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'] as String)
          : null,
      verificationNotes: json['verificationNotes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isOffline: json['isOffline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'hazardType': hazardType.toString().split('.').last,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'mediaUrls': mediaUrls,
      'status': status.toString().split('.').last,
      'severity': severity.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'verificationNotes': verificationNotes,
      'metadata': metadata,
      'isOffline': isOffline,
    };
  }

  ReportModel copyWith({
    String? id,
    String? userId,
    String? userName,
    HazardType? hazardType,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    List<String>? mediaUrls,
    ReportStatus? status,
    ReportSeverity? severity,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? verifiedBy,
    DateTime? verifiedAt,
    String? verificationNotes,
    Map<String, dynamic>? metadata,
    bool? isOffline,
  }) {
    return ReportModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      hazardType: hazardType ?? this.hazardType,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      status: status ?? this.status,
      severity: severity ?? this.severity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verificationNotes: verificationNotes ?? this.verificationNotes,
      metadata: metadata ?? this.metadata,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  Position get position => Position(
    latitude: latitude,
    longitude: longitude,
    timestamp: createdAt,
    accuracy: 0,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0,
    headingAccuracy: 0,
  );

  String get hazardTypeDisplayName {
    switch (hazardType) {
      case HazardType.tsunami:
        return 'Tsunami';
      case HazardType.stormSurge:
        return 'Storm Surge';
      case HazardType.highWaves:
        return 'High Waves';
      case HazardType.coastalFlooding:
        return 'Coastal Flooding';
      case HazardType.abnormalTides:
        return 'Abnormal Tides';
      case HazardType.coastalErosion:
        return 'Coastal Erosion';
      case HazardType.other:
        return 'Other';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.verified:
        return 'Verified';
      case ReportStatus.rejected:
        return 'Rejected';
      case ReportStatus.underReview:
        return 'Under Review';
    }
  }

  String get severityDisplayName {
    switch (severity) {
      case ReportSeverity.low:
        return 'Low';
      case ReportSeverity.medium:
        return 'Medium';
      case ReportSeverity.high:
        return 'High';
      case ReportSeverity.critical:
        return 'Critical';
    }
  }
}
