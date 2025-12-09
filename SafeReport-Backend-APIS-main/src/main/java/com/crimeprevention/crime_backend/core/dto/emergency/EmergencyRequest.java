package com.crimeprevention.crime_backend.core.dto.emergency;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EmergencyRequest {
    @NotNull(message = "Latitude is required")
    private Double latitude;
    
    @NotNull(message = "Longitude is required")
    private Double longitude;
    
    private String address;
    private String description;
    private String emergencyType; // "POLICE", "FIRE", "AMBULANCE", "GENERAL"
}

