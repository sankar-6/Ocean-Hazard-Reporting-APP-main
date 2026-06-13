# Ocean Hazard Reporter

A comprehensive Flutter application for reporting and monitoring ocean hazards in real-time. This platform enables citizens, coastal residents, volunteers, and disaster managers to report observations during hazardous ocean events and monitor public communication trends via social media.

## 🌊 Features

### Core Functionality
- **Real-time Hazard Reporting**: Citizens can submit geotagged reports with photos/videos
- **Interactive Map Dashboard**: Visualize all reports and social media activity on an interactive map
- **Dynamic Hotspot Generation**: Hotspots generated based on report density and verified incidents
- **Social Media Integration**: Monitor social media feeds with NLP for hazard detection
- **Offline Support**: Data collection works offline with automatic sync when connected
- **Role-based Access**: Different access levels for citizens, officials, and analysts

### Hazard Types Supported
- 🌊 Tsunami
- ⛈️ Storm Surge
- 🌊 High Waves
- 🌊 Coastal Flooding
- 📈 Abnormal Tides
- 🏔️ Coastal Erosion
- ⚠️ Other Hazards

### Key Features
- **Geotagged Reporting**: Automatic location detection with manual override
- **Media Upload**: Photo and video support with compression
- **Real-time Notifications**: Push notifications for hazard alerts
- **Multi-language Support**: English, Hindi, Tamil support
- **Offline Data Collection**: Works without internet connection
- **Social Media Monitoring**: Twitter, Facebook, YouTube integration
- **Sentiment Analysis**: AI-powered sentiment detection
- **Verification System**: Officials can verify and manage reports

## 🏗️ Architecture

### Project Structure
```
lib/
├── core/
│   ├── providers/          # State management providers
│   ├── services/           # Core services (auth, location, etc.)
│   ├── theme/              # App theming
│   └── routing/            # Navigation configuration
├── features/
│   ├── auth/               # Authentication screens
│   ├── dashboard/          # Main dashboard
│   ├── reporting/          # Report creation and management
│   ├── map/                # Interactive map functionality
│   ├── social_media/       # Social media monitoring
│   ├── profile/            # User profile management
│   └── settings/           # App settings
├── models/                 # Data models
└── main.dart              # App entry point
```

### Technology Stack
- **Frontend**: Flutter 3.8.1+
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Maps**: Google Maps Flutter
- **Authentication**: Firebase Auth
- **Database**: Hive (local), SQLite (offline)
- **Social Media**: Twitter API, YouTube API
- **Location**: Geolocator, Geocoding
- **Media**: Image Picker, Camera
- **Notifications**: Flutter Local Notifications

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code
- Google Maps API key
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd sih_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Google Maps**
   - Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
   - Add the API key to `android/app/src/main/AndroidManifest.xml`:
     ```xml
     <meta-data
         android:name="com.google.android.geo.API_KEY"
         android:value="YOUR_API_KEY"/>
     ```

4. **Configure Firebase**
   - Create a Firebase project
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`

5. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Screenshots

### Dashboard
- Overview of recent reports and statistics
- Quick action buttons for reporting and navigation
- Hazard alerts banner with real-time updates

### Report Creation
- Intuitive form for hazard reporting
- Hazard type selection with visual indicators
- Severity level selection
- Location picker with map integration
- Media upload with photo/video support

### Interactive Map
- Real-time report visualization
- Dynamic hotspots based on report density
- Filter by hazard type and verification status
- Heatmap overlay option

### Social Media Monitoring
- Real-time social media feed monitoring
- Sentiment analysis and hazard detection
- Platform-specific filtering (Twitter, Facebook, YouTube)
- Engagement metrics and trending topics

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the root directory:
```
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
TWITTER_API_KEY=your_twitter_api_key
TWITTER_API_SECRET=your_twitter_api_secret
YOUTUBE_API_KEY=your_youtube_api_key
```

### Firebase Configuration
1. Enable Authentication in Firebase Console
2. Enable Google Sign-In provider
3. Configure Firestore security rules
4. Set up Cloud Functions for backend processing

## 🛠️ Development

### Running Tests
```bash
flutter test
```

### Building for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Code Generation
```bash
# Generate Hive adapters
flutter packages pub run build_runner build

# Generate Riverpod providers
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## 📊 Data Models

### Report Model
```dart
class ReportModel {
  final String id;
  final String userId;
  final HazardType hazardType;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final List<String> mediaUrls;
  final ReportStatus status;
  final ReportSeverity severity;
  final DateTime createdAt;
  // ... more fields
}
```

### Social Media Post Model
```dart
class SocialMediaPost {
  final String id;
  final String platform;
  final String content;
  final SentimentType sentiment;
  final bool isHazardRelated;
  final List<String> hazardKeywords;
  // ... more fields
}
```

## 🔐 Security

- **Authentication**: Firebase Auth with Google Sign-In
- **Authorization**: Role-based access control
- **Data Validation**: Client and server-side validation
- **Privacy**: Location data anonymization options
- **Encryption**: Sensitive data encrypted at rest

## 🌐 Internationalization

The app supports multiple languages:
- English (en)
- Hindi (hi)
- Tamil (ta)

To add more languages, update the `lib/l10n/` directory and run:
```bash
flutter gen-l10n
```

## 📈 Performance

- **Lazy Loading**: Images and data loaded on demand
- **Caching**: Network responses cached locally
- **Compression**: Media files compressed before upload
- **Offline Support**: Full functionality without internet
- **Background Sync**: Automatic data synchronization

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- INCOIS for ocean hazard data and early warning systems
- Google Maps Platform for mapping services
- Firebase for backend infrastructure
- Flutter community for excellent packages and support

## 📞 Support

For support and questions:
- Create an issue in the GitHub repository
- Contact the development team
- Check the documentation wiki

## 🔮 Future Enhancements

- [ ] Machine Learning for hazard prediction
- [ ] Integration with weather APIs
- [ ] Advanced analytics dashboard
- [ ] Mobile app for officials
- [ ] Web dashboard for disaster management
- [ ] Integration with emergency services
- [ ] Real-time collaboration features
- [ ] Advanced reporting and analytics

---

**Ocean Hazard Reporter** - Protecting coastal communities through technology and community engagement.