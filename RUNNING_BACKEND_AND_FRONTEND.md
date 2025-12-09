# Running Backend (IntelliJ) and Frontend (Android Studio) Together

## 🎯 Overview

This guide explains how to run both your **Java Spring Boot backend** (in IntelliJ IDEA) and **Flutter mobile app** (in Android Studio) simultaneously so they can communicate.

---

## 📋 Prerequisites

1. ✅ **Backend Setup Complete**
   - PostgreSQL database created and running
   - `.env` file configured in `SafeReport-Backend-APIS-main/`
   - Backend project opened in IntelliJ IDEA

2. ✅ **Frontend Setup Complete**
   - Flutter SDK installed
   - Android Studio configured
   - Flutter project opened in Android Studio

---

## 🚀 Step-by-Step: Running Both Together

### **Step 1: Start PostgreSQL Database**

**Windows:**
- Open **Services** (Win + R → `services.msc`)
- Find **PostgreSQL** service
- Ensure it's **Running**

**Or via Command Line:**
```bash
# Check if PostgreSQL is running
pg_ctl status
```

---

### **Step 2: Start Backend in IntelliJ IDEA**

1. **Open IntelliJ IDEA**
2. **Open Project**: `SafeReport-Backend-APIS-main`
3. **Wait for Maven** to download dependencies (if first time)
4. **Find Main Class**: 
   - Navigate to: `src/main/java/com/crimeprevention/crime_backend/CrimeBackendApplication.java`
5. **Run Backend**:
   - Right-click on `CrimeBackendApplication.java`
   - Select **Run 'CrimeBackendApplication'**
   - Or click the green ▶️ button next to the class

6. **Verify Backend is Running**:
   - Look for this in the console:
     ```
     Started CrimeBackendApplication in X.XXX seconds
     ```
   - Backend should be running on: **http://localhost:8080**

7. **Test Backend** (Optional):
   - Open browser: `http://localhost:8080/api/auth/login`
   - Or use Postman/curl to test endpoints

---

### **Step 3: Configure Flutter App for Chrome/Web**

**✅ For Chrome/Web:** You can use `localhost` directly since Chrome runs on your computer.

**The configuration is already set in `lib/config/app_config.dart`:**

```dart
class AppConfig {
  // Backend API Configuration
  // - Chrome/Web: 'http://localhost:8080/api' (current - for web browser)
  // - Android Emulator: 'http://10.0.2.2:8080/api' (commented - use when running on Android emulator)
  static const String baseUrl = 'http://localhost:8080/api'; // Current: Chrome/Web
  // static const String baseUrl = 'http://10.0.2.2:8080/api'; // Android Emulator (commented)
  
  // ... rest of config
}
```

**Note:** If you switch to Android emulator later, uncomment the Android emulator line and comment the Chrome line.

---

### **Step 4: Start Flutter App in Chrome (Android Studio)**

1. **Open Android Studio**
2. **Open Project**: `SAFE REPORT` (your Flutter project root)
3. **Select Device**: 
   - Choose **Chrome** from the device dropdown (not Android emulator)
   - Or select **Web Server** if available
4. **Run App**:
   - Click the green ▶️ **Run** button
   - Or press `Shift + F10`
   - Or use menu: **Run → Run 'main.dart'**

5. **Wait for App to Build and Launch in Chrome**
   - Flutter will compile for web
   - Chrome will open automatically with your app
   - App will be available at `http://localhost:XXXX` (Flutter assigns a random port)

---

## 🔗 How They Communicate

### **For Chrome/Web (Current Setup):**

```
┌─────────────────┐         HTTP Requests         ┌──────────────────┐
│                 │ ────────────────────────────> │                  │
│  Flutter App    │                                │  Spring Boot     │
│  (Chrome/Web)   │ <────────────────────────────  │  Backend         │
│                 │         JSON Responses         │  (IntelliJ)      │
└─────────────────┘                                └──────────────────┘
  Port: Random (Flutter)                                Port: 8080
  localhost:XXXX                                        localhost:8080
```

### **For Android Emulator (If You Switch Later):**

```
┌─────────────────┐         HTTP Requests         ┌──────────────────┐
│                 │ ────────────────────────────> │                  │
│  Flutter App    │                                │  Spring Boot     │
│  (Android)      │ <────────────────────────────  │  Backend         │
│                 │         JSON Responses         │  (IntelliJ)      │
└─────────────────┘                                └──────────────────┘
     Port: N/A                                          Port: 8080
  Emulator IP: 10.0.2.2                              localhost:8080
```

**Flow (Chrome/Web):**
1. Flutter app (running in Chrome) makes HTTP request to `http://localhost:8080/api/...`
2. Request goes directly to Spring Boot backend on port 8080 (same machine)
3. Backend processes request and returns JSON response
4. Flutter app receives response and updates UI

