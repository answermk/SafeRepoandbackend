# Complete Backend Structure & API Documentation
## Mobile Flutter App - Full Backend Implementation Guide

---

## 🏗️ **BACKEND ARCHITECTURE**

```
backend/
├── config/
│   ├── database.dart          # Database configuration
│   ├── environment.dart       # Environment variables
│   └── cors.dart             # CORS configuration
├── controllers/
│   ├── auth_controller.dart
│   ├── report_controller.dart
│   ├── location_controller.dart
│   ├── map_controller.dart
│   ├── user_controller.dart
│   ├── community_controller.dart
│   ├── watch_group_controller.dart
│   ├── forum_controller.dart
│   ├── notification_controller.dart
│   └── media_controller.dart
├── models/
│   ├── user_model.dart
│   ├── report_model.dart
│   ├── location_model.dart
│   ├── watch_group_model.dart
│   ├── forum_post_model.dart
│   └── notification_model.dart
├── services/
│   ├── auth_service.dart
│   ├── report_service.dart
│   ├── location_service.dart
│   ├── map_service.dart
│   ├── heatmap_service.dart
│   ├── notification_service.dart
│   ├── file_upload_service.dart
│   └── email_service.dart
├── middleware/
│   ├── auth_middleware.dart
│   ├── validation_middleware.dart
│   └── error_handler.dart
├── routes/
│   ├── auth_routes.dart
│   ├── report_routes.dart
│   ├── location_routes.dart
│   ├── map_routes.dart
│   ├── user_routes.dart
│   ├── community_routes.dart
│   └── watch_group_routes.dart
├── utils/
│   ├── jwt_util.dart
│   ├── password_util.dart
│   ├── validation_util.dart
│   └── constants.dart
└── main.dart                  # Application entry point
```

---

## 📋 **COMPLETE API ENDPOINTS LIST**

### **🔐 AUTHENTICATION APIs**

#### **1. User Registration**
```
POST /api/auth/register
Content-Type: application/json

Request Body:
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "name": "John Doe",
  "phone": "+250788123456",
  "location": "Kigali, Rwanda"
}

Response:
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "token": "jwt_token_here",
    "user": {
      "id": "user_123",
      "email": "user@example.com",
      "name": "John Doe",
      "role": "citizen"
    }
  }
}
```

#### **2. User Login**
```
POST /api/auth/login
Content-Type: application/json

Request Body:
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}

Response:
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "jwt_token_here",
    "refreshToken": "refresh_token_here",
    "user": {
      "id": "user_123",
      "email": "user@example.com",
      "name": "John Doe",
      "role": "citizen",
      "phone": "+250788123456",
      "location": "Kigali, Rwanda"
    }
  }
}
```

#### **3. Refresh Token**
```
POST /api/auth/refresh-token
Content-Type: application/json

Request Body:
{
  "refreshToken": "refresh_token_here"
}

Response:
{
  "success": true,
  "data": {
    "token": "new_jwt_token_here"
  }
}
```

#### **4. Logout**
```
POST /api/auth/logout
Authorization: Bearer {token}

Response:
{
  "success": true,
  "message": "Logged out successfully"
}
```

#### **5. Change Password**
```
POST /api/auth/change-password
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "currentPassword": "OldPass123!",
  "newPassword": "NewPass123!"
}

Response:
{
  "success": true,
  "message": "Password changed successfully"
}
```

#### **6. Forgot Password**
```
POST /api/auth/forgot-password
Content-Type: application/json

Request Body:
{
  "email": "user@example.com"
}

Response:
{
  "success": true,
  "message": "Password reset link sent to email"
}
```

#### **7. Reset Password**
```
POST /api/auth/reset-password
Content-Type: application/json

Request Body:
{
  "token": "reset_token_from_email",
  "newPassword": "NewPass123!"
}

Response:
{
  "success": true,
  "message": "Password reset successfully"
}
```

---

### **📝 REPORT APIs**

#### **8. Submit Report**
```
POST /api/reports
Authorization: Bearer {token}
Content-Type: multipart/form-data

Request Body (Form Data):
{
  "incidentType": "Theft",
  "description": "Someone stole my bike",
  "location": {
    "latitude": -1.9441,
    "longitude": 30.0619,
    "address": "KG 123 St, Kigali"
  },
  "isAnonymous": false,
  "priority": "normal",
  "media": [File, File, ...]  // Images/Videos
}

Response:
{
  "success": true,
  "message": "Report submitted successfully",
  "data": {
    "reportId": "report_123",
    "status": "submitted",
    "submittedAt": "2024-01-15T10:30:00Z"
  }
}
```

