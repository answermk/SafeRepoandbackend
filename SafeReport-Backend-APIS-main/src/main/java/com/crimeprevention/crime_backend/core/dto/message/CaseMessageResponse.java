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
public class CaseMessageResponse {
    private UUID id;
    private UUID senderId;
    private String senderName;
    private String senderEmail;
    private UUID reportId;
    private String reportTitle;
    private String content;
    private Instant timestamp;
    private Instant createdAt;
    private Instant updatedAt;
} 