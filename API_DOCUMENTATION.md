# Ocean Hazard Reporter API Documentation

## Base URL
```
https://api.oceanhazardreporter.com/v1
```

## Authentication
All API requests require authentication using Bearer token:
```
Authorization: Bearer <your_token>
```

## Endpoints

### Reports

#### GET /reports
Get list of reports with optional filtering.

**Query Parameters:**
- `page` (int): Page number (default: 1)
- `limit` (int): Items per page (default: 20)
- `latitude` (float): Center latitude for location-based filtering
- `longitude` (float): Center longitude for location-based filtering
- `radius` (float): Search radius in kilometers
- `hazard_type` (string): Filter by hazard type
- `status` (string): Filter by report status
- `severity` (string): Filter by severity level

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "report_123",
      "user_id": "user_456",
      "user_name": "John Doe",
      "hazard_type": "high_waves",
      "title": "High waves observed at Marina Beach",
      "description": "Waves reaching 3-4 meters height",
      "latitude": 13.0475,
      "longitude": 80.2837,
      "address": "Marina Beach, Chennai",
      "media_urls": ["https://example.com/image1.jpg"],
      "status": "verified",
      "severity": "high",
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-15T11:00:00Z",
      "verified_by": "official_789",
      "verified_at": "2024-01-15T11:00:00Z",
      "verification_notes": "Confirmed by local authorities"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 5,
    "total_items": 100,
    "items_per_page": 20
  }
}
```

#### GET /reports/{id}
Get specific report by ID.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "report_123",
    // ... report object
  }
}
```

#### POST /reports
Create a new report.

**Request Body:**
```json
{
  "hazard_type": "high_waves",
  "title": "High waves observed",
  "description": "Detailed description",
  "latitude": 13.0475,
  "longitude": 80.2837,
  "address": "Marina Beach, Chennai",
  "media_urls": ["https://example.com/image1.jpg"],
  "severity": "high"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "report_123",
    // ... created report object
  }
}
```

#### PUT /reports/{id}
Update an existing report.

#### DELETE /reports/{id}
Delete a report.

#### POST /reports/{id}/verify
Verify a report.

**Request Body:**
```json
{
  "verified_by": "official_789",
  "verification_notes": "Confirmed by local authorities"
}
```

### Social Media

#### GET /social-media/posts
Get social media posts with filtering.

**Query Parameters:**
- `platform` (string): Filter by platform (twitter, facebook, youtube, instagram)
- `sentiment` (string): Filter by sentiment (positive, negative, neutral, urgent)
- `hazard_related` (boolean): Filter by hazard-related posts
- `latitude` (float): Center latitude for location-based filtering
- `longitude` (float): Center longitude for location-based filtering
- `radius` (float): Search radius in kilometers

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "post_123",
      "platform": "twitter",
      "content": "Just witnessed massive waves at Marina Beach!",
      "author": "John Doe",
      "author_handle": "@johndoe",
      "created_at": "2024-01-15T10:30:00Z",
      "likes": 45,
      "shares": 12,
      "comments": 8,
      "latitude": 13.0475,
      "longitude": 80.2837,
      "location": "Chennai, India",
      "hashtags": ["OceanHazard", "Chennai"],
      "sentiment": "urgent",
      "confidence": 0.85,
      "is_hazard_related": true,
      "hazard_keywords": ["waves", "ocean", "hazard"]
    }
  ]
}
```

### Analytics

#### GET /analytics
Get analytics data.

**Query Parameters:**
- `start_date` (string): Start date in ISO format
- `end_date` (string): End date in ISO format
- `region` (string): Geographic region filter

**Response:**
```json
{
  "success": true,
  "data": {
    "total_reports": 1250,
    "verified_reports": 890,
    "pending_reports": 360,
    "hazard_types": {
      "high_waves": 450,
      "coastal_flooding": 320,
      "storm_surge": 280,
      "tsunami": 50,
      "other": 150
    },
    "severity_distribution": {
      "low": 200,
      "medium": 600,
      "high": 350,
      "critical": 100
    },
    "social_media_stats": {
      "total_posts": 5600,
      "hazard_related_posts": 1200,
      "urgent_posts": 150,
      "platform_distribution": {
        "twitter": 3000,
        "facebook": 1800,
        "youtube": 500,
        "instagram": 300
      }
    },
    "time_series": [
      {
        "date": "2024-01-15",
        "reports": 45,
        "social_posts": 120
      }
    ]
  }
}
```

### Hotspots

#### GET /hotspots
Get dynamic hotspots based on report density.

**Query Parameters:**
- `latitude` (float): Center latitude
- `longitude` (float): Center longitude
- `radius` (float): Search radius in kilometers
- `time_range` (string): Time range (1h, 6h, 24h, 7d, 30d)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "latitude": 13.0475,
      "longitude": 80.2837,
      "intensity": 0.85,
      "report_count": 25,
      "hazard_types": ["high_waves", "coastal_flooding"],
      "severity": "high",
      "last_updated": "2024-01-15T10:30:00Z"
    }
  ]
}
```

