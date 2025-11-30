package com.crimeprevention.crime_backend.core.dto.analytics;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PredictiveAnalyticsResponse {
    
    private String predictionId;
    private String analysisType;
    private LocalDateTime generatedAt;
    private LocalDateTime predictionDate;
    private String location;
    private String modelType;
    private Double modelAccuracy;
    private Double overallConfidence;
    private Long processingTimeMs;
    
    // Crime predictions
    private List<CrimePrediction> crimePredictions;
    
    // Risk assessments
    private List<RiskAssessment> riskAssessments;
    
    // Pattern forecasting
    private List<PatternForecast> patternForecasts;
    
    // Historical analysis
    private HistoricalAnalysis historicalAnalysis;
    
    // Risk factors
    private List<RiskFactor> riskFactors;
    
    // Model insights
    private ModelInsights modelInsights;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CrimePrediction {
        private String predictionId;
        private String crimeType;
        private LocalDateTime predictedDate;
        private Double predictedCount;
        private Double confidence;
        private String location;
        private String timeSlot;
        private Double riskScore;
        private List<String> contributingFactors;
        private Map<String, Object> metadata;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RiskAssessment {
        private String assessmentId;
        private String location;
        private String riskType; // "CRIME_RISK", "SAFETY_RISK", "SECURITY_RISK"
        private Double riskScore;
        private String riskLevel; // "LOW", "MEDIUM", "HIGH", "CRITICAL"
        private LocalDateTime assessmentDate;
        private LocalDateTime validUntil;
        private List<String> riskFactors;
        private List<String> mitigationStrategies;
        private Map<String, Object> details;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PatternForecast {
        private String forecastId;
        private String patternType;
        private String description;
        private LocalDateTime forecastDate;
        private Double probability;
        private String location;
        private List<String> affectedAreas;
        private List<String> crimeTypes;
        private Double impactScore;
        private List<String> preventiveMeasures;
        private Map<String, Object> forecastData;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class HistoricalAnalysis {
        private LocalDateTime analysisStartDate;
        private LocalDateTime analysisEndDate;
        private Long totalCrimes;
            private Map<String, Long> crimesByType;
            private Map<String, Long> crimesByLocation;
            private Map<String, Long> crimesByTime;
            private Double averageCrimeRate;
            private List<String> trends;
            private List<String> anomalies;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RiskFactor {
        private String factorId;
        private String factorName;
        private String factorType;
        private Double weight;
        private String description;
        private Double currentValue;
        private Double thresholdValue;
        private String status; // "NORMAL", "ELEVATED", "CRITICAL"
        private List<String> mitigationActions;
        private Map<String, Object> factorData;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ModelInsights {
        private String modelVersion;
        private LocalDateTime lastTrained;
        private Double trainingAccuracy;
        private Double validationAccuracy;
        private List<String> keyFeatures;
        private List<String> limitations;
        private String dataQuality;
        private List<String> recommendations;
        private Map<String, Object> technicalDetails;
    }
}
