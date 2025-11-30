# Flutter Mobile App - Backend Integration Guide
## Complete API Integration for SafeReport Backend (Java Spring Boot)

---

## 📋 **OVERVIEW**

This guide shows how to integrate your Flutter mobile app with the existing Java Spring Boot backend located at:
```
C:\Users\answer\Documents\SAFE REPORT\SafeReport-Backend-APIS-main
```

**Important:** This guide shows how to interact with the backend **without modifying the backend code**.

---

## 🔧 **BACKEND CONFIGURATION**

### **Base URL**
```dart
// Update this based on your backend deployment
const String baseUrl = 'http://localhost:8080/api';  // Local development
// const String baseUrl = 'https://api.saferreport.com/api';  // Production
```

### **CORS Configuration**
The backend has CORS configured for `http://localhost:5173` (web). For Flutter mobile apps, CORS is not an issue, but ensure your backend allows your mobile app's requests.

---

## 📦 **REQUIRED PACKAGES**

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.2.0
  dio: ^5.4.0  # Alternative to http (more features)
  shared_preferences: ^2.2.2
  connectivity_plus: ^5.0.2
```

---

## 🔐 **AUTHENTICATION**

### **1. Login**

**Backend Endpoint:** `POST /api/auth/login`

**Flutter Implementation:**

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String baseUrl = 'http://localhost:8080/api';
  
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Response: { "token": "...", "email": "...", "username": "..." }
        return {
          'success': true,
          'token': data['token'],
          'email': data['email'],
          'username': data['username'],
        };
      } else {
        return {
          'success': false,
          'error': 'Invalid credentials',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
}
```

### **2. Register**

**Backend Endpoint:** `POST /api/auth/register`

**Flutter Implementation:**

```dart
static Future<Map<String, dynamic>> register({
  required String email,
  required String password,
  required String fullName,
  String? phone,
  String? location,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'fullName': fullName,
        if (phone != null) 'phone': phone,
        if (location != null) 'location': location,
      }),
    );
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': response.body, // "User registered successfully"
      };
    } else {
      return {
        'success': false,
        'error': response.body,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Connection error: ${e.toString()}',
    };
  }
}
```

### **3. Forgot Password**

**Backend Endpoint:** `POST /api/auth/forgot-password`

```dart
static Future<Map<String, dynamic>> forgotPassword(String email) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
      }),
    );
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': response.body,
      };
    } else {
      return {
        'success': false,
        'error': response.body,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Connection error: ${e.toString()}',
    };
  }
}
```

### **4. Reset Password**

**Backend Endpoint:** `POST /api/auth/reset-password`

```dart
static Future<Map<String, dynamic>> resetPassword({
  required String token,
  required String newPassword,
  required String confirmPassword,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'token': token,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': response.body,
      };
    } else {
      return {
        'success': false,
        'error': response.body,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Connection error: ${e.toString()}',
    };
  }
}
```

### **5. Token Storage**

```dart
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'user_email';
  static const String _usernameKey = 'username';
  
  static Future<void> saveToken(String token, String email, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_usernameKey, username);
  }
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_usernameKey);
  }
  
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
```

---

## 📝 **REPORTS API**

### **1. Create Report (with File Upload)**

**Backend Endpoint:** `POST /api/reports`

**Important:** The backend accepts both multipart/form-data (with files) and JSON (without files).

**Flutter Implementation:**

```dart
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path/path.dart' as path;

class ReportService {
  static const String baseUrl = 'http://localhost:8080/api';
  
  static Future<String?> getAuthToken() async {
    return await TokenManager.getToken();
  }
  
  static Future<Map<String, dynamic>> createReport({
    required String incidentType,
    required String description,
    required double latitude,
    required double longitude,
    String? address,
    bool isAnonymous = false,
    String? priority,
    List<File>? mediaFiles,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      // If no files, use JSON request
      if (mediaFiles == null || mediaFiles.isEmpty) {
        final response = await http.post(
          Uri.parse('$baseUrl/reports'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'incidentType': incidentType,
            'description': description,
            'latitude': latitude,
            'longitude': longitude,
            if (address != null) 'address': address,
            'isAnonymous': isAnonymous,
            if (priority != null) 'priority': priority,
          }),
        );
        
        if (response.statusCode == 201) {
          return {
            'success': true,
            'data': jsonDecode(response.body),
          };
        } else {
          return {
            'success': false,
            'error': response.body,
          };
        }
      }
      
      // If files exist, use multipart request
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/reports'));
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add JSON data as a part
      request.fields['request'] = jsonEncode({
        'incidentType': incidentType,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        if (address != null) 'address': address,
        'isAnonymous': isAnonymous,
        if (priority != null) 'priority': priority,
      });
      
      // Add files
      for (var file in mediaFiles) {
        var fileStream = http.ByteStream(file.openRead());
        var length = await file.length();
        var multipartFile = http.MultipartFile(
          'files',
          fileStream,
          length,
          filename: path.basename(file.path),
        );
        request.files.add(multipartFile);
      }
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
}
```

