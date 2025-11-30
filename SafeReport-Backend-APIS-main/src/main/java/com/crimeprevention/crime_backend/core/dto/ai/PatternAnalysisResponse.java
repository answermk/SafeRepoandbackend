package com.crimeprevention.crime_backend.core.dto.ai;

import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class PatternAnalysisResponse {
    
    private String analysisId;
    private LocalDateTime analyzedAt;
    private String aiServiceUsed;
    
    // Pattern results
    private List<CrimePattern> geographicPatterns;
    private List<CrimePattern> temporalPatterns;
    private List<CrimePattern> modusOperandiPatterns;
    
    // Summary statistics
    private Map<String, Integer> crimeTypeFrequency;
    private Map<String, Integer> locationFrequency;
    private Map<String, Integer> timeSlotFrequency;
    
    // Insights
    private List<String> keyInsights;
    private List<String> recommendations;
    private double confidence;
    
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Builder
    public static class CrimePattern {
        private String patternType;
        private String description;
        private int occurrenceCount;
        private double confidence;
        private List<String> examples;
        private Map<String, Object> metadata;
    }
}
