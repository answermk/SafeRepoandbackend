package com.crimeprevention.crime_backend.core.model.notification;

import com.crimeprevention.crime_backend.core.base.AbstractAuditEntity;
import com.crimeprevention.crime_backend.core.model.enums.NotificationPriority;
import com.crimeprevention.crime_backend.core.model.enums.NotificationType;
import com.crimeprevention.crime_backend.core.model.user.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "notifications",
        indexes = {
                @Index(name = "idx_notifications_user", columnList = "user_id"),
                @Index(name = "idx_notifications_type", columnList = "type"),
                @Index(name = "idx_notifications_read", columnList = "is_read"),
                @Index(name = "idx_notifications_created", columnList = "created_at")
        })
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Notification extends AbstractAuditEntity {

    @Id @GeneratedValue @Column(columnDefinition = "uuid")
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false)
    private NotificationType type;

    @Column(name = "title", nullable = false, length = 200)
    private String title;

    @Column(name = "message", columnDefinition = "TEXT", nullable = false)
    private String message;

    @Column(name = "is_read", nullable = false)
    private boolean isRead = false;

    @Column(name = "read_at")
    private Instant readAt;

    @Column(name = "action_url")
    private String actionUrl;

    @Column(name = "related_entity_type")
    private String relatedEntityType;

    @Column(name = "related_entity_id")
    private UUID relatedEntityId;

    @Column(name = "priority", nullable = false)
    @Enumerated(EnumType.STRING)
    private NotificationPriority priority = NotificationPriority.NORMAL;

    @Column(name = "expires_at")
    private Instant expiresAt;

    @Column(name = "metadata", columnDefinition = "TEXT")
    private String metadata; // JSON string for additional data
} 