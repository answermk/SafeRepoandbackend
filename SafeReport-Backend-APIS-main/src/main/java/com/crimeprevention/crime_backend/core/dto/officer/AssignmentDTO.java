package com.crimeprevention.crime_backend.core.dto.officer;

import com.crimeprevention.crime_backend.core.model.enums.AssignmentStatus;
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
public class AssignmentDTO {
    private UUID id;
    private UUID reportId;
    private OfficerDTO officer;
    private String title;
    private String description;
    private AssignmentStatus status;
    private BackupRequestDTO.LocationDTO location;
    private Instant assignedAt;
    private Instant completedAt;
    private String notes;
}