#### **9. Get My Reports**
```
GET /api/reports/my-reports
Authorization: Bearer {token}
Query Parameters:
  - page: 1
  - limit: 20
  - status: submitted|reviewing|resolved|closed
  - sortBy: date|status
  - order: asc|desc

Response:
{
  "success": true,
  "data": {
    "reports": [
      {
        "id": "report_123",
        "incidentType": "Theft",
        "description": "Someone stole my bike",
        "location": {
          "latitude": -1.9441,
          "longitude": 30.0619,
          "address": "KG 123 St, Kigali"
        },
        "status": "submitted",
        "priority": "normal",
        "isAnonymous": false,
        "mediaUrls": [
          "https://api.saferreport.com/media/report_123_img1.jpg"
        ],
        "submittedAt": "2024-01-15T10:30:00Z",
        "updatedAt": "2024-01-15T10:30:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 45,
      "totalPages": 3
    }
  }
}
```

#### **10. Get Report Details**
```
GET /api/reports/{reportId}
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": {
    "id": "report_123",
    "incidentType": "Theft",
    "description": "Someone stole my bike",
    "location": {
      "latitude": -1.9441,
      "longitude": 30.0619,
      "address": "KG 123 St, Kigali"
    },
    "status": "reviewing",
    "priority": "normal",
    "isAnonymous": false,
    "mediaUrls": [...],
    "updates": [
      {
        "status": "reviewing",
        "message": "Report is being reviewed",
        "updatedAt": "2024-01-15T11:00:00Z"
      }
    ],
    "submittedAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T11:00:00Z"
  }
}
```

#### **11. Update Report**
```
PUT /api/reports/{reportId}
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "description": "Updated description",
  "incidentType": "Vandalism"
}

Response:
{
  "success": true,
  "message": "Report updated successfully"
}
```

#### **12. Delete Report**
```
DELETE /api/reports/{reportId}
Authorization: Bearer {token}

Response:
{
  "success": true,
  "message": "Report deleted successfully"
}
```

#### **13. Get Report Status**
```
GET /api/reports/{reportId}/status
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": {
    "status": "reviewing",
    "lastUpdated": "2024-01-15T11:00:00Z"
  }
}
```

---

### **📍 LOCATION & GPS APIs**

#### **14. Get Current Location**
```
GET /api/location/current
Authorization: Bearer {token}
Query Parameters:
  - latitude: -1.9441 (required)
  - longitude: 30.0619 (required)

Response:
{
  "success": true,
  "data": {
    "location": {
      "latitude": -1.9441,
      "longitude": 30.0619,
      "address": "KG 123 St, Kigali, Rwanda",
      "city": "Kigali",
      "district": "Nyarugenge",
      "country": "Rwanda"
    },
    "accuracy": 10.5,  // meters
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

#### **15. Reverse Geocoding (Coordinates to Address)**
```
POST /api/location/reverse-geocode
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "latitude": -1.9441,
  "longitude": 30.0619
}

Response:
{
  "success": true,
  "data": {
    "address": "KG 123 St, Kigali, Rwanda",
    "city": "Kigali",
    "district": "Nyarugenge",
    "country": "Rwanda",
    "postalCode": "00000"
  }
}
```

#### **16. Geocoding (Address to Coordinates)**
```
POST /api/location/geocode
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "address": "KG 123 St, Kigali, Rwanda"
}

Response:
{
  "success": true,
  "data": {
    "latitude": -1.9441,
    "longitude": 30.0619,
    "formattedAddress": "KG 123 St, Kigali, Rwanda"
  }
}
```

#### **17. Search Nearby Locations**
```
GET /api/location/nearby
Authorization: Bearer {token}
Query Parameters:
  - latitude: -1.9441 (required)
  - longitude: 30.0619 (required)
  - radius: 1000 (meters, default: 500)
  - type: landmark|business|all

