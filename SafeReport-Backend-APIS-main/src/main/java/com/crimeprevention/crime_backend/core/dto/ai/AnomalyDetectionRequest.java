package com.crimeprevention.crime_backend.core.dto.ai;

import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class AnomalyDetectionRequest {
    
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private List<String> targetLocations;
    private List<String> crimeTypes;
    private List<String> districts;
    
    // Anomaly detection parameters
    private double anomalyThreshold = 0.7; // Minimum score to flag as anomaly
    private boolean detectFalseReports = true;
    private boolean detectSuspiciousPatterns = true;
    private boolean detectUnusualTiming = true;
    private boolean detectGeographicAnomalies = true;
    private boolean detectModusOperandiAnomalies = true;
    
    // Analysis depth
    private int maxAnomalies = 20;
    private boolean includeDetailedAnalysis = true;
    private boolean includeRecommendations = true;
}
