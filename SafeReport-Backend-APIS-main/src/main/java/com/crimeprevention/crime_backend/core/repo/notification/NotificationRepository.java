package com.crimeprevention.crime_backend.core.repo.notification;

import com.crimeprevention.crime_backend.core.model.notification.Notification;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, UUID> {

    // Find notifications for a specific user
    Page<Notification> findByUserIdOrderByCreatedAtDesc(UUID userId, Pageable pageable);
    
    // Find unread notifications for a user
    List<Notification> findByUserIdAndIsReadFalseOrderByCreatedAtDesc(UUID userId);
    
    // Count unread notifications for a user
    long countByUserIdAndIsReadFalse(UUID userId);
    
    // Find notifications by type for a user
    Page<Notification> findByUserIdAndTypeOrderByCreatedAtDesc(UUID userId, String type, Pageable pageable);
    
    // Find notifications by priority for a user
    Page<Notification> findByUserIdAndPriorityOrderByCreatedAtDesc(UUID userId, String priority, Pageable pageable);
    
    // Mark notifications as read
    @Modifying
    @Query("UPDATE Notification n SET n.isRead = true, n.readAt = :readAt WHERE n.id IN :notificationIds")
    void markNotificationsAsRead(@Param("notificationIds") List<UUID> notificationIds, @Param("readAt") Instant readAt);
    
    // Delete expired notifications
    @Modifying
    @Query("DELETE FROM Notification n WHERE n.expiresAt IS NOT NULL AND n.expiresAt < :now")
    void deleteExpiredNotifications(@Param("now") Instant now);
    
    // Find notifications by related entity
    List<Notification> findByRelatedEntityTypeAndRelatedEntityIdOrderByCreatedAtDesc(String entityType, UUID entityId);
} 