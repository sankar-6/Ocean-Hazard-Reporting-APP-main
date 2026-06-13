#!/bin/bash

echo "Getting SHA-1 fingerprint for Google Maps API key configuration..."
echo

echo "Debug keystore SHA-1:"
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep "SHA1"

echo
echo "If you have a release keystore, run this command with your keystore path:"
echo "keytool -list -v -keystore path/to/your/release.keystore -alias your_alias"
echo
