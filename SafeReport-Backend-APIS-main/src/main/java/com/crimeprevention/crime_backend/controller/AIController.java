package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.service.interfaces.AIService;
import com.crimeprevention.crime_backend.core.dto.ai.AnomalyDetectionRequest;
import com.crimeprevention.crime_backend.core.dto.ai.AnomalyDetectionResponse;
import com.crimeprevention.crime_backend.core.dto.ai.PatternAnalysisRequest;
import com.crimeprevention.crime_backend.core.dto.ai.PatternAnalysisResponse;
import com.crimeprevention.crime_backend.core.dto.ai.PredictiveAlertRequest;
import com.crimeprevention.crime_backend.core.dto.ai.PredictiveAlertResponse;
import com.crimeprevention.crime_backend.core.dto.ai.ReportSummaryRequest;
import com.crimeprevention.crime_backend.core.dto.ai.ReportSummaryResponse;
import com.crimeprevention.crime_backend.core.dto.ai.UpdateSummaryRequest;
import com.crimeprevention.crime_backend.core.dto.ai.RecommendationRequest;
import com.crimeprevention.crime_backend.core.dto.ai.RecommendationResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/ai")
@RequiredArgsConstructor
@Slf4j
public class AIController {

    private final AIService aiService;

    /**
     * Generate AI summary for a crime report
     */
    @PostMapping("/summarize")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<ReportSummaryResponse> summarizeReport(
            @Valid @RequestBody ReportSummaryRequest request) {
        
        try {
            ReportSummaryResponse response = aiService.summarizeReport(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error generating report summary: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Generate AI summary for a crime report by ID
     */
    @PostMapping("/summarize/{reportId}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<ReportSummaryResponse> summarizeReportById(
            @PathVariable String reportId) {
        
        try {
            ReportSummaryResponse response = aiService.summarizeReportById(
                java.util.UUID.fromString(reportId));
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error generating report summary by ID: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Analyze crime patterns using AI
     */
    @PostMapping("/patterns")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<?> analyzePatterns(
            @Valid @RequestBody PatternAnalysisRequest request) {
        
        try {
            PatternAnalysisResponse response = aiService.analyzePatterns(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error analyzing patterns: {}", e.getMessage(), e);
            // Return error details instead of generic 400
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", true);
            errorResponse.put("message", e.getMessage());
            errorResponse.put("details", e.getClass().getSimpleName() + ": " + e.getMessage());
            if (e.getCause() != null) {
                errorResponse.put("cause", e.getCause().getMessage());
            }
            return ResponseEntity.badRequest().body(errorResponse);
        }
    }

    /**
     * Generate predictive alerts using AI
     */
    @PostMapping("/predictions")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<PredictiveAlertResponse> generatePredictiveAlerts(@RequestBody PredictiveAlertRequest request) {
        log.info("Predictive alert generation requested for date: {}", request.getPredictionDate());
        PredictiveAlertResponse response = aiService.generatePredictiveAlerts(request);
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/anomalies")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<AnomalyDetectionResponse> detectAnomalies(@RequestBody AnomalyDetectionRequest request) {
        log.info("Anomaly detection requested for period: {} to {}", request.getStartDate(), request.getEndDate());
        AnomalyDetectionResponse response = aiService.detectAnomalies(request);
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/status")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<Map<String, Object>> getAIStatus() {
        log.info("AI service status requested");
        Map<String, Object> status = new HashMap<>();
        status.put("available", aiService.isServiceAvailable());
        status.put("currentService", aiService.getCurrentService());
        status.put("timestamp", LocalDateTime.now());
        return ResponseEntity.ok(status);
    }
    
    @GetMapping("/test")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<Map<String, Object>> testAIService() {
        log.info("AI service test requested");
        Map<String, Object> result = new HashMap<>();
        
        try {
            // Test with a minimal anomaly detection request
            AnomalyDetectionRequest testRequest = new AnomalyDetectionRequest();
            testRequest.setStartDate(LocalDateTime.now().minusDays(1));
            testRequest.setEndDate(LocalDateTime.now());
            testRequest.setAnomalyThreshold(0.5);
            testRequest.setMaxAnomalies(5);
            
            // This will test the full AI service pipeline
            AnomalyDetectionResponse response = aiService.detectAnomalies(testRequest);
            
            result.put("success", true);
            result.put("aiServiceUsed", response.getAiServiceUsed());
            result.put("anomaliesDetected", response.getAnomaliesDetected());
            result.put("riskLevel", response.getRiskLevel());
            result.put("timestamp", LocalDateTime.now());
            
        } catch (Exception e) {
            log.error("AI service test failed: {}", e.getMessage(), e);
            result.put("success", false);
            result.put("error", e.getMessage());
            result.put("timestamp", LocalDateTime.now());
        }
        
        return ResponseEntity.ok(result);
    }

    /**
     * Generate AI recommendations for case assignments
     */
    @PostMapping("/recommendations")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<RecommendationResponse> generateRecommendations(
            @Valid @RequestBody RecommendationRequest request) {
        
        try {
            RecommendationResponse response = aiService.generateRecommendations(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error generating recommendations: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Test AI service with custom prompt
     */
    @PostMapping("/test")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> testAIService(@RequestBody Map<String, String> testRequest) {
        try {
            String prompt = testRequest.get("prompt");
            if (prompt == null || prompt.trim().isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "Prompt is required"));
            }
            
            // Test with a simple summary request
            ReportSummaryRequest request = ReportSummaryRequest.builder()
                .title("Test Report")
                .description(prompt)
                .summaryLength(ReportSummaryRequest.SummaryLength.SHORT)
                .build();
            
            ReportSummaryResponse response = aiService.summarizeReport(request);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "response", response,
                "service", aiService.getCurrentService()
            ));
        } catch (Exception e) {
            log.error("Error testing AI service: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/test-scenarios")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<Map<String, Object>> testAnomalyDetectionScenarios() {
        log.info("Testing anomaly detection scenarios requested");
        Map<String, Object> result = new HashMap<>();
        
        try {
            AnomalyDetectionResponse response = aiService.testAnomalyDetectionScenarios();
            
            result.put("success", true);
            result.put("aiServiceUsed", response.getAiServiceUsed());
            result.put("anomaliesDetected", response.getAnomaliesDetected());
            result.put("overallAnomalyScore", response.getOverallAnomalyScore());
            result.put("riskLevel", response.getRiskLevel());
            result.put("totalReportsAnalyzed", response.getTotalReportsAnalyzed());
            result.put("confidence", response.getConfidence());
            result.put("timestamp", LocalDateTime.now());
            
            // Add detailed anomaly breakdown
            Map<String, Object> anomalyBreakdown = new HashMap<>();
            anomalyBreakdown.put("falseReportAnomalies", response.getFalseReportAnomalies().size());
            anomalyBreakdown.put("suspiciousPatternAnomalies", response.getSuspiciousPatternAnomalies().size());
            anomalyBreakdown.put("timingAnomalies", response.getTimingAnomalies().size());
            anomalyBreakdown.put("geographicAnomalies", response.getGeographicAnomalies().size());
            anomalyBreakdown.put("modusOperandiAnomalies", response.getModusOperandiAnomalies().size());
            
            result.put("anomalyBreakdown", anomalyBreakdown);
            result.put("categoryScores", response.getCategoryScores());
            
        } catch (Exception e) {
            log.error("Anomaly detection scenario test failed: {}", e.getMessage(), e);
            result.put("success", false);
            result.put("error", e.getMessage());
            result.put("timestamp", LocalDateTime.now());
        }
        
        return ResponseEntity.ok(result);
    }
    
    @PostMapping("/test-gemini")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<Map<String, Object>> testGeminiService(@RequestBody Map<String, String> request) {
        log.info("Testing Gemini service directly");
        String testPrompt = request.getOrDefault("prompt", "Say 'Hello World' in JSON format: {\"message\": \"Hello World\"}");
        
        String response = aiService.testGeminiService(testPrompt);
        
        Map<String, Object> result = new HashMap<>();
        result.put("testPrompt", testPrompt);
        result.put("geminiResponse", response);
        result.put("responseLength", response.length());
        result.put("timestamp", LocalDateTime.now());
        
        return ResponseEntity.ok(result);
    }

    // ==================== CRUD OPERATIONS FOR AI SUMMARIES ====================

    /**
     * Get all AI summaries with pagination and filtering
     */
    @GetMapping("/summaries")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<Map<String, Object>> getAllSummaries(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String aiServiceName,
            @RequestParam(required = false) String urgencyLevel,
            @RequestParam(required = false) String priorityLevel,
            @RequestParam(required = false) Double minConfidence,
            @RequestParam(required = false) String tag) {
        
        try {
            // This will be implemented in the service layer
            Map<String, Object> result = aiService.getAllSummaries(page, size, aiServiceName, urgencyLevel, priorityLevel, minConfidence, tag);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            log.error("Error retrieving summaries: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * Get AI summary by ID
     */
    @GetMapping("/summaries/{summaryId}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<ReportSummaryResponse> getSummaryById(@PathVariable String summaryId) {
        try {
            ReportSummaryResponse summary = aiService.getSummaryById(UUID.fromString(summaryId));
            return ResponseEntity.ok(summary);
        } catch (Exception e) {
            log.error("Error retrieving summary by ID: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Get all summaries for a specific report
     */
    @GetMapping("/summaries/report/{reportId}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<List<ReportSummaryResponse>> getSummariesByReport(@PathVariable String reportId) {
        try {
            List<ReportSummaryResponse> summaries = aiService.getSummariesByReport(UUID.fromString(reportId));
            return ResponseEntity.ok(summaries);
        } catch (Exception e) {
            log.error("Error retrieving summaries by report: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Update AI summary
     */
    @PutMapping("/summaries/{summaryId}")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<ReportSummaryResponse> updateSummary(
            @PathVariable String summaryId,
            @Valid @RequestBody UpdateSummaryRequest request) {
        try {
            ReportSummaryResponse updatedSummary = aiService.updateSummary(UUID.fromString(summaryId), request);
            return ResponseEntity.ok(updatedSummary);
        } catch (Exception e) {
            log.error("Error updating summary: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Delete AI summary
     */
    @DeleteMapping("/summaries/{summaryId}")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<Map<String, String>> deleteSummary(@PathVariable String summaryId) {
        try {
            aiService.deleteSummary(UUID.fromString(summaryId));
            return ResponseEntity.ok(Map.of("message", "Summary deleted successfully"));
        } catch (Exception e) {
            log.error("Error deleting summary: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * Regenerate AI summary for a report
     */
    @PostMapping("/summaries/{summaryId}/regenerate")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<ReportSummaryResponse> regenerateSummary(@PathVariable String summaryId) {
        try {
            ReportSummaryResponse newSummary = aiService.regenerateSummary(UUID.fromString(summaryId));
            return ResponseEntity.ok(newSummary);
        } catch (Exception e) {
            log.error("Error regenerating summary: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Get summary statistics and analytics
     */
    @GetMapping("/summaries/stats")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<Map<String, Object>> getSummaryStats() {
        try {
            Map<String, Object> stats = aiService.getSummaryStatistics();
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            log.error("Error retrieving summary statistics: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