Response:
{
  "success": true,
  "data": {
    "locations": [
      {
        "name": "Kigali Convention Centre",
        "latitude": -1.9441,
        "longitude": 30.0619,
        "address": "KG 123 St",
        "distance": 150.5,  // meters
        "type": "landmark"
      }
    ]
  }
}
```

#### **18. Save User Location**
```
POST /api/location/save
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "latitude": -1.9441,
  "longitude": 30.0619,
  "address": "KG 123 St, Kigali",
  "isDefault": true
}

Response:
{
  "success": true,
  "message": "Location saved successfully"
}
```

#### **19. Get Saved Locations**
```
GET /api/location/saved
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": {
    "locations": [
      {
        "id": "loc_123",
        "latitude": -1.9441,
        "longitude": 30.0619,
        "address": "KG 123 St, Kigali",
        "isDefault": true,
        "savedAt": "2024-01-15T10:30:00Z"
      }
    ]
  }
}
```

---

### **🗺️ MAP & HEAT MAP APIs**

#### **20. Get Map Data (Incidents in Area)**
```
GET /api/map/incidents
Authorization: Bearer {token}
Query Parameters:
  - north: -1.9000 (bounding box)
  - south: -1.9500
  - east: 30.1000
  - west: 30.0500
  - zoom: 12
  - incidentTypes: Theft,Vandalism (optional filter)

Response:
{
  "success": true,
  "data": {
    "incidents": [
      {
        "id": "report_123",
        "incidentType": "Theft",
        "latitude": -1.9441,
        "longitude": 30.0619,
        "status": "submitted",
        "priority": "normal",
        "reportedAt": "2024-01-15T10:30:00Z"
      }
    ],
    "bounds": {
      "north": -1.9000,
      "south": -1.9500,
      "east": 30.1000,
      "west": 30.0500
    }
  }
}
```

#### **21. Get Heat Map Data**
```
GET /api/map/heatmap
Authorization: Bearer {token}
Query Parameters:
  - north: -1.9000
  - south: -1.9500
  - east: 30.1000
  - west: 30.0500
  - period: week|month|year (default: week)
  - incidentTypes: Theft,Vandalism (optional)
  - gridSize: 100 (meters, default: 50)

Response:
{
  "success": true,
  "data": {
    "heatmap": [
      {
        "latitude": -1.9441,
        "longitude": 30.0619,
        "intensity": 0.75,  // 0.0 to 1.0
        "count": 12,  // Number of incidents
        "gridId": "grid_123"
      }
    ],
    "maxIntensity": 1.0,
    "minIntensity": 0.1,
    "period": "week",
    "totalIncidents": 45
  }
}
```

#### **22. Get Heat Map Statistics**
```
GET /api/map/heatmap/stats
Authorization: Bearer {token}
Query Parameters:
  - period: week|month|year

Response:
{
  "success": true,
  "data": {
    "totalIncidents": 45,
    "hotspots": [
      {
        "latitude": -1.9441,
        "longitude": 30.0619,
        "count": 12,
        "address": "KG 123 St, Kigali",
        "intensity": "high"
      }
    ],
    "trends": {
      "increase": 15,  // % increase
      "decrease": 0
    }
  }
}
```

#### **23. Get Nearby Incidents**
```
GET /api/map/nearby-incidents
Authorization: Bearer {token}
Query Parameters:
  - latitude: -1.9441 (required)
  - longitude: 30.0619 (required)
  - radius: 1000 (meters, default: 500)
  - limit: 20 (default: 10)

Response:
{
  "success": true,
  "data": {
    "incidents": [
      {
        "id": "report_123",
        "incidentType": "Theft",
        "latitude": -1.9441,
        "longitude": 30.0619,
        "distance": 150.5,  // meters
        "status": "submitted",
        "reportedAt": "2024-01-15T10:30:00Z"
      }
    ],
    "count": 5
  }
}
```

#### **24. Get Map Clusters (for Performance)**
```
GET /api/map/clusters
Authorization: Bearer {token}
Query Parameters:
  - north: -1.9000
  - south: -1.9500
  - east: 30.1000
  - west: 30.0500
  - zoom: 12 (map zoom level)

