# Google Maps API Key Configuration

## ✅ **Configuration Complete**

All platforms have been configured with the Google Maps API key: `AIzaSyA0Q-Ye7iOfPJmszXhkEy8l9tKC6qbXSi4`

---

## **Platform Configurations**

### **1. Android** ✅
**File:** `android/app/src/main/AndroidManifest.xml`

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyA0Q-Ye7iOfPJmszXhkEy8l9tKC6qbXSi4"/>
```

**Permissions Added:**
- `INTERNET` - Required for map data
- `ACCESS_FINE_LOCATION` - For precise location
- `ACCESS_COARSE_LOCATION` - For approximate location

---

### **2. iOS** ✅
**File:** `ios/Runner/Info.plist`

```xml
<key>GMSApiKey</key>
<string>AIzaSyA0Q-Ye7iOfPJmszXhkEy8l9tKC6qbXSi4</string>
```

**Location Permissions Added:**
- `NSLocationWhenInUseUsageDescription` - For location access when app is in use
- `NSLocationAlwaysUsageDescription` - For location access in background

---

### **3. Web** ✅
**File:** `web/index.html`

```html
<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyA0Q-Ye7iOfPJmszXhkEy8l9tKC6qbXSi4&libraries=places"></script>
```

---

## **Next Steps**

1. **Restart the app** after configuration changes
2. **Test Google Maps** in your app:
   - Location picker
   - Map views
   - Location-based features

3. **Verify API Key Restrictions** (Optional but Recommended):
   - Go to [Google Cloud Console](https://console.cloud.google.com/google/maps-apis/credentials)
   - Set application restrictions:
     - **Android**: Add your package name and SHA-1 certificate fingerprint
     - **iOS**: Add your bundle identifier
     - **Web**: Add your domain

---

## **Troubleshooting**

### **Maps Not Loading:**
1. Check API key is correct in all configuration files
2. Verify API key is enabled in Google Cloud Console
3. Check that "Maps SDK for Android/iOS" is enabled
4. Verify app permissions are granted
5. Check network connectivity

### **Location Not Working:**
1. Ensure location permissions are granted in device settings
2. Check that location services are enabled on device
3. Verify `NSLocationWhenInUseUsageDescription` is set (iOS)

---

**All platforms configured!** 🎉

