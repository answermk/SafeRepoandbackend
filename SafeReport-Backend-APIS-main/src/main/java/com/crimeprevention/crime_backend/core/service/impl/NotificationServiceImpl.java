package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.dto.notification.NotificationResponse;
import com.crimeprevention.crime_backend.core.model.enums.NotificationPriority;
import com.crimeprevention.crime_backend.core.model.enums.NotificationType;
import com.crimeprevention.crime_backend.core.model.notification.Notification;
import com.crimeprevention.crime_backend.core.model.user.User;
import com.crimeprevention.crime_backend.core.repo.notification.NotificationRepository;
import com.crimeprevention.crime_backend.core.repo.user.UserRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;
import com.crimeprevention.crime_backend.core.model.enums.UserRole;
import java.util.Arrays;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationServiceImpl implements NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional(readOnly = true)
    public Page<NotificationResponse> getUserNotifications(UUID userId, Pageable pageable) {
        Page<Notification> notifications = notificationRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable);
        return notifications.map(this::buildNotificationResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public List<NotificationResponse> getUnreadNotifications(UUID userId) {
        List<Notification> notifications = notificationRepository.findByUserIdAndIsReadFalseOrderByCreatedAtDesc(userId);
        return notifications.stream()
                .map(this::buildNotificationResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public long getUnreadNotificationCount(UUID userId) {
        return notificationRepository.countByUserIdAndIsReadFalse(userId);
    }

    @Override
    @Transactional
    public void markNotificationsAsRead(UUID userId, List<UUID> notificationIds) {
        notificationRepository.markNotificationsAsRead(notificationIds, Instant.now());
        log.info("Marked {} notifications as read for user: {}", notificationIds.size(), userId);
    }

    @Override
    @Transactional
    public void markNotificationAsRead(UUID userId, UUID notificationId) {
        markNotificationsAsRead(userId, List.of(notificationId));
    }

    @Override
    @Transactional
    public void deleteNotification(UUID userId, UUID notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new IllegalArgumentException("Notification not found"));
        
        if (!notification.getUser().getId().equals(userId)) {
            throw new SecurityException("You can only delete your own notifications");
        }
        
        notificationRepository.delete(notification);
        log.info("Deleted notification: {} for user: {}", notificationId, userId);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<NotificationResponse> getNotificationsByType(UUID userId, String type, Pageable pageable) {
        Page<Notification> notifications = notificationRepository.findByUserIdAndTypeOrderByCreatedAtDesc(userId, type, pageable);
        return notifications.map(this::buildNotificationResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<NotificationResponse> getNotificationsByPriority(UUID userId, String priority, Pageable pageable) {
        Page<Notification> notifications = notificationRepository.findByUserIdAndPriorityOrderByCreatedAtDesc(userId, priority, pageable);
        return notifications.map(this::buildNotificationResponse);
    }

    // Notification Creation Methods

    @Override
    @Transactional
    public void notifyNewMessage(UUID receiverId, UUID senderId, String messagePreview) {
        User sender = userRepository.findById(senderId).orElse(null);
        if (sender == null) return;
        
        createNotification(
            receiverId,
            NotificationType.NEW_MESSAGE,
            "New Message",
            String.format("New message from %s: %s", sender.getFullName(), messagePreview),
            NotificationPriority.NORMAL,
            "/messages",
            "USER",
            senderId
        );
    }

    @Override
    @Transactional
    public void notifyNewCaseMessage(UUID receiverId, UUID caseId, String caseTitle, String messagePreview) {
        createNotification(
            receiverId,
            NotificationType.NEW_CASE_MESSAGE,
            "New Case Message",
            String.format("New message in case '%s': %s", caseTitle, messagePreview),
            NotificationPriority.HIGH,
            "/cases/" + caseId,
            "REPORT",
            caseId
        );
    }

    @Override
    @Transactional
    public void notifyNewGroupMessage(UUID receiverId, UUID groupId, String groupName, String messagePreview) {
        createNotification(
            receiverId,
            NotificationType.NEW_GROUP_MESSAGE,
            "New Group Message",
            String.format("New message in '%s': %s", groupName, messagePreview),
            NotificationPriority.NORMAL,
            "/watch-groups/" + groupId,
            "WATCH_GROUP",
            groupId
        );
    }

    @Override
    @Transactional
    public void notifyCaseAssigned(UUID officerId, UUID caseId, String caseTitle) {
        createNotification(
            officerId,
            NotificationType.CASE_ASSIGNED,
            "Case Assigned",
            String.format("You have been assigned to case: %s", caseTitle),
            NotificationPriority.HIGH,
            "/cases/" + caseId,
            "REPORT",
            caseId
        );
    }

    @Override
    @Transactional
    public void notifyCaseStatusUpdate(UUID reporterId, UUID caseId, String caseTitle, String newStatus) {
        createNotification(
            reporterId,
            NotificationType.CASE_STATUS_UPDATED,
            "Case Status Updated",
            String.format("Your case '%s' status has been updated to: %s", caseTitle, newStatus),
            NotificationPriority.HIGH,
            "/cases/" + caseId,
            "REPORT",
            caseId
        );
    }

    @Override
    @Transactional
    public void notifyNewEvidence(UUID officerId, UUID caseId, String caseTitle) {
        createNotification(
            officerId,
            NotificationType.CASE_EVIDENCE_ADDED,
            "New Evidence Added",
            String.format("New evidence has been added to case: %s", caseTitle),
            NotificationPriority.HIGH,
            "/cases/" + caseId,
            "REPORT",
            caseId
        );
    }

    @Override
    @Transactional
    public void notifyGroupCreated(UUID adminId, UUID groupId, String groupName, String creatorName) {
        createNotification(
            adminId,
            NotificationType.GROUP_CREATED,
            "New Watch Group Created",
            String.format("New watch group '%s' created by %s requires approval", groupName, creatorName),
            NotificationPriority.HIGH,
            "/watch-groups/pending",
            "WATCH_GROUP",
            groupId
        );
    }

    @Override
    @Transactional
    public void notifyGroupApproved(UUID creatorId, UUID groupId, String groupName, String officerName) {
        createNotification(
            creatorId,
            NotificationType.GROUP_APPROVED,
            "Watch Group Approved",
            String.format("Your watch group '%s' has been approved by %s", groupName, officerName),
            NotificationPriority.HIGH,
            "/watch-groups/" + groupId,
            "WATCH_GROUP",
            groupId
        );
    }

    @Override
    @Transactional
    public void notifyGroupRejected(UUID creatorId, UUID groupId, String groupName, String reason) {
        createNotification(
            creatorId,
            NotificationType.GROUP_REJECTED,
            "Watch Group Rejected",
            String.format("Your watch group '%s' was rejected. Reason: %s", groupName, reason),
            NotificationPriority.HIGH,
            "/watch-groups/" + groupId,
            "WATCH_GROUP",
            groupId
        );
    }

    @Override
    @Transactional
    public void notifyGroupOfficerAssigned(UUID groupId, String groupName, UUID officerId, String officerName) {
        createNotification(
            officerId,
            NotificationType.GROUP_OFFICER_ASSIGNED,
            "Assigned to Watch Group",
            String.format("You have been assigned to watch group: %s", groupName),
            NotificationPriority.HIGH,
            "/watch-groups/" + groupId,
            "WATCH_GROUP",
            groupId
        );
    }

    @Override
    @Transactional
    public void notifyGroupMemberJoined(UUID groupId, String groupName, UUID memberId, String memberName) {
        // Notify group admins about new member
        // This would need to be implemented with group member lookup
        log.info("Member {} joined group {}", memberName, groupName);
    }

    @Override
    @Transactional
    public void notifyGroupMemberLeft(UUID groupId, String groupName, UUID memberId, String memberName) {
        // Notify group admins about member leaving
        log.info("Member {} left group {}", memberName, groupName);
    }

    @Override
    @Transactional
    public void notifySystemAlert(UUID userId, String title, String message, String priority) {
        NotificationPriority priorityEnum = NotificationPriority.valueOf(priority.toUpperCase());
        createNotification(
            userId,
            NotificationType.SYSTEM_ALERT,
            title,
            message,
            priorityEnum,
            null,
            null,
            null
        );
    }

    @Override
    @Transactional
    public void notifyUserRoleChanged(UUID userId, String oldRole, String newRole) {
        createNotification(
            userId,
            NotificationType.USER_ROLE_CHANGED,
            "Role Updated",
            String.format("Your role has been changed from %s to %s", oldRole, newRole),
            NotificationPriority.HIGH,
            "/profile",
            "USER",
            userId
        );
    }

    @Override
    @Transactional
    public void notifyProfileUpdated(UUID userId, String updateType) {
        createNotification(userId, NotificationType.PROFILE_UPDATED, 
            "Profile Updated", 
            "Your profile has been updated: " + updateType, 
            NotificationPriority.NORMAL, 
            "/profile", 
            "USER", 
            userId);
    }

    // Account Management Notifications
    @Override
    public void notifyAccountCreated(UUID userId, String userName) {
        createNotification(userId, NotificationType.ACCOUNT_CREATED, 
            "Account Created", 
            "Welcome " + userName + "! Your account has been created successfully.", 
            NotificationPriority.HIGH, 
            "/profile", 
            "USER", 
            userId);
    }

    @Override
    public void notifyAccountUpdated(UUID userId, String updateType) {
        createNotification(userId, NotificationType.ACCOUNT_UPDATED, 
            "Account Updated", 
            "Your account has been updated: " + updateType, 
            NotificationPriority.NORMAL, 
            "/profile", 
            "USER", 
            userId);
    }

    @Override
    public void notifyAccountVerified(UUID userId, String userName) {
        createNotification(userId, NotificationType.ACCOUNT_VERIFIED, 
            "Account Verified", 
            "Congratulations " + userName + "! Your account has been verified.", 
            NotificationPriority.HIGH, 
            "/dashboard", 
            "USER", 
            userId);
    }

    @Override
    public void notifyAccountDeactivated(UUID userId, String userName) {
        createNotification(userId, NotificationType.ACCOUNT_DEACTIVATED, 
            "Account Deactivated", 
            "Your account has been deactivated. Contact support for assistance.", 
            NotificationPriority.URGENT, 
            "/support", 
            "USER", 
            userId);
    }

    @Override
    public void notifyPasswordChanged(UUID userId, String userName) {
        createNotification(userId, NotificationType.PASSWORD_CHANGED, 
            "Password Changed", 
            "Your password has been changed successfully. If this wasn't you, contact support immediately.", 
            NotificationPriority.HIGH, 
            "/profile", 
            "USER", 
            userId);
    }

    @Override
    public void notifyPasswordResetRequested(UUID userId, String userName) {
        createNotification(userId, NotificationType.PASSWORD_RESET_REQUESTED, 
            "Password Reset Requested", 
            "A password reset has been requested for your account. Check your email for instructions.", 
            NotificationPriority.HIGH, 
            "/auth/reset-password", 
            "USER", 
            userId);
    }

    @Override
    public void notifyPasswordResetCompleted(UUID userId, String userName) {
        createNotification(userId, NotificationType.PASSWORD_RESET_COMPLETED, 
            "Password Reset Completed", 
            "Your password has been reset successfully. You can now login with your new password.", 
            NotificationPriority.HIGH, 
            "/auth/login", 
            "USER", 
            userId);
    }

    // News and Updates
    @Override
    public void notifyNewsUpdate(UUID userId, String newsTitle, String newsContent) {
        createNotification(userId, NotificationType.NEWS_UPDATE, 
            "News Update: " + newsTitle, 
            newsContent, 
            NotificationPriority.NORMAL, 
            "/news", 
            "NEWS", 
            null);
    }

    @Override
    public void notifySystemMaintenance(UUID userId, String maintenanceDetails) {
        createNotification(userId, NotificationType.SYSTEM_MAINTENANCE, 
            "System Maintenance", 
            "Scheduled maintenance: " + maintenanceDetails, 
            NotificationPriority.HIGH, 
            "/status", 
            "SYSTEM", 
            null);
    }

    @Override
    public void notifySecurityAlert(UUID userId, String alertTitle, String alertMessage) {
        createNotification(userId, NotificationType.SECURITY_ALERT, 
            alertTitle, 
            alertMessage, 
            NotificationPriority.URGENT, 
            "/security", 
            "SYSTEM", 
            null);
    }
    
    // AI-Powered Predictive Alerts
    @Override
    public void notifyPredictiveAlert(UUID userId, String location, String crimeType, double probability, String riskLevel, List<String> recommendations) {
        NotificationPriority priority = determinePriorityFromRiskLevel(riskLevel);
        String message = String.format("Predictive Alert: %s crime predicted in %s with %.1f%% probability. Risk Level: %s. Recommendations: %s", 
            crimeType, location, probability * 100, riskLevel, String.join(", ", recommendations));
        
        createNotification(userId, NotificationType.PREDICTIVE_ALERT, 
            "Crime Prediction Alert", 
            message, 
            priority, 
            "/ai/predictions", 
            "AI_SYSTEM", 
            null);
    }
    
    @Override
    public void notifyCrimeHotspotAlert(UUID userId, String location, String description, double riskScore, List<String> suggestedActions) {
        NotificationPriority priority = determinePriorityFromRiskScore(riskScore);
        String message = String.format("Hotspot Alert: %s identified in %s. Risk Score: %.2f. Suggested Actions: %s", 
            description, location, riskScore, String.join(", ", suggestedActions));
        
        createNotification(userId, NotificationType.CRIME_HOTSPOT_ALERT, 
            "Crime Hotspot Detected", 
            message, 
            priority, 
            "/ai/patterns", 
            "AI_SYSTEM", 
            null);
    }
    
    @Override
    public void notifyRiskAssessmentAlert(UUID userId, String assessmentTitle, String riskSummary, double overallRisk, List<String> riskFactors) {
        NotificationPriority priority = determinePriorityFromRiskScore(overallRisk);
        String message = String.format("Risk Assessment: %s. Overall Risk: %.2f. Risk Factors: %s. Summary: %s", 
            assessmentTitle, overallRisk, String.join(", ", riskFactors), riskSummary);
        
        createNotification(userId, NotificationType.RISK_ASSESSMENT_ALERT, 
            "Risk Assessment Alert", 
            message, 
            priority, 
            "/ai/risk-assessment", 
            "AI_SYSTEM", 
            null);
    }
    
    @Override
    public void notifyPatternDetectionAlert(UUID userId, String patternType, String description, double confidence, List<String> insights) {
        NotificationPriority priority = confidence > 0.8 ? NotificationPriority.HIGH : NotificationPriority.NORMAL;
        String message = String.format("Pattern Detection: %s pattern identified. Confidence: %.1f%%. Description: %s. Key Insights: %s", 
            patternType, confidence * 100, description, String.join(", ", insights));
        
        createNotification(userId, NotificationType.PATTERN_DETECTION_ALERT, 
            "Crime Pattern Detected", 
            message, 
            priority, 
            "/ai/patterns", 
            "AI_SYSTEM", 
            null);
    }
    
    @Override
    public void notifyAllOfficersOfPredictiveAlert(String location, String crimeType, double probability, String riskLevel, List<String> recommendations) {
        // Get all police officers and admins
        List<User> officers = userRepository.findByRoleIn(Arrays.asList(UserRole.OFFICER, UserRole.ADMIN));
        
        for (User officer : officers) {
            if (officer.isActive()) {
                notifyPredictiveAlert(officer.getId(), location, crimeType, probability, riskLevel, recommendations);
            }
        }
        
        log.info("Sent predictive alert to {} officers for location: {}", officers.size(), location);
    }
    
    @Override
    public void notifyDistrictOfficersOfHotspot(String district, String description, double riskScore, List<String> suggestedActions) {
        // Get all police officers and admins
        List<User> officers = userRepository.findByRoleIn(Arrays.asList(UserRole.OFFICER, UserRole.ADMIN));
        
        for (User officer : officers) {
            if (officer.isActive()) {
                notifyCrimeHotspotAlert(officer.getId(), district, description, riskScore, suggestedActions);
            }
        }
        
        log.info("Sent hotspot alert to {} officers for district: {}", officers.size(), district);
    }
    
    // Anomaly Detection Alerts
    @Override
    public void notifyAllOfficersOfAnomalyDetection(String riskLevel, int anomaliesDetected, List<String> keyInsights) {
        // Get all police officers and admins
        List<User> officers = userRepository.findByRoleIn(Arrays.asList(UserRole.OFFICER, UserRole.ADMIN));
        
        for (User officer : officers) {
            if (officer.isActive()) {
                NotificationPriority priority = determinePriorityFromRiskLevel(riskLevel);
                String message = String.format("Anomaly Detection Alert: %d anomalies detected with %s risk level. Key Insights: %s", 
                    anomaliesDetected, riskLevel, String.join(", ", keyInsights));
                
                createNotification(officer.getId(), NotificationType.PATTERN_DETECTION_ALERT, 
                    "Anomaly Detection Alert", 
                    message, 
                    priority, 
                    "/ai/anomalies", 
                    "AI_SYSTEM", 
                    null);
            }
        }
        
        log.info("Sent anomaly detection alert to {} officers for {} risk level", officers.size(), riskLevel);
    }
    
    @Override
    public void notifyAnomalyDetected(UUID userId, String anomalyType, String description, double anomalyScore, String severity) {
        NotificationPriority priority = determinePriorityFromSeverity(severity);
        String message = String.format("Anomaly Detected: %s - %s. Anomaly Score: %.2f. Severity: %s", 
            anomalyType, description, anomalyScore, severity);
        
        createNotification(userId, NotificationType.PATTERN_DETECTION_ALERT, 
            "Anomaly Detected", 
            message, 
            priority, 
            "/ai/anomalies", 
            "AI_SYSTEM", 
            null);
    }
    
    @Override
    public void notifyFalseReportDetected(UUID userId, String location, String crimeType, List<String> suspiciousFactors) {
        String message = String.format("False Report Detected: Location: %s, Crime Type: %s. Suspicious Factors: %s", 
            location, crimeType, String.join(", ", suspiciousFactors));
        
        createNotification(userId, NotificationType.PATTERN_DETECTION_ALERT, 
            "False Report Detected", 
            message, 
            NotificationPriority.HIGH, 
            "/ai/anomalies", 
            "AI_SYSTEM", 
            null);
    }
    
    @Override
    public void notifySuspiciousPatternDetected(UUID userId, String patternType, String description, double confidence) {
        NotificationPriority priority = confidence > 0.8 ? NotificationPriority.HIGH : NotificationPriority.NORMAL;
        String message = String.format("Suspicious Pattern Detected: %s - %s. Confidence: %.1f%%", 
            patternType, description, confidence * 100);
        
        createNotification(userId, NotificationType.PATTERN_DETECTION_ALERT, 
            "Suspicious Pattern Detected", 
            message, 
            priority, 
            "/ai/anomalies", 
            "AI_SYSTEM", 
            null);
    }
    
    // Helper methods for determining notification priority
    private NotificationPriority determinePriorityFromRiskLevel(String riskLevel) {
        return switch (riskLevel.toUpperCase()) {
            case "CRITICAL" -> NotificationPriority.EMERGENCY;
            case "HIGH" -> NotificationPriority.URGENT;
            case "MEDIUM" -> NotificationPriority.HIGH;
            case "LOW" -> NotificationPriority.NORMAL;
            default -> NotificationPriority.NORMAL;
        };
    }
    
    private NotificationPriority determinePriorityFromRiskScore(double riskScore) {
        if (riskScore >= 0.8) return NotificationPriority.EMERGENCY;
        if (riskScore >= 0.6) return NotificationPriority.URGENT;
        if (riskScore >= 0.4) return NotificationPriority.HIGH;
        if (riskScore >= 0.2) return NotificationPriority.NORMAL;
        return NotificationPriority.LOW;
    }

    private NotificationPriority determinePriorityFromSeverity(String severity) {
        return switch (severity.toUpperCase()) {
            case "CRITICAL" -> NotificationPriority.EMERGENCY;
            case "HIGH" -> NotificationPriority.URGENT;
            case "MEDIUM" -> NotificationPriority.HIGH;
            case "LOW" -> NotificationPriority.NORMAL;
            default -> NotificationPriority.NORMAL;
        };
    }
    
    // User Activity Notifications
    @Override
    public void notifyLoginAttempt(UUID userId, String location, String deviceInfo) {
        createNotification(userId, NotificationType.LOGIN_ATTEMPT, 
            "Login Attempt", 
            "Login attempt from " + location + " using " + deviceInfo, 
            NotificationPriority.NORMAL, 
            "/security", 
            "SECURITY", 
            userId);
    }

    @Override
    public void notifyLoginSuccessful(UUID userId, String location, String deviceInfo) {
        createNotification(userId, NotificationType.LOGIN_SUCCESSFUL, 
            "Login Successful", 
            "Successful login from " + location + " using " + deviceInfo, 
            NotificationPriority.LOW, 
            "/dashboard", 
            "SECURITY", 
            userId);
    }

    @Override
    public void notifyAccountLocked(UUID userId, String reason) {
        createNotification(userId, NotificationType.ACCOUNT_LOCKED, 
            "Account Locked", 
            "Your account has been locked: " + reason, 
            NotificationPriority.URGENT, 
            "/support", 
            "SECURITY", 
            userId);
    }

    // Helper method to create notifications
    private void createNotification(UUID userId, NotificationType type, String title, String message, 
                                  NotificationPriority priority, String actionUrl, String entityType, UUID entityId) {
        try {
            User user = userRepository.findById(userId).orElse(null);
            if (user == null) {
                log.warn("Cannot create notification for non-existent user: {}", userId);
                return;
            }

            Instant now = Instant.now();
            Notification notification = Notification.builder()
                    .user(user)
                    .type(type)
                    .title(title)
                    .message(message)
                    .isRead(false)
                    .actionUrl(actionUrl)
                    .relatedEntityType(entityType)
                    .relatedEntityId(entityId)
                    .priority(priority)
                    .build();
            
            // Set createdAt and updatedAt for AbstractAuditEntity
            notification.setCreatedAt(now);
            notification.setUpdatedAt(now);

            notificationRepository.save(notification);
            log.info("Created notification for user {}: {}", userId, title);
        } catch (Exception e) {
            log.error("Error creating notification for user {}: {}", userId, e.getMessage(), e);
        }
    }

    private NotificationResponse buildNotificationResponse(Notification notification) {
        return NotificationResponse.builder()
                .id(notification.getId())
                .type(notification.getType().name())
                .title(notification.getTitle())
                .message(notification.getMessage())
                .isRead(notification.isRead())
                .readAt(notification.getReadAt())
                .actionUrl(notification.getActionUrl())
                .relatedEntityType(notification.getRelatedEntityType())
                .relatedEntityId(notification.getRelatedEntityId())
                .priority(notification.getPriority().name())
                .expiresAt(notification.getExpiresAt())
                .metadata(notification.getMetadata())
                .createdAt(notification.getCreatedAt())
                .updatedAt(notification.getUpdatedAt())
                .build();
    }
}