Response:
{
  "success": true,
  "data": {
    "clusters": [
      {
        "latitude": -1.9441,
        "longitude": 30.0619,
        "count": 5,  // Number of incidents in cluster
        "bounds": {
          "north": -1.9400,
          "south": -1.9480,
          "east": 30.0650,
          "west": 30.0580
        }
      }
    ]
  }
}
```

---

### **👤 USER PROFILE APIs**

#### **25. Get User Profile**
```
GET /api/user/profile
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": {
    "id": "user_123",
    "email": "user@example.com",
    "name": "John Doe",
    "phone": "+250788123456",
    "location": "Kigali, Rwanda",
    "emergencyContact": {
      "name": "Jane Doe",
      "phone": "+250788654321"
    },
    "avatarUrl": "https://api.saferreport.com/avatars/user_123.jpg",
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

#### **26. Update User Profile**
```
PUT /api/user/profile
Authorization: Bearer {token}
Content-Type: multipart/form-data

Request Body (Form Data):
{
  "name": "John Doe Updated",
  "phone": "+250788123456",
  "location": "Kigali, Rwanda",
  "emergencyContactName": "Jane Doe",
  "emergencyContactPhone": "+250788654321",
  "avatar": File (optional)
}

Response:
{
  "success": true,
  "message": "Profile updated successfully"
}
```

#### **27. Upload Avatar**
```
POST /api/user/avatar
Authorization: Bearer {token}
Content-Type: multipart/form-data

Request Body:
{
  "avatar": File
}

Response:
{
  "success": true,
  "data": {
    "avatarUrl": "https://api.saferreport.com/avatars/user_123.jpg"
  }
}
```

---

### **📊 COMMUNITY STATISTICS APIs**

#### **28. Get Community Statistics**
```
GET /api/community/statistics
Authorization: Bearer {token}
Query Parameters:
  - period: week|month|year (default: week)
  - area: district|city|all (default: all)

Response:
{
  "success": true,
  "data": {
    "totalReports": 39,
    "resolved": 28,
    "pending": 8,
    "avgResponseTime": 8,  // minutes
    "safetyLevel": "Good",
    "trends": [
      {
        "date": "2024-01-15",
        "count": 5
      }
    ],
    "incidentTypes": {
      "Theft": 12,
      "Vandalism": 8,
      "Suspicious Person": 7
    },
    "topAreas": [
      {
        "name": "Oak Street",
        "count": 12
      }
    ]
  }
}
```

#### **29. Get Community Status (Quick Overview)**
```
GET /api/community/status
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": {
    "thisWeekReports": 12,
    "avgResponse": "8 minutes",
    "safetyLevel": "Good"
  }
}
```

---

### **👥 WATCH GROUP APIs**

#### **30. Get My Watch Groups**
```
GET /api/watch-groups/my-groups
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": {
    "groups": [
      {
        "id": "group_123",
        "name": "Oak Street Watch",
        "description": "Neighborhood watch group",
        "memberCount": 25,
        "newAlerts": 2,
        "location": {
          "latitude": -1.9441,
          "longitude": 30.0619,
          "address": "Oak Street, Kigali"
        },
        "joinedAt": "2024-01-01T00:00:00Z"
      }
    ]
  }
}
```

#### **31. Get Watch Group Details**
```
GET /api/watch-groups/{groupId}
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": {
    "id": "group_123",
    "name": "Oak Street Watch",
    "description": "Neighborhood watch group",
    "memberCount": 25,
    "members": [
      {
        "id": "user_456",
        "name": "Jane Doe",
        "avatarUrl": "..."
      }
    ],
    "messages": [
      {
        "id": "msg_123",
        "userId": "user_456",
        "userName": "Jane Doe",
        "message": "Suspicious activity reported",
        "timestamp": "2024-01-15T10:30:00Z"
      }
    ],
    "location": {...}
  }
}
```

#### **32. Join Watch Group**
```
POST /api/watch-groups/{groupId}/join
Authorization: Bearer {token}

Response:
{
  "success": true,
  "message": "Joined watch group successfully"
}
```

#### **33. Leave Watch Group**
```
POST /api/watch-groups/{groupId}/leave
Authorization: Bearer {token}

Response:
{
  "success": true,
  "message": "Left watch group successfully"
}
```

