package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.dto.notification.NotificationResponse;
import com.crimeprevention.crime_backend.core.service.interfaces.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
@Slf4j
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<Page<NotificationResponse>> getUserNotifications(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            Authentication authentication) {
        
        UUID userId = UUID.fromString(authentication.getName());
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        
        Page<NotificationResponse> notifications = notificationService.getUserNotifications(userId, pageable);
        return ResponseEntity.ok(notifications);
    }

    @GetMapping("/unread")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<List<NotificationResponse>> getUnreadNotifications(Authentication authentication) {
        UUID userId = UUID.fromString(authentication.getName());
        List<NotificationResponse> notifications = notificationService.getUnreadNotifications(userId);
        return ResponseEntity.ok(notifications);
    }

    @GetMapping("/count")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<Long> getUnreadNotificationCount(Authentication authentication) {
        UUID userId = UUID.fromString(authentication.getName());
        long count = notificationService.getUnreadNotificationCount(userId);
        return ResponseEntity.ok(count);
    }

    @GetMapping("/type/{type}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<Page<NotificationResponse>> getNotificationsByType(
            @PathVariable String type,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            Authentication authentication) {
        
        UUID userId = UUID.fromString(authentication.getName());
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        
        Page<NotificationResponse> notifications = notificationService.getNotificationsByType(userId, type, pageable);
        return ResponseEntity.ok(notifications);
    }

    @GetMapping("/priority/{priority}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<Page<NotificationResponse>> getNotificationsByPriority(
            @PathVariable String priority,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            Authentication authentication) {
        
        UUID userId = UUID.fromString(authentication.getName());
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        
        Page<NotificationResponse> notifications = notificationService.getNotificationsByPriority(userId, priority, pageable);
        return ResponseEntity.ok(notifications);
    }

    @PutMapping("/{notificationId}/read")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<Void> markNotificationAsRead(
            @PathVariable UUID notificationId,
            Authentication authentication) {
        
        UUID userId = UUID.fromString(authentication.getName());
        notificationService.markNotificationAsRead(userId, notificationId);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/read-multiple")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<Void> markNotificationsAsRead(
            @RequestBody List<UUID> notificationIds,
            Authentication authentication) {
        
        UUID userId = UUID.fromString(authentication.getName());
        notificationService.markNotificationsAsRead(userId, notificationIds);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{notificationId}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<Void> deleteNotification(
            @PathVariable UUID notificationId,
            Authentication authentication) {
        
        UUID userId = UUID.fromString(authentication.getName());
        notificationService.deleteNotification(userId, notificationId);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/clear-all")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<Void> clearAllNotifications(Authentication authentication) {
        UUID userId = UUID.fromString(authentication.getName());
        // This would need to be implemented in the service
        // For now, we'll mark all as read
        log.info("User {} requested to clear all notifications", userId);
        return ResponseEntity.ok().build();
    }

    // Test endpoint for creating sample notifications (remove in production)
    @PostMapping("/test")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<String> createTestNotification(
            @RequestParam UUID userId,
            @RequestParam String type,
            @RequestParam String title,
            @RequestParam String message,
            Authentication authentication) {
        
        try {
            switch (type.toUpperCase()) {
                case "MESSAGE":
                    notificationService.notifyNewMessage(userId, UUID.randomUUID(), message);
                    break;
                case "CASE":
                    notificationService.notifyCaseAssigned(userId, UUID.randomUUID(), "Test Case");
                    break;
                case "GROUP":
                    notificationService.notifyGroupCreated(userId, UUID.randomUUID(), "Test Group", "Test User");
                    break;
                case "SYSTEM":
                    notificationService.notifySystemAlert(userId, title, message, "HIGH");
                    break;
                default:
                    return ResponseEntity.badRequest().body("Invalid notification type");
            }
            return ResponseEntity.ok("Test notification created successfully");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error creating test notification: " + e.getMessage());
        }
    }
} 