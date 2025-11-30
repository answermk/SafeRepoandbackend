package com.crimeprevention.crime_backend.core.service.interfaces;

import com.crimeprevention.crime_backend.core.dto.notification.NotificationResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface NotificationService {

    /**
     * Get all notifications for a user with pagination
     */
    Page<NotificationResponse> getUserNotifications(UUID userId, Pageable pageable);

    /**
     * Get unread notifications for a user
     */
    List<NotificationResponse> getUnreadNotifications(UUID userId);

    /**
     * Get notification count for a user
     */
    long getUnreadNotificationCount(UUID userId);

    /**
     * Mark notifications as read
     */
    void markNotificationsAsRead(UUID userId, List<UUID> notificationIds);

    /**
     * Mark single notification as read
     */
    void markNotificationAsRead(UUID userId, UUID notificationId);

    /**
     * Delete a notification
     */
    void deleteNotification(UUID userId, UUID notificationId);

    /**
     * Get notifications by type for a user
     */
    Page<NotificationResponse> getNotificationsByType(UUID userId, String type, Pageable pageable);

    /**
     * Get notifications by priority for a user
     */
    Page<NotificationResponse> getNotificationsByPriority(UUID userId, String priority, Pageable pageable);

    // Message Notifications
    void notifyNewMessage(UUID receiverId, UUID senderId, String messagePreview);
    void notifyNewCaseMessage(UUID receiverId, UUID caseId, String caseTitle, String messagePreview);
    void notifyNewGroupMessage(UUID receiverId, UUID groupId, String groupName, String messagePreview);
    
    // Case Notifications
    void notifyCaseAssigned(UUID officerId, UUID caseId, String caseTitle);
    void notifyCaseStatusUpdate(UUID reporterId, UUID caseId, String caseTitle, String newStatus);
    void notifyNewEvidence(UUID officerId, UUID caseId, String caseTitle);
    
    // Watch Group Notifications
    void notifyGroupCreated(UUID adminId, UUID groupId, String groupName, String creatorName);
    void notifyGroupApproved(UUID creatorId, UUID groupId, String groupName, String officerName);
    void notifyGroupRejected(UUID creatorId, UUID groupId, String groupName, String reason);
    void notifyGroupOfficerAssigned(UUID groupId, String groupName, UUID officerId, String officerName);
    void notifyGroupMemberJoined(UUID groupId, String groupName, UUID memberId, String memberName);
    void notifyGroupMemberLeft(UUID groupId, String groupName, UUID memberId, String memberName);
    
    // Account Management Notifications
    void notifyAccountCreated(UUID userId, String userName);
    void notifyAccountUpdated(UUID userId, String updateType);
    void notifyAccountVerified(UUID userId, String userName);
    void notifyAccountDeactivated(UUID userId, String userName);
    void notifyPasswordChanged(UUID userId, String userName);
    void notifyPasswordResetRequested(UUID userId, String userName);
    void notifyPasswordResetCompleted(UUID userId, String userName);
    
    // System Notifications
    void notifySystemAlert(UUID userId, String title, String message, String priority);
    void notifyUserRoleChanged(UUID userId, String oldRole, String newRole);
    void notifyProfileUpdated(UUID userId, String updateType);
    
    // News and Updates
    void notifyNewsUpdate(UUID userId, String newsTitle, String newsContent);
    void notifySystemMaintenance(UUID userId, String maintenanceDetails);
    void notifySecurityAlert(UUID userId, String alertTitle, String alertMessage);
    
    // AI-Powered Predictive Alerts
    void notifyPredictiveAlert(UUID userId, String location, String crimeType, double probability, String riskLevel, List<String> recommendations);
    void notifyCrimeHotspotAlert(UUID userId, String location, String description, double riskScore, List<String> suggestedActions);
    void notifyRiskAssessmentAlert(UUID userId, String assessmentTitle, String riskSummary, double overallRisk, List<String> riskFactors);
    void notifyPatternDetectionAlert(UUID userId, String patternType, String description, double confidence, List<String> insights);
    
    // Bulk Predictive Alerts for Officers
    void notifyAllOfficersOfPredictiveAlert(String location, String crimeType, double probability, String riskLevel, List<String> recommendations);
    void notifyDistrictOfficersOfHotspot(String district, String description, double riskScore, List<String> suggestedActions);
    
    // Anomaly Detection Alerts
    void notifyAllOfficersOfAnomalyDetection(String riskLevel, int anomaliesDetected, List<String> keyInsights);
    void notifyAnomalyDetected(UUID userId, String anomalyType, String description, double anomalyScore, String severity);
    void notifyFalseReportDetected(UUID userId, String location, String crimeType, List<String> suspiciousFactors);
    void notifySuspiciousPatternDetected(UUID userId, String patternType, String description, double confidence);
    
    // User Activity Notifications
    void notifyLoginAttempt(UUID userId, String location, String deviceInfo);
    void notifyLoginSuccessful(UUID userId, String location, String deviceInfo);
    void notifyAccountLocked(UUID userId, String reason);
}