#### **34. Send Message to Watch Group**
```
POST /api/watch-groups/{groupId}/messages
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "message": "Suspicious activity in the area"
}

Response:
{
  "success": true,
  "data": {
    "messageId": "msg_123",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

#### **35. Find More Groups**
```
GET /api/watch-groups/search
Authorization: Bearer {token}
Query Parameters:
  - query: "Oak Street" (search term)
  - latitude: -1.9441 (optional, for nearby)
  - longitude: 30.0619 (optional)
  - radius: 5000 (meters)

Response:
{
  "success": true,
  "data": {
    "groups": [
      {
        "id": "group_123",
        "name": "Oak Street Watch",
        "memberCount": 25,
        "distance": 150.5,  // meters
        "location": {...}
      }
    ]
  }
}
```

---

### **💬 FORUM APIs**

#### **36. Get Forum Posts**
```
GET /api/forum/posts
Authorization: Bearer {token}
Query Parameters:
  - page: 1
  - limit: 20
  - category: all|safety|general|tips

Response:
{
  "success": true,
  "data": {
    "posts": [
      {
        "id": "post_123",
        "title": "Safety Tips for Night",
        "content": "Always be aware...",
        "author": {
          "id": "user_456",
          "name": "Jane Doe",
          "avatarUrl": "..."
        },
        "category": "tips",
        "commentCount": 5,
        "likes": 12,
        "createdAt": "2024-01-15T10:30:00Z"
      }
    ],
    "pagination": {...}
  }
}
```

#### **37. Create Forum Post**
```
POST /api/forum/posts
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "title": "Safety Tips for Night",
  "content": "Always be aware of your surroundings...",
  "category": "tips"
}

Response:
{
  "success": true,
  "data": {
    "postId": "post_123"
  }
}
```

#### **38. Get Forum Post Details**
```
GET /api/forum/posts/{postId}
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": {
    "id": "post_123",
    "title": "Safety Tips for Night",
    "content": "Always be aware...",
    "author": {...},
    "comments": [
      {
        "id": "comment_123",
        "content": "Great tips!",
        "author": {...},
        "createdAt": "2024-01-15T11:00:00Z"
      }
    ],
    "likes": 12,
    "createdAt": "2024-01-15T10:30:00Z"
  }
}
```

#### **39. Add Comment to Post**
```
POST /api/forum/posts/{postId}/comments
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "content": "Great tips! Thanks for sharing."
}

Response:
{
  "success": true,
  "data": {
    "commentId": "comment_123"
  }
}
```

---

### **🔔 NOTIFICATION APIs**

#### **40. Get Notifications**
```
GET /api/notifications
Authorization: Bearer {token}
Query Parameters:
  - page: 1
  - limit: 20
  - unreadOnly: true|false

Response:
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": "notif_123",
        "type": "report_status_update",
        "title": "Report Status Updated",
        "message": "Your report has been reviewed",
        "isRead": false,
        "data": {
          "reportId": "report_123",
          "status": "resolved"
        },
        "createdAt": "2024-01-15T10:30:00Z"
      }
    ],
    "unreadCount": 5
  }
}
```

#### **41. Mark Notification as Read**
```
PUT /api/notifications/{notificationId}/read
Authorization: Bearer {token}

Response:
{
  "success": true
}
```

#### **42. Mark All Notifications as Read**
```
PUT /api/notifications/read-all
Authorization: Bearer {token}

Response:
{
  "success": true,
  "message": "All notifications marked as read"
}
```

#### **43. Delete Notification**
```
DELETE /api/notifications/{notificationId}
Authorization: Bearer {token}

Response:
{
  "success": true
}
```

---

### **📁 MEDIA/FILE APIs**

#### **44. Upload Media (Images/Videos)**
```
POST /api/media/upload
Authorization: Bearer {token}
Content-Type: multipart/form-data

Request Body:
{
  "file": File,
  "type": "report|avatar|evidence"
}

Response:
{
  "success": true,
  "data": {
    "fileId": "file_123",
    "url": "https://api.saferreport.com/media/file_123.jpg",
    "thumbnailUrl": "https://api.saferreport.com/media/thumb_file_123.jpg",
    "size": 1024000,  // bytes
    "mimeType": "image/jpeg"
  }
}
```

#### **45. Delete Media**
```
DELETE /api/media/{fileId}
Authorization: Bearer {token}

