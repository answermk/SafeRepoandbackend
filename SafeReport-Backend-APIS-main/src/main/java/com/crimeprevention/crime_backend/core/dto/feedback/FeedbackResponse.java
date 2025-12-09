package com.crimeprevention.crime_backend.core.dto.feedback;

import com.crimeprevention.crime_backend.core.model.feedback.FeedbackStatus;
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
public class FeedbackResponse {
    private UUID id;
    private String message;
    private UUID userId;
    private String userEmail;
    private String userName;
    private FeedbackStatus status;
    private String adminResponse;
    private Instant createdAt;
    private Instant updatedAt;
}

