package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.dto.news.NewsNotificationRequest;
import com.crimeprevention.crime_backend.core.service.interfaces.NotificationService;
import com.crimeprevention.crime_backend.core.service.interfaces.EmailService;
import com.crimeprevention.crime_backend.core.service.interfaces.SmsService;
import com.crimeprevention.crime_backend.core.repo.user.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/news")
@RequiredArgsConstructor
@Slf4j
public class NewsController {

    private final NotificationService notificationService;
    private final EmailService emailService;
    private final SmsService smsService;
    private final UserRepository userRepository;

    /**
     * Send news notification to all users
     */
    @PostMapping("/broadcast")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<String> broadcastNews(@Valid @RequestBody NewsNotificationRequest request) {
        try {
            List<UUID> allUserIds = userRepository.findAll().stream()
                    .map(user -> user.getId())
                    .toList();

            int successCount = 0;
            int totalUsers = allUserIds.size();

            for (UUID userId : allUserIds) {
                try {
                    // In-app notification
                    notificationService.notifyNewsUpdate(userId, request.getTitle(), request.getContent());
                    
                    // Get user details for email/SMS
                    var userOpt = userRepository.findById(userId);
                    if (userOpt.isPresent()) {
                        var user = userOpt.get();
                        
                        // Email notification
                        emailService.sendNewsNotification(user.getEmail(), user.getFullName(), request.getTitle(), request.getContent());
                        
                        // SMS notification if phone exists
                        if (user.getPhoneNumber() != null) {
                            smsService.sendNewsNotificationSms(user.getPhoneNumber(), user.getFullName(), request.getTitle());
                        }
                        
                        successCount++;
                    }
                } catch (Exception e) {
                    log.warn("Failed to send news notification to user {}: {}", userId, e.getMessage());
                }
            }

            String message = String.format("News notification sent to %d out of %d users", successCount, totalUsers);
            return ResponseEntity.ok(message);

        } catch (Exception e) {
            log.error("Error broadcasting news: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().body("Error broadcasting news: " + e.getMessage());
        }
    }

    /**
     * Send news notification to specific users
     */
    @PostMapping("/send")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<String> sendNewsToUsers(
            @Valid @RequestBody NewsNotificationRequest request,
            @RequestParam List<UUID> userIds) {
        try {
            int successCount = 0;
            int totalUsers = userIds.size();

            for (UUID userId : userIds) {
                try {
                    // In-app notification
                    notificationService.notifyNewsUpdate(userId, request.getTitle(), request.getContent());
                    
                    // Get user details for email/SMS
                    var userOpt = userRepository.findById(userId);
                    if (userOpt.isPresent()) {
                        var user = userOpt.get();
                        
                        // Email notification
                        emailService.sendNewsNotification(user.getEmail(), user.getFullName(), request.getTitle(), request.getContent());
                        
                        // SMS notification if phone exists
                        if (user.getPhoneNumber() != null) {
                            smsService.sendNewsNotificationSms(user.getPhoneNumber(), user.getFullName(), request.getTitle());
                        }
                        
                        successCount++;
                    }
                } catch (Exception e) {
                    log.warn("Failed to send news notification to user {}: {}", userId, e.getMessage());
                }
            }

            String message = String.format("News notification sent to %d out of %d users", successCount, totalUsers);
            return ResponseEntity.ok(message);

        } catch (Exception e) {
            log.error("Error sending news to users: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().body("Error sending news: " + e.getMessage());
        }
    }

    /**
     * Send system maintenance notification
     */
    @PostMapping("/maintenance")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<String> sendMaintenanceNotification(@Valid @RequestBody NewsNotificationRequest request) {
        try {
            List<UUID> allUserIds = userRepository.findAll().stream()
                    .map(user -> user.getId())
                    .toList();

            int successCount = 0;
            for (UUID userId : allUserIds) {
                try {
                    notificationService.notifySystemMaintenance(userId, request.getContent());
                    successCount++;
                } catch (Exception e) {
                    log.warn("Failed to send maintenance notification to user {}: {}", userId, e.getMessage());
                }
            }

            return ResponseEntity.ok("Maintenance notification sent to " + successCount + " users");

        } catch (Exception e) {
            log.error("Error sending maintenance notification: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().body("Error sending maintenance notification: " + e.getMessage());
        }
    }

    /**
     * Send security alert
     */
    @PostMapping("/security-alert")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<String> sendSecurityAlert(@Valid @RequestBody NewsNotificationRequest request) {
        try {
            List<UUID> allUserIds = userRepository.findAll().stream()
                    .map(user -> user.getId())
                    .toList();

            int successCount = 0;
            for (UUID userId : allUserIds) {
                try {
                    notificationService.notifySecurityAlert(userId, request.getTitle(), request.getContent());
                    successCount++;
                } catch (Exception e) {
                    log.warn("Failed to send security alert to user {}: {}", userId, e.getMessage());
                }
            }

            return ResponseEntity.ok("Security alert sent to " + successCount + " users");

        } catch (Exception e) {
            log.error("Error sending security alert: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().body("Error sending security alert: " + e.getMessage());
        }
    }

    /**
     * Test endpoint for testing different SMS types (remove in production)
     */
    @PostMapping("/test-sms")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<String> testSmsService(
            @RequestParam String smsType,
            @RequestParam String phoneNumber,
            @RequestParam String userName,
            @RequestParam(required = false) String additionalInfo) {
        
        try {
            switch (smsType.toUpperCase()) {
                case "PASSWORD_RESET":
                    smsService.sendPasswordResetSms(phoneNumber, "123456", userName);
                    break;
                case "WELCOME":
                    smsService.sendWelcomeSms(phoneNumber, userName);
                    break;
                case "ACCOUNT_UPDATE":
                    smsService.sendAccountUpdateSms(phoneNumber, userName, additionalInfo != null ? additionalInfo : "Profile Updated");
                    break;
                case "PASSWORD_CHANGE":
                    smsService.sendPasswordChangeSms(phoneNumber, userName);
                    break;
                case "NEWS":
                    smsService.sendNewsNotificationSms(phoneNumber, userName, "Test News Alert");
                    break;
                case "EMERGENCY":
                    smsService.sendEmergencyAlertSms(phoneNumber, userName, "Test Emergency", additionalInfo != null ? additionalInfo : "This is a test emergency alert");
                    break;
                case "CASE_UPDATE":
                    smsService.sendCaseUpdateSms(phoneNumber, userName, "Test Case", additionalInfo != null ? additionalInfo : "Case status updated");
                    break;
                default:
                    return ResponseEntity.badRequest().body("Invalid SMS type. Use: PASSWORD_RESET, WELCOME, ACCOUNT_UPDATE, PASSWORD_CHANGE, NEWS, EMERGENCY, CASE_UPDATE");
            }
            return ResponseEntity.ok("SMS test executed successfully for type: " + smsType);
        } catch (Exception e) {
            log.error("Error testing SMS service: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().body("Error testing SMS: " + e.getMessage());
        }
    }
} 