**Flow (Android Emulator - if you switch later):**
1. Flutter app makes HTTP request to `http://10.0.2.2:8080/api/...`
2. Android emulator routes `10.0.2.2` to your host machine's `localhost`
3. Request reaches Spring Boot backend on port 8080
4. Backend processes request and returns JSON response
5. Flutter app receives response and updates UI

---

## 🧪 Testing the Connection

### **Test 1: Backend Health Check**

In your Flutter app, try logging in or making any API call. Check the backend console in IntelliJ for incoming requests.

### **Test 2: Check Backend Logs**

In IntelliJ console, you should see:
```
2024-XX-XX ... POST /api/auth/login
```

### **Test 3: Network Inspector (Android Studio)**

1. Open **View → Tool Windows → Flutter Inspector**
2. Check for network errors in the console

---

## 🔧 Troubleshooting

### **Problem: "Connection refused" or "Failed to connect"**

**Solutions:**

1. **Check Backend is Running**:
   - Look at IntelliJ console for "Started CrimeBackendApplication"
   - Test in browser: `http://localhost:8080/api/auth/login`

2. **Check URL in Flutter App**:
   - For Chrome/Web: Ensure `app_config.dart` uses `http://localhost:8080/api`
   - For Android Emulator: Use `http://10.0.2.2:8080/api` (commented in current config)

3. **Check Firewall**:
   - Windows Firewall might block connections
   - Allow Java/IntelliJ through firewall if needed

4. **Check Port 8080**:
   ```bash
   # Windows - Check if port 8080 is in use
   netstat -ano | findstr :8080
   ```

### **Problem: "Network is unreachable"**

**Solutions:**

1. **Verify Emulator Network**:
   - Android emulator should have internet access
   - Check emulator settings

2. **Try Physical Device Instead**:
   - Connect Android phone via USB
   - Enable USB debugging
   - Use your computer's IP address: `http://192.168.1.X:8080/api`
   - Find your IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)

### **Problem: Backend starts but Flutter can't connect**

**Solutions:**

1. **Check CORS** (if testing web):
   - Backend CORS is configured for web apps
   - Mobile apps don't need CORS

2. **Check Backend Logs**:
   - Look for errors in IntelliJ console
   - Check database connection errors

3. **Restart Both**:
   - Stop backend in IntelliJ
   - Stop Flutter app
   - Start backend first, then Flutter app

---

## 📱 Different Device Configurations

### **Chrome/Web (Current Setup)**
```dart
static const String baseUrl = 'http://localhost:8080/api';
```

### **Android Emulator**
```dart
static const String baseUrl = 'http://10.0.2.2:8080/api';
```

### **iOS Simulator**
```dart
static const String baseUrl = 'http://localhost:8080/api';
```

### **Physical Android Device (USB)**
```dart
// Find your computer's IP address
// Windows: ipconfig
// Mac/Linux: ifconfig
static const String baseUrl = 'http://192.168.1.XXX:8080/api';  // Replace XXX
```

### **Physical Device (Same WiFi)**
```dart
// Use your computer's local network IP
static const String baseUrl = 'http://192.168.1.XXX:8080/api';
```

---

## 🎯 Quick Reference

### **Start Order:**
1. ✅ PostgreSQL (must be running)
2. ✅ Backend in IntelliJ (port 8080)
3. ✅ Flutter app in Android Studio

### **URLs:**
- **Backend**: `http://localhost:8080/api`
- **Flutter (Chrome/Web)**: `http://localhost:8080/api` ✅ (Current)
- **Flutter (Android Emulator)**: `http://10.0.2.2:8080/api`
- **Flutter (iOS Simulator)**: `http://localhost:8080/api`
- **Flutter (Physical Device)**: `http://YOUR_IP:8080/api`

### **Key Files:**
- **Backend Config**: `SafeReport-Backend-APIS-main/src/main/resources/application.properties`
- **Flutter Config**: `lib/config/app_config.dart`
- **Backend Main**: `SafeReport-Backend-APIS-main/src/main/java/.../CrimeBackendApplication.java`
- **Flutter Main**: `lib/main.dart`

---

## ✅ Success Checklist

- [ ] PostgreSQL is running
- [ ] Backend starts successfully in IntelliJ (see "Started" message)
- [ ] Backend accessible at `http://localhost:8080`
- [ ] Flutter `app_config.dart` uses correct URL for your device type
- [ ] Flutter app builds and runs in Android Studio
- [ ] API calls from Flutter app reach backend (check IntelliJ console)
- [ ] Login/API requests work from Flutter app

---

## 🆘 Still Having Issues?

1. **Check Backend Logs** in IntelliJ console for errors
2. **Check Flutter Logs** in Android Studio console
3. **Verify Database** is running and accessible
4. **Test Backend Directly** using Postman or curl
5. **Check Network Settings** - ensure no VPN or proxy interfering

---

## 📚 Additional Resources

- **Backend Setup**: See `BACKEND_SETUP_GUIDE.md`
- **Flutter Integration**: See `FLUTTER_BACKEND_INTEGRATION_GUIDE.md`
- **API Documentation**: Check backend README for endpoint details

