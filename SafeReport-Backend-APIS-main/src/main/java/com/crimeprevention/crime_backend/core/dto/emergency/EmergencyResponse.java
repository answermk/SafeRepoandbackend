package com.crimeprevention.crime_backend.core.dto.emergency;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EmergencyResponse {
    private UUID emergencyId;
    private Integer etaMinutes; // Estimated time of arrival in minutes
    private Integer etaMin; // Minimum ETA
    private Integer etaMax; // Maximum ETA
    private String status; // "DISPATCHED", "IN_PROGRESS", "ARRIVED"
    private String message;
    private UUID assignedOfficerId;
    private String assignedOfficerName;
}

