package com.crimeprevention.crime_backend.core.dto.report;

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
public class AssignmentResponse {
    private UUID id;
    private UUID reportId;
    private String reportTitle;
    private UUID officerId;
    private String officerName;
    private String assignmentNotes;
    private String status;
    private String priority;
    private Instant assignedAt;
    private Instant createdAt;
    private Instant updatedAt;
} 