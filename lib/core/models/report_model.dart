/// Report Model
/// Represents a crime report
class ReportModel {
  final String id;
  final String userId;
  final String incidentType;
  final String description;
  final double latitude;
  final double longitude;
  final String? address;
  final String status;
  final String? priority;
  final bool isAnonymous;
  final List<String>? mediaUrls;
  final String? assignedOfficerId;
  final DateTime? submittedAt;
  final DateTime? resolvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReportModel({
    required this.id,
    required this.userId,
    required this.incidentType,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.status,
    this.priority,
    required this.isAnonymous,
    this.mediaUrls,
    this.assignedOfficerId,
    this.submittedAt,
    this.resolvedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      incidentType: json['incidentType'] ?? '',
      description: json['description'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'],
      status: json['status'] ?? 'SUBMITTED',
      priority: json['priority'],
      isAnonymous: json['isAnonymous'] ?? false,
      mediaUrls: json['mediaUrls'] != null
          ? List<String>.from(json['mediaUrls'])
          : null,
      assignedOfficerId: json['assignedOfficerId']?.toString(),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'])
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'incidentType': incidentType,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'status': status,
      'priority': priority,
      'isAnonymous': isAnonymous,
      'mediaUrls': mediaUrls,
      'assignedOfficerId': assignedOfficerId,
      'submittedAt': submittedAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

