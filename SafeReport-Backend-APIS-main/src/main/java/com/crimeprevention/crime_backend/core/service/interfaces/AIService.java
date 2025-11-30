package com.crimeprevention.crime_backend.core.service.interfaces;

import com.crimeprevention.crime_backend.core.dto.ai.ReportSummaryRequest;
import com.crimeprevention.crime_backend.core.dto.ai.ReportSummaryResponse;
import com.crimeprevention.crime_backend.core.dto.ai.PatternAnalysisRequest;
import com.crimeprevention.crime_backend.core.dto.ai.PatternAnalysisResponse;
import com.crimeprevention.crime_backend.core.dto.ai.PredictiveAlertRequest;
import com.crimeprevention.crime_backend.core.dto.ai.PredictiveAlertResponse;
import com.crimeprevention.crime_backend.core.dto.ai.AnomalyDetectionRequest;
import com.crimeprevention.crime_backend.core.dto.ai.AnomalyDetectionResponse;
import com.crimeprevention.crime_backend.core.dto.ai.RecommendationRequest;
import com.crimeprevention.crime_backend.core.dto.ai.RecommendationResponse;
import com.crimeprevention.crime_backend.core.dto.ai.UpdateSummaryRequest;

import java.util.List;
import java.util.Map;
import java.util.UUID;

public interface AIService {
    
    /**
     * Generate a concise summary of a crime report
     */
    ReportSummaryResponse summarizeReport(ReportSummaryRequest request);
    
    /**
     * Generate a concise summary of a crime report by report ID
     */
    ReportSummaryResponse summarizeReportById(UUID reportId);
    
    /**
     * Analyze patterns in crime reports
     */
    PatternAnalysisResponse analyzePatterns(PatternAnalysisRequest request);
    
    /**
     * Generate predictive alerts based on historical data
     */
    PredictiveAlertResponse generatePredictiveAlerts(PredictiveAlertRequest request);
    
    /**
     * Detect anomalies in crime reports using AI analysis
     */
    AnomalyDetectionResponse detectAnomalies(AnomalyDetectionRequest request);
    
    /**
     * Test anomaly detection with different scenarios
     */
    AnomalyDetectionResponse testAnomalyDetectionScenarios();
    
    /**
     * Test Gemini AI service directly with a simple prompt
     */
    String testGeminiService(String testPrompt);
    
    /**
     * Generate automated recommendations for case assignments
     */
    RecommendationResponse generateRecommendations(RecommendationRequest request);
    
    /**
     * Check if AI service is available
     */
    boolean isServiceAvailable();
    
    /**
     * Get the current AI service being used
     */
    String getCurrentService();
    
    // New CRUD methods for summaries
    Map<String, Object> getAllSummaries(int page, int size, String aiServiceName, String urgencyLevel, 
                                       String priorityLevel, Double minConfidence, String tag);
    ReportSummaryResponse getSummaryById(UUID summaryId);
    List<ReportSummaryResponse> getSummariesByReport(UUID reportId);
    ReportSummaryResponse updateSummary(UUID summaryId, UpdateSummaryRequest request);
    void deleteSummary(UUID summaryId);
    ReportSummaryResponse regenerateSummary(UUID summaryId);
    Map<String, Object> getSummaryStatistics();
}
