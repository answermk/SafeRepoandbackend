package com.crimeprevention.crime_backend.core.dto.report;

import com.crimeprevention.crime_backend.core.model.enums.AssignmentStatus;
import lombok.Builder;
import lombok.Data;

import java.time.Instant;
import java.util.UUID;

/**
 * DTO for returning assignment info.
 */
@Data
@Builder
public class AssignmentResponseDTO {

    private UUID assignmentId;

    private UUID reportId;

    private UUID officerId;

    private AssignmentStatus status;

    private Instant assignedAt;

    private Instant updatedAt;
}
