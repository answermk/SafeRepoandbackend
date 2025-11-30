package com.crimeprevention.crime_backend.core.dto.message;

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
public class WatchGroupMessageResponse {
    private UUID id;
    private UUID groupId;
    private String groupName;
    private UUID senderId;
    private String senderName;
    private String senderEmail;
    private String message;
    private Instant sentAt;
    private Instant createdAt;
    private Instant updatedAt;
} 