### **2. Get My Reports**

**Backend Endpoint:** `GET /api/reports/my-reports`

```dart
static Future<Map<String, dynamic>> getMyReports({
  int page = 0,
  int size = 10,
  String sortBy = 'createdAt',
  String sortDir = 'desc',
}) async {
  try {
    final token = await getAuthToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    final uri = Uri.parse('$baseUrl/reports/my-reports').replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
        'sortBy': sortBy,
        'sortDir': sortDir,
      },
    );
    
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'data': data['content'], // List of reports
        'totalPages': data['totalPages'],
        'totalElements': data['totalElements'],
        'currentPage': data['number'],
      };
    } else {
      return {
        'success': false,
        'error': response.body,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Connection error: ${e.toString()}',
    };
  }
}
```

### **3. Get Report by ID**

**Backend Endpoint:** `GET /api/reports/{reportId}`

```dart
static Future<Map<String, dynamic>> getReport(String reportId) async {
  try {
    final token = await getAuthToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    final response = await http.get(
      Uri.parse('$baseUrl/reports/$reportId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': jsonDecode(response.body),
      };
    } else {
      return {
        'success': false,
        'error': response.body,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Connection error: ${e.toString()}',
    };
  }
}
```

### **4. Delete Report**

**Backend Endpoint:** `DELETE /api/reports/{reportId}`

```dart
static Future<Map<String, dynamic>> deleteReport(String reportId) async {
  try {
    final token = await getAuthToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    final response = await http.delete(
      Uri.parse('$baseUrl/reports/$reportId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 204) {
      return {'success': true};
    } else {
      return {
        'success': false,
        'error': response.body,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Connection error: ${e.toString()}',
    };
  }
}
```

---

## 📍 **LOCATION API**

### **1. Reverse Geocoding**

**Backend Endpoint:** `GET /api/locations/reverse-geocode?lat={lat}&lon={lon}`

```dart
class LocationService {
  static const String baseUrl = 'http://localhost:8080/api';
  
  static Future<String?> getAuthToken() async {
    return await TokenManager.getToken();
  }
  
  static Future<Map<String, dynamic>> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final uri = Uri.parse('$baseUrl/locations/reverse-geocode').replace(
        queryParameters: {
          'lat': latitude.toString(),
          'lon': longitude.toString(),
        },
      );
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'address': data['display_name'] ?? '',
        };
      } else {
        return {
          'success': false,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
}
```

---

## 🗺️ **MAP & HEAT MAP API**

### **1. Generate Crime Map**

**Backend Endpoint:** `POST /api/maps/generate`

```dart
class MapService {
  static const String baseUrl = 'http://localhost:8080/api';
  
  static Future<String?> getAuthToken() async {
    return await TokenManager.getToken();
  }
  
  static Future<Map<String, dynamic>> generateCrimeMap({
    String? timeRange,  // e.g., "7d", "30d", "1y"
    String? mapType,    // "heatmap", "points", "clusters"
    List<String>? crimeTypes,
    double? north,
    double? south,
    double? east,
    double? west,
    int? maxPoints,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final requestBody = <String, dynamic>{};
      if (timeRange != null) requestBody['timeRange'] = timeRange;
      if (mapType != null) requestBody['mapType'] = mapType;
      if (crimeTypes != null) requestBody['crimeTypes'] = crimeTypes;
      if (north != null) requestBody['north'] = north;
      if (south != null) requestBody['south'] = south;
      if (east != null) requestBody['east'] = east;
      if (west != null) requestBody['west'] = west;
      if (maxPoints != null) requestBody['maxPoints'] = maxPoints;
      
      final response = await http.post(
        Uri.parse('$baseUrl/maps/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
}
```

