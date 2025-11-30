# Flutter Project Structure
## Complete Backend Integration Structure

---

## 📁 **COMPLETE PROJECT STRUCTURE**

```
lib/
├── config/                          # Configuration files
│   ├── app_config.dart              # App-wide configuration (base URLs, timeouts, etc.)
│   └── constants.dart               # Application constants (statuses, roles, etc.)
│
├── core/                            # Core functionality
│   ├── exceptions/                  # Custom exceptions
│   │   └── api_exception.dart       # API exception classes
│   └── models/                      # Data models
│       ├── base_response.dart       # Base response and pagination models
│       ├── user_model.dart          # User model
│       ├── report_model.dart        # Report model
│       └── notification_model.dart  # Notification model
│
├── controllers/                     # State management controllers
│   ├── auth_controller.dart        # Authentication controller
│   ├── report_controller.dart      # Report controller
│   └── notification_controller.dart # Notification controller
│
├── services/                        # Backend API services
│   ├── api_client.dart              # Base HTTP client (Dio)
│   ├── api_error_handler.dart      # Error handling utilities
│   ├── token_manager.dart          # Token storage and management
│   ├── auth_service.dart           # Authentication APIs
│   ├── report_service.dart         # Report APIs
│   ├── location_service.dart       # Location APIs
│   ├── map_service.dart            # Map & Heat Map APIs
│   ├── user_service.dart           # User profile APIs
│   ├── watch_group_service.dart    # Watch Group APIs
│   ├── forum_service.dart          # Forum APIs
│   ├── notification_service.dart   # Notification APIs
│   ├── file_upload_service.dart    # File upload APIs
│   ├── draft_service.dart          # Draft auto-save (existing)
│   └── offline_reports_service.dart # Offline reports (existing)
│
├── utils/                          # Utility functions
│   ├── validators.dart             # Input validators
│   ├── date_formatter.dart         # Date/time formatting
│   ├── network_utils.dart          # Network connectivity
│   └── file_utils.dart             # File operations
│
├── screens/                        # UI Screens (existing)
│   └── ... (all your existing screens)
│
├── l10n/                           # Localization (existing)
│   └── ... (localization files)
│
├── app.dart                        # App configuration
└── main.dart                       # Entry point
```

---

## 📋 **FILE DESCRIPTIONS**

### **📁 config/**
- **`app_config.dart`**: Centralized configuration (base URLs, timeouts, file limits)
- **`constants.dart`**: App-wide constants (statuses, roles, incident types)

### **📁 core/exceptions/**
- **`api_exception.dart`**: Custom exception classes for API errors

### **📁 core/models/**
- **`base_response.dart`**: Standard response structure and pagination
- **`user_model.dart`**: User data model
- **`report_model.dart`**: Report data model
- **`notification_model.dart`**: Notification data model

### **📁 controllers/**
- **`auth_controller.dart`**: Manages authentication state
- **`report_controller.dart`**: Manages report state and operations
- **`notification_controller.dart`**: Manages notification state

### **📁 services/**
- **`api_client.dart`**: Base Dio client with interceptors
- **`api_error_handler.dart`**: Error handling utilities
- **`token_manager.dart`**: Token storage (SharedPreferences)
- **`auth_service.dart`**: Login, register, password reset
- **`report_service.dart`**: Create, get, delete reports
- **`location_service.dart`**: Reverse geocoding, location operations
- **`map_service.dart`**: Maps, heat maps, live incidents
- **`user_service.dart`**: User profile operations
- **`watch_group_service.dart`**: Watch group operations
- **`forum_service.dart`**: Forum posts and replies
- **`notification_service.dart`**: Notification operations
- **`file_upload_service.dart`**: File uploads

### **📁 utils/**
- **`validators.dart`**: Form input validators
- **`date_formatter.dart`**: Date/time formatting helpers
- **`network_utils.dart`**: Network connectivity checks
- **`file_utils.dart`**: File operation helpers

---

## 🔧 **USAGE EXAMPLES**

### **Using Controllers:**

```dart
import 'package:safereport_mobo/controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authController = AuthController();
  
  @override
  void initState() {
    super.initState();
    _authController.addListener(() {
      if (_authController.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    });
  }
  
  Future<void> _handleLogin() async {
    await _authController.login(email, password);
    if (_authController.error != null) {
      // Show error
    }
  }
}
```

### **Using Services Directly:**

```dart
import 'package:safereport_mobo/services/report_service.dart';

// Create report
final result = await ReportService.createReport(
  incidentType: 'Theft',
  description: 'Someone stole my bike',
  latitude: -1.9441,
  longitude: 30.0619,
  mediaFiles: [File('path/to/image.jpg')],
);

if (result['success'] == true) {
  // Success
} else {
  // Error: result['error']
}
```

### **Using Validators:**

```dart
import 'package:safereport_mobo/utils/validators.dart';

TextFormField(
  validator: Validators.email,
  // or
  validator: (value) => Validators.required(value, fieldName: 'Email'),
)
```

### **Using Date Formatter:**

```dart
import 'package:safereport_mobo/utils/date_formatter.dart';

Text(DateFormatter.formatRelativeTime(report.createdAt!))
// Output: "2 hours ago"
```

---

## ✅ **ALL FILES CREATED**

### **Config (2 files):**
- ✅ `lib/config/app_config.dart`
- ✅ `lib/config/constants.dart`

### **Core (4 files):**
- ✅ `lib/core/exceptions/api_exception.dart`
- ✅ `lib/core/models/base_response.dart`
- ✅ `lib/core/models/user_model.dart`
- ✅ `lib/core/models/report_model.dart`
- ✅ `lib/core/models/notification_model.dart`

### **Controllers (3 files):**
- ✅ `lib/controllers/auth_controller.dart`
- ✅ `lib/controllers/report_controller.dart`
- ✅ `lib/controllers/notification_controller.dart`

### **Services (12 files):**
- ✅ `lib/services/api_client.dart`
- ✅ `lib/services/api_error_handler.dart`
- ✅ `lib/services/token_manager.dart`
- ✅ `lib/services/auth_service.dart`
- ✅ `lib/services/report_service.dart`
- ✅ `lib/services/location_service.dart`
- ✅ `lib/services/map_service.dart`
- ✅ `lib/services/user_service.dart`
- ✅ `lib/services/watch_group_service.dart`
- ✅ `lib/services/forum_service.dart`
- ✅ `lib/services/notification_service.dart`
- ✅ `lib/services/file_upload_service.dart`

### **Utils (4 files):**
- ✅ `lib/utils/validators.dart`
- ✅ `lib/utils/date_formatter.dart`
- ✅ `lib/utils/network_utils.dart`
- ✅ `lib/utils/file_utils.dart`

---

## 🎯 **FEATURES**

✅ **Centralized Configuration** - All settings in one place
✅ **Type-Safe Models** - Proper data models for all entities
✅ **State Management** - Controllers for reactive UI updates
✅ **Error Handling** - Comprehensive error handling
✅ **Validation** - Reusable form validators
✅ **Utilities** - Helper functions for common operations
✅ **Backend Integration** - All APIs integrated and ready

---

## 🚀 **NEXT STEPS**

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Update base URL in `lib/config/app_config.dart`:**
   ```dart
   static const String baseUrl = 'http://your-backend-url:8080/api';
   ```

3. **Start using in your screens:**
   - Import controllers for state management
   - Import services for direct API calls
   - Use validators in forms
   - Use utilities for formatting

**Everything is ready to use!** 🎉

