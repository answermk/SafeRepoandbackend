# Screen Integration Guide
## Connecting Flutter Screens to Backend Services

---

## ⚠️ **CURRENT STATUS**

**Services Created:** ✅ All backend services are ready  
**Screens Integrated:** ❌ Most screens still use mock/hardcoded data

---

## 📋 **SCREENS THAT NEED INTEGRATION**

### **🔴 HIGH PRIORITY (Core Functionality)**

#### **1. Login Screen** (`lib/screens/login_screen.dart`)
**Current:** Hardcoded credentials check  
**Needs:**
- ✅ Import `AuthService`
- ✅ Call `AuthService.login()`
- ✅ Save token using `TokenManager`
- ✅ Handle errors properly

#### **2. Signup Screen** (`lib/screens/signup_screen.dart`)
**Current:** Simulated signup with delay  
**Needs:**
- ✅ Import `AuthService`
- ✅ Call `AuthService.register()`
- ✅ Handle validation errors
- ✅ Navigate to login on success

#### **3. Report Crime Screen** (`lib/screens/report_crime_screen.dart`)
**Current:** Only saves draft locally  
**Needs:**
- ✅ Import `ReportService`
- ✅ Call `ReportService.createReport()` when submitting
- ✅ Upload media files using `FileUploadService`
- ✅ Handle submission errors

#### **4. My Reports Screen** (`lib/screens/my_reports_screen.dart`)
**Current:** Hardcoded placeholder data  
**Needs:**
- ✅ Import `ReportService`
- ✅ Call `ReportService.getMyReports()` in `_loadReports()`
- ✅ Handle pagination
- ✅ Update filters to work with real data

#### **5. Profile Screen** (`lib/screens/profile_screen.dart`)
**Current:** Hardcoded user data  
**Needs:**
- ✅ Import `UserService`
- ✅ Call `UserService.getUserProfile()` in `_loadUserProfile()`
- ✅ Load from `TokenManager` for user ID
- ✅ Handle logout with `AuthService.logout()`

#### **6. Dashboard Screen** (`lib/screens/dashboard_screen.dart`)
**Current:** Hardcoded statistics  
**Needs:**
- ✅ Import `UserService` for stats
- ✅ Import `ReportService` for report counts
- ✅ Import `NotificationService` for unread count
- ✅ Call services in `_loadUserData()`

---

### **🟡 MEDIUM PRIORITY**

#### **7. Location Screen** (`lib/screens/location_screen.dart`)
**Needs:**
- ✅ Import `LocationService`
- ✅ Call `LocationService.reverseGeocode()` for address

#### **8. Review Report Screen** (`lib/screens/review_report_screen.dart`)
**Needs:**
- ✅ Import `ReportService`
- ✅ Call `ReportService.createReport()` on submit

#### **9. Watch Groups Screens**
**Needs:**
- ✅ Import `WatchGroupService`
- ✅ Call `WatchGroupService.getAllWatchGroups()`
- ✅ Call `WatchGroupService.getMyWatchGroups()`
- ✅ Call `WatchGroupService.joinWatchGroup()`

#### **10. Watch Group Messages Screen**
**Needs:**
- ✅ Import `WatchGroupMessageService`
- ✅ Call `WatchGroupMessageService.getWatchGroupMessages()`
- ✅ Call `WatchGroupMessageService.sendMessage()`

#### **11. Messages Screen**
**Needs:**
- ✅ Import `MessageService`
- ✅ Call `MessageService.getInbox()`
- ✅ Call `MessageService.sendMessage()`

#### **12. Forum Screens**
**Needs:**
- ✅ Import `ForumService`
- ✅ Call `ForumService.getAllPosts()`
- ✅ Call `ForumService.createPost()`
- ✅ Call `ForumService.createReply()`

#### **13. Notifications Screen**
**Needs:**
- ✅ Import `NotificationService`
- ✅ Call `NotificationService.getNotifications()`
- ✅ Call `NotificationService.markAsRead()`

---

### **🟢 LOW PRIORITY (Can work with mock data for now)**

- Nearby Incidents Screen
- Community Statistics Screen
- Map Screens (can use mock data initially)
- Safety Education Screen

---

## 🔧 **INTEGRATION STEPS**

