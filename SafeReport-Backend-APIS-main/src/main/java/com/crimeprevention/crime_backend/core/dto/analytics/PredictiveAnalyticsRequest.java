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
public class PredictiveAnalyticsRequest {
    
    private String analysisType; // "CRIME_PREDICTION", "RISK_ASSESSMENT", "PATTERN_FORECASTING"
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private LocalDateTime predictionDate; // Date to predict for
    private String location; // Specific location for prediction
    private List<String> crimeTypes; // Crime types to analyze
    private String timeGranularity; // "hourly", "daily", "weekly", "monthly"
    private Integer predictionHorizon; // Number of time units to predict ahead
    private Double confidenceThreshold; // Minimum confidence for predictions
    private Boolean includeHistoricalData; // Whether to include historical analysis
    private Boolean includeRiskFactors; // Whether to include risk factor analysis
    private String modelType; // "time_series", "ml_regression", "ensemble"
    private Map<String, Object> customParameters; // Custom ML parameters
}
