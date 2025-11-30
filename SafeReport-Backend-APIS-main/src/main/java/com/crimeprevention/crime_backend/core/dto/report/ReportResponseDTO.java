package com.crimeprevention.crime_backend.core.dto.report;

import com.crimeprevention.crime_backend.core.dto.user.UserDTO;
import com.crimeprevention.crime_backend.core.model.enums.ReportStatus;
import lombok.Builder;
import lombok.Data;

import java.time.Instant;
import java.util.UUID;

/**
 * DTO returned when fetching report information.
 */
@Data
@Builder
public class ReportResponseDTO {

    private UUID reportId;

    private String title;

    private String description;

    private String location;

    private Double latitude;

    private Double longitude;

    private boolean urgent;

    private ReportStatus status;

    private Instant createdAt;

    private Instant updatedAt;

    private UserDTO submittedBy; // Civilian basic info
}
