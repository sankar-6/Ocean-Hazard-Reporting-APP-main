# Google Maps Setup Guide

## Fixing the MapTypeId Error

The error `TypeError: Cannot read properties of undefined (reading 'MapTypeId')` occurs when the Google Maps API key is not properly configured. This guide will help you set up Google Maps correctly.

## Step 1: Get a Google Maps API Key

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS (if targeting iOS)
   - Places API (optional, for location search)
   - Geocoding API (optional, for address conversion)

4. Go to "Credentials" and create a new API key
5. Restrict the API key to your app's package name and SHA-1 fingerprint

## Step 2: Configure Android

### Update AndroidManifest.xml

The Android manifest has been updated with the necessary permissions and API key configuration:

```xml
<!-- Permissions for Google Maps -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Google Maps API Key -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE" />
```

### Replace the API Key

1. Open `android/app/src/main/AndroidManifest.xml`
2. Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key
3. Make sure to keep the quotes around the API key

## Step 3: Configure iOS (if targeting iOS)

### Update Info.plist

Add the following to `ios/Runner/Info.plist`:

```xml
<key>GMSApiKey</key>
<string>YOUR_GOOGLE_MAPS_API_KEY_HERE</string>
```

### Update AppDelegate.swift

Add the following to `ios/Runner/AppDelegate.swift`:

```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Step 4: Environment-Specific Configuration

For different environments (development, staging, production), you can use different API keys:

### Development Setup

Create a `android/app/src/debug/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_DEVELOPMENT_API_KEY" />
    </application>
</manifest>
```

### Production Setup

Create a `android/app/src/release/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_PRODUCTION_API_KEY" />
    </application>
</manifest>
```

## Step 5: Test the Setup

1. Clean and rebuild your project:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. Navigate to the map screen and verify that:
   - The map loads without errors
   - You can see the map tiles
   - Markers are displayed correctly
   - Location services work

## Troubleshooting

### Common Issues

1. **"MapTypeId is undefined" Error**
   - Ensure the API key is correctly set in AndroidManifest.xml
   - Verify the API key has the correct permissions
   - Check that the Maps SDK for Android is enabled

2. **"This page can't load Google Maps correctly"**
   - Verify your API key is valid
   - Check that billing is enabled for your Google Cloud project
   - Ensure the API key restrictions are set correctly

3. **Map shows but no tiles**
   - Check your internet connection
   - Verify the API key has the correct APIs enabled
   - Check the Google Cloud Console for quota limits

4. **Location not working**
   - Ensure location permissions are granted
   - Check that location services are enabled on the device
   - Verify the location permission is in the manifest

### Debug Steps

1. Check the console logs for any error messages
2. Verify the API key in Google Cloud Console
3. Test with a simple map first before adding complex features
4. Use the error widget in the app to get more specific error information

## Security Best Practices

1. **Restrict your API key** to specific:
   - Android apps (package name + SHA-1)
   - iOS apps (bundle identifier)
   - HTTP referrers (for web)

2. **Use different API keys** for different environments

3. **Monitor usage** in Google Cloud Console

4. **Set up billing alerts** to avoid unexpected charges

## API Key Restrictions Example

In Google Cloud Console, restrict your API key:

```
Application restrictions:
- Android apps
  - Package name: com.example.sih_app
  - SHA-1 certificate fingerprint: YOUR_SHA1_FINGERPRINT

API restrictions:
- Maps SDK for Android
- Places API
- Geocoding API
```

## Getting SHA-1 Fingerprint

For debug builds:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

For release builds:
```bash
keytool -list -v -keystore path/to/your/release.keystore -alias your_alias
```

## Cost Considerations

- Google Maps has a free tier with usage limits
- Monitor your usage in the Google Cloud Console
- Set up billing alerts to avoid unexpected charges
- Consider using map caching for frequently accessed areas

## Additional Resources

- [Google Maps Flutter Plugin Documentation](https://pub.dev/packages/google_maps_flutter)
- [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)
- [Google Cloud Console](https://console.cloud.google.com/)
- [API Key Best Practices](https://developers.google.com/maps/api-key-best-practices)
