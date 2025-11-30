package com.crimeprevention.crime_backend.core.dto.officer;

import com.crimeprevention.crime_backend.core.model.enums.BackupStatus;
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
public class BackupResponseDTO {
    private UUID id;
    private OfficerDTO requestingOfficer;
    private BackupRequestDTO.LocationDTO location;
    private String details;
    private BackupStatus status;
    private Instant createdAt;
    private Instant respondedAt;
}
