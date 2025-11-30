package com.crimeprevention.crime_backend.core.dto.analytics;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PatternAnalysisResponse {
    
    private String analysisId;
    
    private String analysisType;
    
    private LocalDateTime startDate;
    
    private LocalDateTime endDate;
    
    private List<CrimePatternResponse> patterns;
    
    private String overallSummary;
    
    private String riskAssessment;
    
    private List<String> keyRecommendations;
    
    private String aiServiceUsed;
    
    private String modelVersion;
    
    private Long processingTimeMs;
    
    private LocalDateTime generatedAt;
    
    private Double confidenceScore;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CrimePatternResponse {
        private UUID patternId;
        private String patternType;
        private String patternSummary;
        private String keyInsights;
        private String riskLevel;
        private Double confidenceScore;
        private List<String> affectedLocations;
        private List<String> affectedCrimeTypes;
        private List<String> tags;
        private String recommendations;
    }
}