### **2. Get Heat Map**

**Backend Endpoint:** `POST /api/maps/heatmap`

```dart
static Future<Map<String, dynamic>> getHeatMap({
  String? timeRange,
  List<String>? crimeTypes,
  double? north,
  double? south,
  double? east,
  double? west,
}) async {
  try {
    final token = await getAuthToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    final requestBody = <String, dynamic>{};
    if (timeRange != null) requestBody['timeRange'] = timeRange;
    if (crimeTypes != null) requestBody['crimeTypes'] = crimeTypes;
    if (north != null) requestBody['north'] = north;
    if (south != null) requestBody['south'] = south;
    if (east != null) requestBody['east'] = east;
    if (west != null) requestBody['west'] = west;
    
    final response = await http.post(
      Uri.parse('$baseUrl/maps/heatmap'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': jsonDecode(response.body),
      };
    } else {
      return {
        'success': false,
        'error': response.body,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Connection error: ${e.toString()}',
    };
  }
}
```

### **3. Get Live Incidents**

**Backend Endpoint:** `GET /api/maps/live-incidents`

```dart
static Future<Map<String, dynamic>> getLiveIncidents() async {
  try {
    final token = await getAuthToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    final response = await http.get(
      Uri.parse('$baseUrl/maps/live-incidents'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'data': data is List ? data : [data],
      };
    } else {
      return {
        'success': false,
        'error': response.body,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Connection error: ${e.toString()}',
    };
  }
}
```

### **4. Get Live Incidents in Area**

**Backend Endpoint:** `GET /api/maps/live-incidents/area?latitude={lat}&longitude={lon}&radiusKm={radius}`

```dart
static Future<Map<String, dynamic>> getLiveIncidentsInArea({
  required double latitude,
  required double longitude,
  required double radiusKm,
}) async {
  try {
    final token = await getAuthToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    final uri = Uri.parse('$baseUrl/maps/live-incidents/area').replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radiusKm': radiusKm.toString(),
      },
    );
    
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'data': data is List ? data : [data],
      };
    } else {
      return {
        'success': false,
        'error': response.body,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Connection error: ${e.toString()}',
    };
  }
}
```

### **5. Quick Crime Map**

**Backend Endpoint:** `GET /api/maps/quick/{timeRange}`

```dart
static Future<Map<String, dynamic>> getQuickCrimeMap({
  required String timeRange,  // "7d", "30d", "1y"
  String mapType = 'heatmap',
  int maxPoints = 100,
}) async {
  try {
    final token = await getAuthToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    final uri = Uri.parse('$baseUrl/maps/quick/$timeRange').replace(
      queryParameters: {
        'mapType': mapType,
        'maxPoints': maxPoints.toString(),
      },
    );
    
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': jsonDecode(response.body),
      };
    } else {
      return {
        'success': false,
        'error': response.body,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Connection error: ${e.toString()}',
    };
  }
}
```

---

## 👤 **USER API**

### **1. Get User Profile**

**Backend Endpoint:** `GET /api/users/{id}`

```dart
class UserService {
  static const String baseUrl = 'http://localhost:8080/api';
  
  static Future<String?> getAuthToken() async {
    return await TokenManager.getToken();
  }
  
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
}
```

### **2. Update User Profile**

**Backend Endpoint:** `PUT /api/users/{id}`

```dart
static Future<Map<String, dynamic>> updateUserProfile({
  required String userId,
  String? fullName,
  String? phone,
  String? location,
  String? emergencyContactName,
  String? emergencyContactPhone,
}) async {
  try {
    final token = await getAuthToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    final requestBody = <String, dynamic>{};
    if (fullName != null) requestBody['fullName'] = fullName;
    if (phone != null) requestBody['phone'] = phone;
    if (location != null) requestBody['location'] = location;
    if (emergencyContactName != null) requestBody['emergencyContactName'] = emergencyContactName;
    if (emergencyContactPhone != null) requestBody['emergencyContactPhone'] = emergencyContactPhone;
    
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': jsonDecode(response.body),
      };
    } else {
      return {
        'success': false,
        'error': response.body,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Connection error: ${e.toString()}',
    };
  }
}
```

