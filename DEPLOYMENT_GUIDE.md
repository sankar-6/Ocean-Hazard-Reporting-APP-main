# Ocean Hazard Reporter - Deployment Guide

This guide covers deploying the Ocean Hazard Reporter Flutter application to various platforms.

## 📱 Mobile App Deployment

### Android Deployment

#### 1. Generate Signed APK

1. **Create a keystore file:**
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Create key.properties file:**
   ```properties
   storePassword=<password from previous step>
   keyPassword=<password from previous step>
   keyAlias=upload
   storeFile=<location of the key store file>
   ```

3. **Update android/app/build.gradle:**
   ```gradle
   android {
       ...
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

4. **Build the APK:**
   ```bash
   flutter build apk --release
   ```

5. **Build App Bundle (recommended for Play Store):**
   ```bash
   flutter build appbundle --release
   ```

#### 2. Google Play Store Deployment

1. **Create a Google Play Console account**
2. **Create a new application**
3. **Upload the AAB file** from `build/app/outputs/bundle/release/`
4. **Configure store listing:**
   - App name: Ocean Hazard Reporter
   - Short description: Report and monitor ocean hazards in real-time
   - Full description: Use the content from README.md
   - Screenshots: Add screenshots from different devices
   - Icon: 512x512 PNG icon

5. **Set up content rating and privacy policy**
6. **Configure pricing and distribution**
7. **Submit for review**

### iOS Deployment

#### 1. Prerequisites

- macOS with Xcode installed
- Apple Developer account
- iOS device or simulator

#### 2. Configure iOS Project

1. **Open ios/Runner.xcworkspace in Xcode**
2. **Update Bundle Identifier** in Runner target
3. **Configure signing** with your Apple Developer account
4. **Update Info.plist** with required permissions:
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>This app needs location access to report ocean hazards</string>
   <key>NSCameraUsageDescription</key>
   <string>This app needs camera access to capture hazard photos</string>
   <key>NSMicrophoneUsageDescription</key>
   <string>This app needs microphone access to record hazard videos</string>
   ```

#### 3. Build and Deploy

1. **Build for release:**
   ```bash
   flutter build ios --release
   ```

2. **Archive in Xcode:**
   - Open ios/Runner.xcworkspace
   - Select "Any iOS Device" as target
   - Product → Archive
   - Upload to App Store Connect

3. **App Store Connect:**
   - Create new app
   - Upload build
   - Configure app information
   - Submit for review

## 🌐 Web Deployment

### 1. Build Web App

```bash
flutter build web --release
```

### 2. Deploy to Firebase Hosting

1. **Install Firebase CLI:**
   ```bash
   npm install -g firebase-tools
   ```

2. **Initialize Firebase:**
   ```bash
   firebase init hosting
   ```

3. **Configure firebase.json:**
   ```json
   {
     "hosting": {
       "public": "build/web",
       "ignore": [
         "firebase.json",
         "**/.*",
         "**/node_modules/**"
       ],
       "rewrites": [
         {
           "source": "**",
           "destination": "/index.html"
         }
       ]
     }
   }
   ```

4. **Deploy:**
   ```bash
   firebase deploy
   ```

### 3. Deploy to Vercel

1. **Install Vercel CLI:**
   ```bash
   npm install -g vercel
   ```

2. **Create vercel.json:**
   ```json
   {
     "version": 2,
     "builds": [
       {
         "src": "build/web/**",
         "use": "@vercel/static"
       }
     ],
     "routes": [
       {
         "src": "/(.*)",
         "dest": "/build/web/index.html"
       }
     ]
   }
   ```

3. **Deploy:**
   ```bash
   vercel --prod
   ```

## 🖥️ Desktop Deployment

### Windows

1. **Build Windows app:**
   ```bash
   flutter build windows --release
   ```

2. **Create installer:**
   - Use tools like Inno Setup or NSIS
   - Package the executable from `build/windows/runner/Release/`

### macOS

1. **Build macOS app:**
   ```bash
   flutter build macos --release
   ```

2. **Create DMG:**
   - Use tools like create-dmg
   - Package the app from `build/macos/Build/Products/Release/`

### Linux

1. **Build Linux app:**
   ```bash
   flutter build linux --release
   ```

