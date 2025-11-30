package com.crimeprevention.crime_backend.core.dto.report;

import com.crimeprevention.crime_backend.core.model.enums.BackupStatus;
import lombok.Builder;
import lombok.Data;

import java.time.Instant;
import java.util.UUID;

/**
 * DTO for returning backup request information.
 */
@Data
@Builder
public class BackupResponseDTO {

    private UUID backupRequestId;

    private UUID assignmentId;

    private String reason;

    private BackupStatus status;

    private Instant requestedAt;

    private Instant respondedAt;

    private UUID reviewedBy; // In-charge who approved/rejected
}
