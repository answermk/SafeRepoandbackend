package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.dto.analytics.PredictiveAnalyticsRequest;
import com.crimeprevention.crime_backend.core.dto.analytics.PredictiveAnalyticsResponse;
import com.crimeprevention.crime_backend.core.service.interfaces.PredictiveAnalyticsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.Map;

@RestController
@RequestMapping("/api/analytics/predictive")
@RequiredArgsConstructor
@Slf4j
public class PredictiveAnalyticsController {
    
    private final PredictiveAnalyticsService predictiveAnalyticsService;
    
    /**
     * Generate comprehensive predictive analytics
     */
    @PostMapping("/generate")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<PredictiveAnalyticsResponse> generatePredictiveAnalytics(@Valid @RequestBody PredictiveAnalyticsRequest request) {
        log.info("Generating comprehensive predictive analytics for request: {}", request);
        
        try {
            PredictiveAnalyticsResponse response = predictiveAnalyticsService.generatePredictiveAnalytics(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error generating predictive analytics", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Predict crime occurrences for specific time and location
     */
    @PostMapping("/predict-crimes")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<PredictiveAnalyticsResponse> predictCrimeOccurrences(@Valid @RequestBody PredictiveAnalyticsRequest request) {
        log.info("Predicting crime occurrences for request: {}", request);
        
        try {
            PredictiveAnalyticsResponse response = predictiveAnalyticsService.predictCrimeOccurrences(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error predicting crime occurrences", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Assess risk levels for specific areas
     */
    @PostMapping("/assess-risk")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<PredictiveAnalyticsResponse> assessRiskLevels(@Valid @RequestBody PredictiveAnalyticsRequest request) {
        log.info("Assessing risk levels for request: {}", request);
        
        try {
            PredictiveAnalyticsResponse response = predictiveAnalyticsService.assessRiskLevels(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error assessing risk levels", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Forecast crime patterns and trends
     */
    @PostMapping("/forecast-patterns")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<PredictiveAnalyticsResponse> forecastCrimePatterns(@Valid @RequestBody PredictiveAnalyticsRequest request) {
        log.info("Forecasting crime patterns for request: {}", request);
        
        try {
            PredictiveAnalyticsResponse response = predictiveAnalyticsService.forecastCrimePatterns(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error forecasting crime patterns", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get real-time risk assessment for current conditions
     */
    @GetMapping("/risk-assessment/realtime")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<PredictiveAnalyticsResponse> getRealTimeRiskAssessment(@RequestParam String location) {
        log.info("Generating real-time risk assessment for location: {}", location);
        
        try {
            PredictiveAnalyticsResponse response = predictiveAnalyticsService.getRealTimeRiskAssessment(location);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error generating real-time risk assessment", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Generate time-series analysis for crime trends
     */
    @GetMapping("/time-series")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<PredictiveAnalyticsResponse> generateTimeSeriesAnalysis(
            @RequestParam String location,
            @RequestParam(defaultValue = "7d") String timeRange,
            @RequestParam(defaultValue = "daily") String granularity) {
        
        log.info("Generating time series analysis: location={}, timeRange={}, granularity={}", location, timeRange, granularity);
        
        try {
            PredictiveAnalyticsResponse response = predictiveAnalyticsService.generateTimeSeriesAnalysis(location, timeRange, granularity);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error generating time series analysis", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get predictive model performance metrics
     */
    @GetMapping("/model-performance")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<PredictiveAnalyticsResponse.ModelInsights> getModelPerformance() {
        log.info("Retrieving model performance metrics");
        
        try {
            PredictiveAnalyticsResponse.ModelInsights insights = predictiveAnalyticsService.getModelPerformance();
            return ResponseEntity.ok(insights);
        } catch (Exception e) {
            log.error("Error retrieving model performance", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Retrain predictive models with new data
     */
    @PostMapping("/retrain-models")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> retrainModels() {
        log.info("Retraining predictive models");
        
        try {
            boolean success = predictiveAnalyticsService.retrainModels();
            
            Map<String, Object> response = Map.of(
                "success", success,
                "message", success ? "Models retrained successfully" : "Failed to retrain models",
                "timestamp", java.time.LocalDateTime.now()
            );
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error retraining models", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get feature importance for ML models
     */
    @GetMapping("/feature-importance")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<Map<String, Double>> getFeatureImportance() {
        log.info("Retrieving feature importance for ML models");
        
        try {
            Map<String, Double> featureImportance = predictiveAnalyticsService.getFeatureImportance();
            return ResponseEntity.ok(featureImportance);
        } catch (Exception e) {
            log.error("Error retrieving feature importance", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Quick crime prediction for common scenarios
     */
    @GetMapping("/quick-prediction")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<PredictiveAnalyticsResponse> getQuickPrediction(
            @RequestParam String location,
            @RequestParam(defaultValue = "24h") String timeRange,
            @RequestParam(defaultValue = "CRIME_PREDICTION") String analysisType) {
        
        log.info("Generating quick prediction: location={}, timeRange={}, analysisType={}", location, timeRange, analysisType);
        
        try {
            PredictiveAnalyticsRequest request = PredictiveAnalyticsRequest.builder()
                    .analysisType(analysisType)
                    .location(location)
                    .startDate(parseTimeRange(timeRange))
                    .endDate(java.time.LocalDateTime.now())
                    .predictionDate(java.time.LocalDateTime.now().plusHours(24))
                    .modelType("quick")
                    .build();
            
            PredictiveAnalyticsResponse response = predictiveAnalyticsService.generatePredictiveAnalytics(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error generating quick prediction", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get crime prediction for specific crime type
     */
    @GetMapping("/crime-type/{crimeType}/prediction")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<PredictiveAnalyticsResponse> getCrimeTypePrediction(
            @PathVariable String crimeType,
            @RequestParam String location,
            @RequestParam(defaultValue = "7d") String timeRange) {
        
        log.info("Generating crime type prediction: crimeType={}, location={}, timeRange={}", crimeType, location, timeRange);
        
        try {
            PredictiveAnalyticsRequest request = PredictiveAnalyticsRequest.builder()
                    .analysisType("CRIME_PREDICTION")
                    .location(location)
                    .startDate(parseTimeRange(timeRange))
                    .endDate(java.time.LocalDateTime.now())
                    .crimeTypes(java.util.List.of(crimeType))
                    .predictionDate(java.time.LocalDateTime.now().plusDays(7))
                    .modelType("crime_specific")
                    .build();
            
            PredictiveAnalyticsResponse response = predictiveAnalyticsService.predictCrimeOccurrences(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error generating crime type prediction", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get area-specific risk assessment
     */
    @GetMapping("/area-risk/{location}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<PredictiveAnalyticsResponse> getAreaRiskAssessment(
            @PathVariable String location,
            @RequestParam(defaultValue = "30d") String timeRange) {
        
        log.info("Generating area risk assessment: location={}, timeRange={}", location, timeRange);
        
        try {
            PredictiveAnalyticsRequest request = PredictiveAnalyticsRequest.builder()
                    .analysisType("RISK_ASSESSMENT")
                    .location(location)
                    .startDate(parseTimeRange(timeRange))
                    .endDate(java.time.LocalDateTime.now())
                    .predictionDate(java.time.LocalDateTime.now())
                    .modelType("area_specific")
                    .build();
            
            PredictiveAnalyticsResponse response = predictiveAnalyticsService.assessRiskLevels(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error generating area risk assessment", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    // Helper method to parse time range strings
    private java.time.LocalDateTime parseTimeRange(String timeRange) {
        switch (timeRange.toLowerCase()) {
            case "24h":
                return java.time.LocalDateTime.now().minusHours(24);
            case "7d":
                return java.time.LocalDateTime.now().minusDays(7);
            case "30d":
                return java.time.LocalDateTime.now().minusDays(30);
            case "90d":
                return java.time.LocalDateTime.now().minusDays(90);
            default:
                return java.time.LocalDateTime.now().minusDays(7);
        }
    }
}
