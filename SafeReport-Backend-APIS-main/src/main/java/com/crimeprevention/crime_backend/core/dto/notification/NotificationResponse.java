package com.crimeprevention.crime_backend.core.dto.notification;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationResponse {
    private UUID id;
    private String type;
    private String title;
    private String message;
    
    @JsonProperty("isRead")
    private boolean isRead;
    
    private Instant readAt;
    private String actionUrl;
    private String relatedEntityType;
    private UUID relatedEntityId;
    private String priority;
    private Instant expiresAt;
    private String metadata;
    private Instant createdAt;
    private Instant updatedAt;
} 