package com.crimeprevention.crime_backend.core.dto.report;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.UUID;

/**
 * DTO for creating or updating an officer assignment to a report.
 */
@Data
public class AssignmentRequestDTO {

    @NotNull(message = "Report ID is required")
    private UUID reportId;

    @NotNull(message = "Officer ID is required")
    private UUID officerId;
}
