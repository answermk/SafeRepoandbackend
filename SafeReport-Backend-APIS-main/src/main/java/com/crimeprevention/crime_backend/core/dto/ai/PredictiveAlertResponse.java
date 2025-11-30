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
public class PredictiveAlertResponse {
    
    private String alertId;
    private LocalDateTime generatedAt;
    private String aiServiceUsed;
    
    private List<Prediction> predictions;
    private List<String> riskFactors;
    private List<String> recommendations;
    private double overallRisk;
    
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Builder
    public static class Prediction {
        private String location;
        private String crimeType;
        private LocalDateTime predictedDate;
        private double probability;
        private String riskLevel; // LOW, MEDIUM, HIGH, CRITICAL
        private List<String> contributingFactors;
        private List<String> suggestedActions;
    }
}