### **3. Change Password**

**Backend Endpoint:** `PUT /api/users/{id}/change-password`

```dart
static Future<Map<String, dynamic>> changePassword({
  required String userId,
  required String currentPassword,
  required String newPassword,
}) async {
  try {
    final token = await getAuthToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': jsonDecode(response.body)['message'],
      };
    } else {
      final error = jsonDecode(response.body);
      return {
        'success': false,
        'error': error['error'] ?? 'Failed to change password',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Connection error: ${e.toString()}',
    };
  }
}
```

---

## 👥 **WATCH GROUPS API**

### **1. Get My Watch Groups**

**Backend Endpoint:** `GET /api/watch-groups/my-groups`

```dart
class WatchGroupService {
  static const String baseUrl = 'http://localhost:8080/api';
  
  static Future<String?> getAuthToken() async {
    return await TokenManager.getToken();
  }
  
  static Future<Map<String, dynamic>> getMyWatchGroups({
    int page = 0,
    int size = 100,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final uri = Uri.parse('$baseUrl/watch-groups/my-groups').replace(
        queryParameters: {
          'page': page.toString(),
          'size': size.toString(),
          'sortBy': sortBy,
          'sortDir': sortDir,
        },
      );
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['content'],
          'totalPages': data['totalPages'],
          'totalElements': data['totalElements'],
        };
      } else {
        return {
          'success': false,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
}
```

### **2. Get All Watch Groups (Search)**

**Backend Endpoint:** `GET /api/watch-groups`

```dart
static Future<Map<String, dynamic>> getAllWatchGroups({
  int page = 0,
  int size = 50,
  String sortBy = 'createdAt',
  String sortDir = 'desc',
  double? latitude,
  double? longitude,
  double? radius,
}) async {
  try {
    final token = await getAuthToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy,
      'sortDir': sortDir,
    };
    
    if (latitude != null) queryParams['latitude'] = latitude.toString();
    if (longitude != null) queryParams['longitude'] = longitude.toString();
    if (radius != null) queryParams['radius'] = radius.toString();
    
    final uri = Uri.parse('$baseUrl/watch-groups').replace(
      queryParameters: queryParams,
    );
    
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'data': data['content'],
        'totalPages': data['totalPages'],
        'totalElements': data['totalElements'],
      };
    } else {
      return {
        'success': false,
        'error': response.body,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Connection error: ${e.toString()}',
    };
  }
}
```

### **3. Join Watch Group**

**Backend Endpoint:** `POST /api/watch-groups/{id}/members`

```dart
static Future<Map<String, dynamic>> joinWatchGroup(String groupId) async {
  try {
    final token = await getAuthToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/watch-groups/$groupId/members'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': jsonDecode(response.body),
      };
    } else {
      return {
        'success': false,
        'error': response.body,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Connection error: ${e.toString()}',
    };
  }
}
```

### **4. Leave Watch Group**

**Backend Endpoint:** `DELETE /api/watch-groups/{id}/members/{userId}`

```dart
static Future<Map<String, dynamic>> leaveWatchGroup({
  required String groupId,
  required String userId,
}) async {
  try {
    final token = await getAuthToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    final response = await http.delete(
      Uri.parse('$baseUrl/watch-groups/$groupId/members/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 204) {
      return {'success': true};
    } else {
      return {
        'success': false,
        'error': response.body,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Connection error: ${e.toString()}',
    };
  }
}
```

---

## 💬 **FORUM API**

### **1. Get All Forum Posts**

**Backend Endpoint:** `GET /api/forum/posts`

```dart
class ForumService {
  static const String baseUrl = 'http://localhost:8080/api';
  
  static Future<String?> getAuthToken() async {
    return await TokenManager.getToken();
  }
  
  static Future<Map<String, dynamic>> getAllPosts({
    int page = 0,
    int size = 50,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
    String? priority,
    String? status,
    String? category,
    String? location,
    String? search,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
        'sortBy': sortBy,
        'sortDir': sortDir,
      };
      
      if (priority != null) queryParams['priority'] = priority;
      if (status != null) queryParams['status'] = status;
      if (category != null) queryParams['category'] = category;
      if (location != null) queryParams['location'] = location;
      if (search != null) queryParams['search'] = search;
      
      final uri = Uri.parse('$baseUrl/forum/posts').replace(
        queryParameters: queryParams,
      );
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['content'],
          'totalPages': data['totalPages'],
          'totalElements': data['totalElements'],
        };
      } else {
        return {
          'success': false,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
}
```

