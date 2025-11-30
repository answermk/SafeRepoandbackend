package com.crimeprevention.crime_backend.core.dto.ai;

import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class RecommendationRequest {
    
    private UUID reportId;
    private List<UUID> availableOfficers;
    private String crimeType;
    private String location;
    private String priority;
    private LocalDateTime incidentTime;
    private List<String> specialRequirements;
    private boolean includeWorkloadBalance = true;
    private boolean includeProximity = true;
    private boolean includeExpertise = true;
    private int maxRecommendations = 5;
}