Response:
{
  "success": true
}
```

---

### **📈 ANALYTICS & IMPACT APIs**

#### **46. Get My Impact**
```
GET /api/user/impact
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": {
    "totalReports": 15,
    "resolvedReports": 12,
    "contributionScore": 85,
    "badges": [
      {
        "id": "badge_123",
        "name": "First Report",
        "icon": "first_report",
        "earnedAt": "2024-01-01T00:00:00Z"
      }
    ],
    "achievements": [
      {
        "title": "Community Helper",
        "description": "Submitted 10+ reports",
        "unlocked": true
      }
    ]
  }
}
```

---

### **⚙️ SETTINGS APIs**

#### **47. Get Settings**
```
GET /api/user/settings
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": {
    "notifications": {
      "reportUpdates": true,
      "communityAlerts": true,
      "watchGroupMessages": false
    },
    "privacy": {
      "showProfile": true,
      "allowMessages": true
    },
    "accessibility": {
      "fontSize": "medium",
      "highContrast": false,
      "textToSpeech": false
    },
    "language": "en"
  }
}
```

#### **48. Update Settings**
```
PUT /api/user/settings
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "notifications": {
    "reportUpdates": true,
    "communityAlerts": false
  },
  "accessibility": {
    "fontSize": "large"
  }
}

Response:
{
  "success": true,
  "message": "Settings updated successfully"
}
```

---

### **📱 OFFLINE QUEUE APIs**

#### **49. Sync Offline Reports**
```
POST /api/reports/sync
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "reports": [
    {
      "id": "local_report_123",
      "incidentType": "Theft",
      "description": "...",
      "location": {...},
      "submittedAt": "2024-01-15T10:30:00Z"
    }
  ]
}

Response:
{
  "success": true,
  "data": {
    "synced": [
      {
        "localId": "local_report_123",
        "serverId": "report_456",
        "status": "success"
      }
    ],
    "failed": []
  }
}
```

---

## 🗄️ **DATABASE SCHEMA**

### **Users Table**
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  location VARCHAR(255),
  emergency_contact_name VARCHAR(255),
  emergency_contact_phone VARCHAR(20),
  avatar_url TEXT,
  role VARCHAR(50) DEFAULT 'citizen',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### **Reports Table**
```sql
CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  incident_type VARCHAR(100) NOT NULL,
  description TEXT,
  location_lat DECIMAL(10, 8) NOT NULL,
  location_lng DECIMAL(11, 8) NOT NULL,
  location_address VARCHAR(255),
  status VARCHAR(50) DEFAULT 'submitted',
  priority VARCHAR(20) DEFAULT 'normal',
  is_anonymous BOOLEAN DEFAULT false,
  submitted_at TIMESTAMP DEFAULT NOW(),
  resolved_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_reports_location ON reports USING GIST (
  ll_to_earth(location_lat, location_lng)
);
CREATE INDEX idx_reports_user ON reports(user_id);
CREATE INDEX idx_reports_status ON reports(status);
```

### **Report Media Table**
```sql
CREATE TABLE report_media (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_id UUID REFERENCES reports(id) ON DELETE CASCADE,
  file_url TEXT NOT NULL,
  thumbnail_url TEXT,
  file_type VARCHAR(50),
  file_size BIGINT,
  mime_type VARCHAR(100),
  created_at TIMESTAMP DEFAULT NOW()
);
```

### **Locations Table**
```sql
CREATE TABLE user_locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  address VARCHAR(255),
  is_default BOOLEAN DEFAULT false,
  saved_at TIMESTAMP DEFAULT NOW()
);
```

### **Watch Groups Table**
```sql
CREATE TABLE watch_groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  location_lat DECIMAL(10, 8),
  location_lng DECIMAL(11, 8),
  location_address VARCHAR(255),
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE watch_group_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID REFERENCES watch_groups(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  joined_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(group_id, user_id)
);