### **2. Create Forum Post**

**Backend Endpoint:** `POST /api/forum/posts`

```dart
static Future<Map<String, dynamic>> createPost({
  required String title,
  required String content,
  String? category,
  String? priority,
  String? location,
}) async {
  try {
    final token = await getAuthToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    final requestBody = <String, dynamic>{
      'title': title,
      'content': content,
    };
    
    if (category != null) requestBody['category'] = category;
    if (priority != null) requestBody['priority'] = priority;
    if (location != null) requestBody['location'] = location;
    
    final response = await http.post(
      Uri.parse('$baseUrl/forum/posts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );
    
    if (response.statusCode == 201) {
      return {
        'success': true,
        'data': jsonDecode(response.body),
      };
    } else {
      return {
        'success': false,
        'error': response.body,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Connection error: ${e.toString()}',
    };
  }
}
```

### **3. Add Reply to Post**

**Backend Endpoint:** `POST /api/forum/posts/{postId}/replies`

```dart
static Future<Map<String, dynamic>> addReply({
  required String postId,
  required String content,
}) async {
  try {
    final token = await getAuthToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/forum/posts/$postId/replies'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'content': content,
      }),
    );
    
    if (response.statusCode == 201) {
      return {
        'success': true,
        'data': jsonDecode(response.body),
      };
    } else {
      return {
        'success': false,
        'error': response.body,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Connection error: ${e.toString()}',
    };
  }
}
```

---

## 🔔 **NOTIFICATIONS API**

### **1. Get Notifications**

**Backend Endpoint:** `GET /api/notifications`

```dart
class NotificationService {
  static const String baseUrl = 'http://localhost:8080/api';
  
  static Future<String?> getAuthToken() async {
    return await TokenManager.getToken();
  }
  
  static Future<Map<String, dynamic>> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final uri = Uri.parse('$baseUrl/notifications').replace(
        queryParameters: {
          'page': page.toString(),
          'size': size.toString(),
        },
      );
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['content'],
          'totalPages': data['totalPages'],
          'totalElements': data['totalElements'],
        };
      } else {
        return {
          'success': false,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
}
```

### **2. Get Unread Count**

**Backend Endpoint:** `GET /api/notifications/count`

```dart
static Future<Map<String, dynamic>> getUnreadCount() async {
  try {
    final token = await getAuthToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/count'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'count': jsonDecode(response.body),
      };
    } else {
      return {
        'success': false,
        'error': response.body,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Connection error: ${e.toString()}',
    };
  }
}
```

### **3. Mark Notification as Read**

**Backend Endpoint:** `PUT /api/notifications/{notificationId}/read`

```dart
static Future<Map<String, dynamic>> markAsRead(String notificationId) async {
  try {
    final token = await getAuthToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/$notificationId/read'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      return {'success': true};
    } else {
      return {
        'success': false,
        'error': response.body,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Connection error: ${e.toString()}',
    };
  }
}
```

---

## 📁 **FILE UPLOAD API**

### **Upload File**

**Backend Endpoint:** `POST /api/upload`

```dart
class FileUploadService {
  static const String baseUrl = 'http://localhost:8080/api';
  
  static Future<String?> getAuthToken() async {
    return await TokenManager.getToken();
  }
  
  static Future<Map<String, dynamic>> uploadFile(File file) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      
      var fileStream = http.ByteStream(file.openRead());
      var length = await file.length();
      var multipartFile = http.MultipartFile(
        'file',
        fileStream,
        length,
        filename: path.basename(file.path),
      );
      
      request.files.add(multipartFile);
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'url': data['url'],
          'path': data['path'],
          'fileName': data['fileName'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Upload failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
}
```

---

## 🔧 **HTTP CLIENT SETUP (Alternative using Dio)**

For better error handling and interceptors, use Dio:

