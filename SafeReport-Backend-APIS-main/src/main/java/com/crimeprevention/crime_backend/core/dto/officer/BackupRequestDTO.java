package com.crimeprevention.crime_backend.core.dto.officer;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BackupRequestDTO {
    private UUID assignmentId;
    private String reason;
    private LocationDTO location;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class LocationDTO {
        private double latitude;
        private double longitude;
    }
}
