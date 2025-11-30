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
public class AnomalyDetectionResponse {
    
    private String analysisId;
    private LocalDateTime analyzedAt;
    private String aiServiceUsed;
    
    // Analysis summary
    private int totalReportsAnalyzed;
    private int anomaliesDetected;
    private double overallAnomalyScore;
    private String riskLevel; // LOW, MEDIUM, HIGH, CRITICAL
    
    // Anomaly categories
    private List<Anomaly> falseReportAnomalies;
    private List<Anomaly> suspiciousPatternAnomalies;
    private List<Anomaly> timingAnomalies;
    private List<Anomaly> geographicAnomalies;
    private List<Anomaly> modusOperandiAnomalies;
    
    // Key insights
    private List<String> keyInsights;
    private List<String> recommendations;
    private Map<String, Double> categoryScores;
    
    // Metadata
    private double confidence;
    private String analysisNotes;
    
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Builder
    public static class Anomaly {
        private String anomalyId;
        private String anomalyType;
        private String description;
        private double anomalyScore;
        private String severity; // LOW, MEDIUM, HIGH, CRITICAL
        private String location;
        private String crimeType;
        private LocalDateTime detectedAt;
        private List<String> contributingFactors;
        private List<String> evidence;
        private List<String> suggestedActions;
        private Map<String, Object> metadata;
    }
}
