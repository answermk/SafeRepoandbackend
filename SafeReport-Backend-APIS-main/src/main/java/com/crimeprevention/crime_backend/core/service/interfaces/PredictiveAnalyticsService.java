package com.crimeprevention.crime_backend.core.service.interfaces;

import com.crimeprevention.crime_backend.core.dto.analytics.PredictiveAnalyticsRequest;
import com.crimeprevention.crime_backend.core.dto.analytics.PredictiveAnalyticsResponse;

public interface PredictiveAnalyticsService {
    
    /**
     * Generate comprehensive predictive analytics
     */
    PredictiveAnalyticsResponse generatePredictiveAnalytics(PredictiveAnalyticsRequest request);
    
    /**
     * Predict crime occurrences for specific time and location
     */
    PredictiveAnalyticsResponse predictCrimeOccurrences(PredictiveAnalyticsRequest request);
    
    /**
     * Assess risk levels for specific areas
     */
    PredictiveAnalyticsResponse assessRiskLevels(PredictiveAnalyticsRequest request);
    
    /**
     * Forecast crime patterns and trends
     */
    PredictiveAnalyticsResponse forecastCrimePatterns(PredictiveAnalyticsRequest request);
    
    /**
     * Get real-time risk assessment for current conditions
     */
    PredictiveAnalyticsResponse getRealTimeRiskAssessment(String location);
    
    /**
     * Generate time-series analysis for crime trends
     */
    PredictiveAnalyticsResponse generateTimeSeriesAnalysis(
            String location, 
            String timeRange, 
            String granularity);
    
    /**
     * Get predictive model performance metrics
     */
    PredictiveAnalyticsResponse.ModelInsights getModelPerformance();
    
    /**
     * Retrain predictive models with new data
     */
    boolean retrainModels();
    
    /**
     * Get feature importance for ML models
     */
    java.util.Map<String, Double> getFeatureImportance();
}
