package com.crimeprevention.crime_backend.core.dto.officer;

import com.crimeprevention.crime_backend.core.model.enums.DutyStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OfficerDTO {
    private UUID id;
    private String fullName;
    private String email;
    private String phoneNumber;
    private String username;
    private String badgeNumber;
    private DutyStatus dutyStatus;
    private boolean isActive;
    private LocationDTO location;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class LocationDTO {
        private Double latitude;
        private Double longitude;
    }
}