```dart
import 'package:dio/dio.dart';

class ApiClient {
  static Dio? _dio;
  static const String baseUrl = 'http://localhost:8080/api';
  
  static Dio get dio {
    if (_dio == null) {
      _dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ));
      
      // Add interceptor for authentication
      _dio!.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenManager.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Handle unauthorized - clear token and redirect to login
            TokenManager.clearToken();
          }
          return handler.next(error);
        },
      ));
    }
    return _dio!;
  }
}

// Usage example:
final response = await ApiClient.dio.post('/auth/login', data: {
  'email': email,
  'password': password,
});
```

---

## 📝 **COMPLETE SERVICE FILE STRUCTURE**

Create these service files in your Flutter project:

```
lib/
├── services/
│   ├── api_client.dart          # Base HTTP client setup
│   ├── auth_service.dart        # Authentication APIs
│   ├── report_service.dart      # Report APIs
│   ├── location_service.dart    # Location APIs
│   ├── map_service.dart         # Map & Heat Map APIs
│   ├── user_service.dart        # User APIs
│   ├── watch_group_service.dart # Watch Group APIs
│   ├── forum_service.dart       # Forum APIs
│   ├── notification_service.dart # Notification APIs
│   ├── file_upload_service.dart # File Upload APIs
│   └── token_manager.dart       # Token storage
```

---

## 🎯 **USAGE EXAMPLE IN FLUTTER SCREEN**

```dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/token_manager.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  
  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    
    final result = await AuthService.login(
      _emailController.text,
      _passwordController.text,
    );
    
    setState(() => _isLoading = false);
    
    if (result['success'] == true) {
      // Save token
      await TokenManager.saveToken(
        result['token'],
        result['email'],
        result['username'],
      );
      
      // Navigate to dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Login failed')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(controller: _emailController),
          TextField(controller: _passwordController, obscureText: true),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            child: _isLoading ? CircularProgressIndicator() : Text('Login'),
          ),
        ],
      ),
    );
  }
}
```

---

## 🔒 **ERROR HANDLING**

Create a centralized error handler:

```dart
class ApiErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please check your internet.';
        case DioExceptionType.badResponse:
          if (error.response?.statusCode == 401) {
            return 'Unauthorized. Please login again.';
          } else if (error.response?.statusCode == 403) {
            return 'Access denied.';
          } else if (error.response?.statusCode == 404) {
            return 'Resource not found.';
          } else if (error.response?.statusCode == 500) {
            return 'Server error. Please try again later.';
          }
          return 'Error: ${error.response?.statusCode}';
        case DioExceptionType.cancel:
          return 'Request cancelled.';
        default:
          return 'Network error. Please check your connection.';
      }
    }
    return 'An unexpected error occurred.';
  }
}
```

---

## 📊 **SUMMARY**

### **All Available Endpoints:**

✅ **Authentication:**
- POST `/api/auth/login`
- POST `/api/auth/register`
- POST `/api/auth/forgot-password`
- POST `/api/auth/reset-password`
- GET `/api/auth/validate-reset-token/{token}`

✅ **Reports:**
- POST `/api/reports` (with multipart file support)
- GET `/api/reports/my-reports`
- GET `/api/reports/{reportId}`
- DELETE `/api/reports/{reportId}`

✅ **Location:**
- GET `/api/locations/reverse-geocode`

✅ **Maps:**
- POST `/api/maps/generate`
- POST `/api/maps/heatmap`
- POST `/api/maps/clusters`
- POST `/api/maps/points`
- GET `/api/maps/live-incidents`
- GET `/api/maps/live-incidents/area`
- GET `/api/maps/quick/{timeRange}`

✅ **Users:**
- GET `/api/users/{id}`
- PUT `/api/users/{id}`
- PUT `/api/users/{id}/change-password`

✅ **Watch Groups:**
- GET `/api/watch-groups/my-groups`
- GET `/api/watch-groups`
- POST `/api/watch-groups/{id}/members` (join)
- DELETE `/api/watch-groups/{id}/members/{userId}` (leave)

✅ **Forum:**
- GET `/api/forum/posts`
- POST `/api/forum/posts`
- POST `/api/forum/posts/{postId}/replies`

✅ **Notifications:**
- GET `/api/notifications`
- GET `/api/notifications/count`
- PUT `/api/notifications/{id}/read`

✅ **File Upload:**
- POST `/api/upload`

**All endpoints are ready to use! Just implement the Flutter service classes as shown above.** 🚀