### **Step 1: Update Base URL**
```dart
// lib/config/app_config.dart
static const String baseUrl = 'http://YOUR_BACKEND_IP:8080/api';
// For Android emulator: 'http://10.0.2.2:8080/api'
// For iOS simulator: 'http://localhost:8080/api'
// For physical device: 'http://YOUR_COMPUTER_IP:8080/api'
```

### **Step 2: Initialize ApiClient**
```dart
// lib/main.dart or lib/app.dart
import 'package:safereport_mobo/services/api_client.dart';

void main() {
  ApiClient.init(); // Initialize Dio with interceptors
  runApp(MyApp());
}
```

### **Step 3: Update Screens**
Follow the examples below for each screen type.

---

## 📝 **INTEGRATION EXAMPLES**

### **Example 1: Login Screen Integration**

```dart
import '../services/auth_service.dart';
import '../services/token_manager.dart';

Future<void> _handleLogin() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text;

  if (email.isEmpty || password.isEmpty) {
    _showMessage('Please enter both email and password', isError: true);
    return;
  }

  // Show loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  try {
    final result = await AuthService.login(email, password);
    
    Navigator.of(context).pop(); // Close loading
    
    if (result['success'] == true) {
      // Save token
      await TokenManager.saveToken(
        token: result['token'],
        email: result['email'],
        username: result['username'],
      );
      
      _showMessage('Login successful!', isError: false);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      _showMessage(result['error'] ?? 'Login failed', isError: true);
    }
  } catch (e) {
    Navigator.of(context).pop(); // Close loading
    _showMessage('Connection error: ${e.toString()}', isError: true);
  }
}
```

### **Example 2: My Reports Screen Integration**

```dart
import '../services/report_service.dart';
import '../services/token_manager.dart';

Future<void> _loadReports() async {
  setState(() {
    // Show loading state
  });

  try {
    final result = await ReportService.getMyReports(
      page: 0,
      size: 20,
      status: _selectedFilter == 1 ? null : (_selectedFilter == 2 ? 'RESOLVED' : null),
    );

    if (result['success'] == true) {
      setState(() {
        reports = List<Map<String, dynamic>>.from(result['data']);
        _applyFiltersAndSort();
      });
    } else {
      _showMessage(result['error'] ?? 'Failed to load reports', isError: true);
    }
  } catch (e) {
    _showMessage('Connection error: ${e.toString()}', isError: true);
  }
}
```

### **Example 3: Profile Screen Integration**

```dart
import '../services/user_service.dart';
import '../services/token_manager.dart';

Future<void> _loadUserProfile() async {
  try {
    final userId = await TokenManager.getUserId(); // You may need to add this method
    if (userId == null) return;

    final result = await UserService.getUserProfile(userId);

    if (result['success'] == true) {
      final userData = result['data'];
      setState(() {
        userName = userData['fullName'] ?? userData['username'] ?? 'User';
        userEmail = userData['email'] ?? '';
        userPhone = userData['phone'] ?? '';
        userLocation = userData['location'] ?? '';
        // Format member since date
        if (userData['createdAt'] != null) {
          final date = DateTime.parse(userData['createdAt']);
          memberSince = 'Member since ${_formatDate(date)}';
        }
      });
    }
  } catch (e) {
    print('Error loading profile: $e');
  }
}
```

---

## ✅ **CHECKLIST**

Before running the app, ensure:

- [ ] Base URL is set correctly in `app_config.dart`
- [ ] `ApiClient.init()` is called in `main.dart`
- [ ] Login screen calls `AuthService.login()`
- [ ] Signup screen calls `AuthService.register()`
- [ ] Report submission calls `ReportService.createReport()`
- [ ] My Reports loads from `ReportService.getMyReports()`
- [ ] Profile loads from `UserService.getUserProfile()`
- [ ] Token is saved after login
- [ ] Error handling is implemented
- [ ] Loading indicators are shown during API calls

---

## 🚨 **COMMON ISSUES**

### **Issue 1: Connection Refused**
**Solution:** Check base URL matches your backend IP/port

### **Issue 2: 401 Unauthorized**
**Solution:** Ensure token is saved and sent in headers

### **Issue 3: CORS Errors (Web)**
**Solution:** Backend needs CORS configuration

### **Issue 4: Network Error**
**Solution:** Check device/emulator can reach backend

---

## 📚 **NEXT STEPS**

1. Start with Login/Signup screens
2. Then integrate Report submission
3. Then integrate data loading screens
4. Test each integration before moving to next

---

**Status:** Services ready ✅ | Screens need integration ⚠️