2. **Create AppImage:**
   ```bash
   # Install appimagetool
   wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
   chmod +x appimagetool-x86_64.AppImage
   
   # Create AppImage
   ./appimagetool-x86_64.AppImage build/linux/x64/release/bundle/ OceanHazardReporter.AppImage
   ```

## ☁️ Backend Deployment

### 1. Firebase Functions

1. **Initialize Firebase Functions:**
   ```bash
   firebase init functions
   ```

2. **Deploy functions:**
   ```bash
   firebase deploy --only functions
   ```

### 2. Docker Deployment

1. **Create Dockerfile:**
   ```dockerfile
   FROM node:18-alpine
   WORKDIR /app
   COPY package*.json ./
   RUN npm install
   COPY . .
   EXPOSE 3000
   CMD ["npm", "start"]
   ```

2. **Build and run:**
   ```bash
   docker build -t ocean-hazard-api .
   docker run -p 3000:3000 ocean-hazard-api
   ```

### 3. AWS Deployment

1. **Deploy to AWS Lambda:**
   - Use Serverless Framework
   - Configure API Gateway
   - Set up DynamoDB for data storage

2. **Deploy to AWS ECS:**
   - Create ECS cluster
   - Deploy containerized API
   - Configure load balancer

## 🔧 Environment Configuration

### 1. Environment Variables

Create environment-specific configuration files:

**Development (.env.dev):**
```
API_BASE_URL=https://dev-api.oceanhazardreporter.com
GOOGLE_MAPS_API_KEY=dev_key
FIREBASE_PROJECT_ID=ocean-hazard-dev
```

**Production (.env.prod):**
```
API_BASE_URL=https://api.oceanhazardreporter.com
GOOGLE_MAPS_API_KEY=prod_key
FIREBASE_PROJECT_ID=ocean-hazard-prod
```

### 2. Build Configurations

**Debug:**
```bash
flutter run --debug
```

**Release:**
```bash
flutter run --release
```

**Profile:**
```bash
flutter run --profile
```

## 📊 Monitoring and Analytics

### 1. Firebase Analytics

1. **Enable Firebase Analytics** in Firebase Console
2. **Add analytics events** in the app
3. **Monitor user behavior** and app performance

### 2. Crashlytics

1. **Enable Firebase Crashlytics**
2. **Add crash reporting** to track app stability
3. **Monitor crash reports** in Firebase Console

### 3. Performance Monitoring

1. **Enable Firebase Performance Monitoring**
2. **Track app startup time** and network requests
3. **Monitor app performance** metrics

## 🔐 Security Considerations

### 1. API Security

- Use HTTPS for all API communications
- Implement proper authentication and authorization
- Validate all input data
- Use rate limiting to prevent abuse

### 2. App Security

- Obfuscate code for production builds
- Use secure storage for sensitive data
- Implement proper certificate pinning
- Regular security audits

### 3. Data Privacy

- Comply with GDPR and local privacy laws
- Implement data encryption
- Provide user data export/deletion options
- Clear privacy policy and terms of service

## 🚀 CI/CD Pipeline

### 1. GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy Ocean Hazard Reporter

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v2
        with:
          name: app-release
          path: build/app/outputs/flutter-apk/app-release.apk
```

### 2. Automated Testing

- Unit tests for business logic
- Widget tests for UI components
- Integration tests for user flows
- Performance tests for critical paths

## 📈 Performance Optimization

### 1. App Performance

- Optimize images and media files
- Implement lazy loading
- Use efficient data structures
- Minimize app size

### 2. Backend Performance

- Implement caching strategies
- Use CDN for static assets
- Optimize database queries
- Monitor and scale resources

## 🔄 Updates and Maintenance

### 1. App Updates

- Use over-the-air updates for minor changes
- Coordinate with app stores for major updates
- Maintain backward compatibility
- Test updates thoroughly

### 2. Backend Maintenance

- Regular security updates
- Database maintenance
- Performance monitoring
- Backup and disaster recovery

## 📞 Support and Monitoring

### 1. Error Tracking

- Implement comprehensive error logging
- Set up alerts for critical errors
- Monitor app performance metrics
- Track user feedback

### 2. User Support

- Provide in-app help and documentation
- Set up support channels (email, chat)
- Create FAQ and troubleshooting guides
- Monitor user reviews and feedback

---

This deployment guide provides comprehensive instructions for deploying the Ocean Hazard Reporter application across all supported platforms. Follow the steps carefully and test thoroughly before production deployment.