### Media Upload

#### POST /media/upload
Upload media files (images/videos).

**Request Body:**
- `file` (file): Media file
- `type` (string): File type (image, video)

**Response:**
```json
{
  "success": true,
  "data": {
    "url": "https://cdn.oceanhazardreporter.com/media/123456.jpg",
    "file_id": "media_123",
    "file_size": 1024000,
    "mime_type": "image/jpeg"
  }
}
```

### Health Check

#### GET /health
Check API health status.

**Response:**
```json
{
  "success": true,
  "data": {
    "status": "healthy",
    "timestamp": "2024-01-15T10:30:00Z",
    "version": "1.0.0",
    "uptime": 86400
  }
}
```

## Error Responses

All error responses follow this format:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": {
      "field": "latitude",
      "reason": "Must be between -90 and 90"
    }
  }
}
```

## Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `422` - Validation Error
- `500` - Internal Server Error

## Rate Limiting

- **Free Tier**: 1000 requests per hour
- **Pro Tier**: 10000 requests per hour
- **Enterprise**: Custom limits

Rate limit headers:
- `X-RateLimit-Limit`: Request limit per hour
- `X-RateLimit-Remaining`: Remaining requests
- `X-RateLimit-Reset`: Reset timestamp

## Webhooks

### Report Created
Triggered when a new report is created.

**Payload:**
```json
{
  "event": "report.created",
  "data": {
    "report_id": "report_123",
    "hazard_type": "high_waves",
    "severity": "high",
    "latitude": 13.0475,
    "longitude": 80.2837,
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

### Report Verified
Triggered when a report is verified.

**Payload:**
```json
{
  "event": "report.verified",
  "data": {
    "report_id": "report_123",
    "verified_by": "official_789",
    "verified_at": "2024-01-15T11:00:00Z"
  }
}
```

## SDK Examples

### Flutter/Dart
```dart
import 'package:ocean_hazard_reporter/api_service.dart';

// Get reports
final reports = await ApiService.getReports(
  latitude: 13.0475,
  longitude: 80.2837,
  radius: 10.0,
  hazardType: HazardType.highWaves,
);

// Create report
final report = await ApiService.createReport(ReportModel(
  hazardType: HazardType.highWaves,
  title: 'High waves observed',
  description: 'Detailed description',
  latitude: 13.0475,
  longitude: 80.2837,
  severity: ReportSeverity.high,
));
```

### JavaScript/Node.js
```javascript
const OceanHazardAPI = require('ocean-hazard-reporter-api');

const api = new OceanHazardAPI('your-api-key');

// Get reports
const reports = await api.reports.get({
  latitude: 13.0475,
  longitude: 80.2837,
  radius: 10.0,
  hazardType: 'high_waves'
});

// Create report
const report = await api.reports.create({
  hazard_type: 'high_waves',
  title: 'High waves observed',
  description: 'Detailed description',
  latitude: 13.0475,
  longitude: 80.2837,
  severity: 'high'
});
```

## Support

For API support and questions:
- Email: api-support@oceanhazardreporter.com
- Documentation: https://docs.oceanhazardreporter.com
- Status Page: https://status.oceanhazardreporter.com