CREATE TABLE watch_group_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID REFERENCES watch_groups(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### **Forum Posts Table**
```sql
CREATE TABLE forum_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  category VARCHAR(50),
  likes_count INT DEFAULT 0,
  comments_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE forum_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES forum_posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### **Notifications Table**
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT,
  data JSONB,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id, is_read);
```

---

## 🗺️ **MAP & HEAT MAP IMPLEMENTATION**

### **Heat Map Algorithm**

```dart
// Backend Service: Heat Map Generation
class HeatMapService {
  // Generate heat map data using grid-based approach
  Future<List<HeatMapPoint>> generateHeatMap({
    required double north,
    required double south,
    required double east,
    required double west,
    required int gridSize, // meters
    String? period,
  }) async {
    // 1. Get all reports in bounding box
    final reports = await ReportRepository.findInBounds(
      north: north,
      south: south,
      east: east,
      west: west,
      period: period,
    );
    
    // 2. Create grid
    final grid = _createGrid(north, south, east, west, gridSize);
    
    // 3. Count incidents per grid cell
    final cellCounts = <String, int>{};
    for (final report in reports) {
      final cellId = _getGridCell(
        report.latitude,
        report.longitude,
        grid,
      );
      cellCounts[cellId] = (cellCounts[cellId] ?? 0) + 1;
    }
    
    // 4. Calculate intensity (0.0 to 1.0)
    final maxCount = cellCounts.values.reduce(max);
    final heatMapPoints = <HeatMapPoint>[];
    
    for (final entry in cellCounts.entries) {
      final intensity = entry.value / maxCount;
      final cell = grid[entry.key]!;
      
      heatMapPoints.add(HeatMapPoint(
        latitude: cell.centerLat,
        longitude: cell.centerLng,
        intensity: intensity,
        count: entry.value,
        gridId: entry.key,
      ));
    }
    
    return heatMapPoints;
  }
  
  // Create grid cells
  Map<String, GridCell> _createGrid(
    double north,
    double south,
    double east,
    double west,
    int gridSize,
  ) {
    final grid = <String, GridCell>{};
    final latStep = _metersToLatitude(gridSize);
    final lngStep = _metersToLongitude(gridSize, (north + south) / 2);
    
    for (double lat = south; lat <= north; lat += latStep) {
      for (double lng = west; lng <= east; lng += lngStep) {
        final cellId = '${lat.toStringAsFixed(6)}_${lng.toStringAsFixed(6)}';
        grid[cellId] = GridCell(
          centerLat: lat + latStep / 2,
          centerLng: lng + lngStep / 2,
        );
      }
    }
    
    return grid;
  }
  
  double _metersToLatitude(double meters) {
    return meters / 111320.0; // 1 degree latitude ≈ 111.32 km
  }
  
  double _metersToLongitude(double meters, double latitude) {
    return meters / (111320.0 * cos(latitude * pi / 180));
  }
}
```

### **Spatial Indexing (PostgreSQL with PostGIS)**

```sql
-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- Add geometry column to reports
ALTER TABLE reports ADD COLUMN location_geom GEOMETRY(Point, 4326);

-- Create spatial index
CREATE INDEX idx_reports_location_geom ON reports USING GIST(location_geom);

-- Update geometry when lat/lng changes
CREATE OR REPLACE FUNCTION update_report_geometry()
RETURNS TRIGGER AS $$
BEGIN
  NEW.location_geom = ST_SetSRID(
    ST_MakePoint(NEW.location_lng, NEW.location_lat),
    4326
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_report_geometry
BEFORE INSERT OR UPDATE ON reports
FOR EACH ROW
EXECUTE FUNCTION update_report_geometry();

-- Query reports in bounding box
SELECT * FROM reports
WHERE ST_Within(
  location_geom,
  ST_MakeEnvelope(
    :west, :south, :east, :north, 4326
  )
);

-- Query nearby reports (within radius)
SELECT * FROM reports
WHERE ST_DWithin(
  location_geom,
  ST_SetSRID(ST_MakePoint(:lng, :lat), 4326),
  :radius_meters / 111320.0  -- Convert meters to degrees
);
```

---

## 📍 **GPS & LOCATION SERVICES**

### **Location Service Implementation**

```dart
// Backend Service: Location Services
class LocationService {
  // Reverse geocoding using external API (Google Maps, Mapbox, etc.)
  Future<Address> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    // Option 1: Use Google Maps Geocoding API
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=$latitude,$longitude'
        '&key=${env.googleMapsApiKey}',
      ),
    );
    
    final data = jsonDecode(response.body);
    if (data['status'] == 'OK' && data['results'].isNotEmpty) {
      final result = data['results'][0];
      return Address(
        formatted: result['formatted_address'],
        city: _extractComponent(result, 'locality'),
        district: _extractComponent(result, 'administrative_area_level_2'),
        country: _extractComponent(result, 'country'),
      );
    }
    
    throw Exception('Geocoding failed');
  }
  
  // Geocoding (address to coordinates)
  Future<Coordinates> geocode(String address) async {
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?address=${Uri.encodeComponent(address)}'
        '&key=${env.googleMapsApiKey}',
      ),
    );
    
    final data = jsonDecode(response.body);
    if (data['status'] == 'OK' && data['results'].isNotEmpty) {
      final location = data['results'][0]['geometry']['location'];
      return Coordinates(
        latitude: location['lat'],
        longitude: location['lng'],
      );
    }
    
    throw Exception('Geocoding failed');
  }
  
  // Calculate distance between two points (Haversine formula)
  double calculateDistance({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    const double earthRadius = 6371000; // meters
    
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
        cos(_toRadians(lat2)) *
        sin(dLng / 2) *
        sin(dLng / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  double _toRadians(double degrees) => degrees * (pi / 180);
}
```

---

## 🔧 **BACKEND TECHNOLOGY STACK**

### **Recommended Stack:**

1. **Backend Framework:**
   - Dart (Shelf) - If using Dart
   - Node.js (Express) - Popular choice
   - Python (FastAPI/Django) - Easy to use
   - Java (Spring Boot) - Enterprise grade

2. **Database:**
   - PostgreSQL with PostGIS extension (for spatial queries)
   - Redis (for caching and sessions)

3. **File Storage:**
   - AWS S3 / Google Cloud Storage
   - Or local storage with CDN

4. **External Services:**
   - Google Maps API / Mapbox (for geocoding)
   - Firebase Cloud Messaging (for push notifications)
   - SendGrid / AWS SES (for emails)

5. **Authentication:**
   - JWT tokens
   - Refresh tokens

---

## 🚀 **DEPLOYMENT**

### **Backend Deployment:**
- **Cloud Platforms:** AWS, Google Cloud, Azure, Heroku
- **Container:** Docker + Kubernetes
- **API Gateway:** For rate limiting, authentication

### **Environment Variables:**
```env
DATABASE_URL=postgresql://user:pass@localhost:5432/saferreport
JWT_SECRET=your_secret_key_here
GOOGLE_MAPS_API_KEY=your_google_maps_key
AWS_ACCESS_KEY_ID=your_aws_key
AWS_SECRET_ACCESS_KEY=your_aws_secret
S3_BUCKET_NAME=saferreport-media
REDIS_URL=redis://localhost:6379
```

---

## 📝 **API RESPONSE STANDARDS**

### **Success Response:**
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```

### **Error Response:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": { ... }
  }
}
```

### **HTTP Status Codes:**
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Internal Server Error

---

## 🔒 **SECURITY CONSIDERATIONS**

1. **Authentication:**
   - JWT tokens with expiration
   - Refresh token rotation
   - Password hashing (bcrypt)

2. **Authorization:**
   - Role-based access control
   - Resource ownership checks

3. **Data Validation:**
   - Input validation on all endpoints
   - SQL injection prevention
   - XSS prevention

4. **Rate Limiting:**
   - Limit API calls per user
   - Prevent abuse

5. **HTTPS:**
   - All API calls over HTTPS
   - Certificate validation

---

## 📊 **SUMMARY**

### **Complete Backend Includes:**

✅ **49 API Endpoints** covering:
- Authentication (7 endpoints)
- Reports (6 endpoints)
- Location & GPS (6 endpoints)
- Maps & Heat Maps (5 endpoints)
- User Profile (3 endpoints)
- Community Statistics (2 endpoints)
- Watch Groups (6 endpoints)
- Forum (4 endpoints)
- Notifications (4 endpoints)
- Media (2 endpoints)
- Analytics (1 endpoint)
- Settings (2 endpoints)
- Offline Sync (1 endpoint)

✅ **Database Schema** with:
- Users, Reports, Locations
- Watch Groups, Forum Posts
- Notifications, Media
- Spatial indexing for maps

✅ **Map & Heat Map** features:
- Grid-based heat map generation
- Spatial queries with PostGIS
- Clustering for performance

✅ **GPS Integration:**
- Reverse geocoding
- Geocoding
- Distance calculations
- Nearby search

**Your backend is ready to implement!** 🚀

