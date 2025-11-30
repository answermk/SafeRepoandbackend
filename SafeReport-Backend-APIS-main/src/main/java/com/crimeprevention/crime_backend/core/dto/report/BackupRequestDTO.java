package com.crimeprevention.crime_backend.core.dto.report;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.UUID;

/**
 * DTO for creating a backup request.
 */
@Data
public class BackupRequestDTO {

    @NotNull(message = "Assignment ID is required")
    private UUID assignmentId;

    @NotBlank(message = "Reason is required")
    private String reason;
}
