package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.dto.analytics.PatternAnalysisRequest;
import com.crimeprevention.crime_backend.core.dto.analytics.PatternAnalysisResponse;
import com.crimeprevention.crime_backend.core.service.interfaces.PatternAnalysisService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/analytics/patterns")
@RequiredArgsConstructor
@Slf4j
public class PatternAnalysisController {
    
    private final PatternAnalysisService patternAnalysisService;
    
    /**
     * Analyze crime patterns using AI
     */
    @PostMapping("/analyze")
    public ResponseEntity<PatternAnalysisResponse> analyzePatterns(@RequestBody PatternAnalysisRequest request) {
        log.info("Received pattern analysis request: {}", request);
        
        try {
            PatternAnalysisResponse response = patternAnalysisService.analyzePatterns(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error during pattern analysis", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get pattern analysis by ID
     */
    @GetMapping("/{analysisId}")
    public ResponseEntity<PatternAnalysisResponse> getPatternAnalysisById(@PathVariable UUID analysisId) {
        log.info("Getting pattern analysis by ID: {}", analysisId);
        
        try {
            PatternAnalysisResponse response = patternAnalysisService.getPatternAnalysisById(analysisId);
            return ResponseEntity.ok(response);
        } catch (UnsupportedOperationException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            log.error("Error getting pattern analysis", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get all pattern analyses with pagination
     */
    @GetMapping
    public ResponseEntity<Page<PatternAnalysisResponse>> getAllPatternAnalyses(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        log.info("Getting all pattern analyses - page: {}, size: {}", page, size);
        
        try {
            Pageable pageable = PageRequest.of(page, size);
            Page<PatternAnalysisResponse> response = patternAnalysisService.getAllPatternAnalyses(pageable);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting all pattern analyses", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get patterns by type
     */
    @GetMapping("/type/{patternType}")
    public ResponseEntity<List<PatternAnalysisResponse>> getPatternsByType(@PathVariable String patternType) {
        log.info("Getting patterns by type: {}", patternType);
        
        try {
            List<PatternAnalysisResponse> response = patternAnalysisService.getPatternsByType(patternType);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting patterns by type", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get patterns by risk level
     */
    @GetMapping("/risk/{riskLevel}")
    public ResponseEntity<List<PatternAnalysisResponse>> getPatternsByRiskLevel(@PathVariable String riskLevel) {
        log.info("Getting patterns by risk level: {}", riskLevel);
        
        try {
            List<PatternAnalysisResponse> response = patternAnalysisService.getPatternsByRiskLevel(riskLevel);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting patterns by risk level", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get patterns within date range
     */
    @GetMapping("/date-range")
    public ResponseEntity<List<PatternAnalysisResponse>> getPatternsByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        
        log.info("Getting patterns by date range: {} to {}", startDate, endDate);
        
        try {
            List<PatternAnalysisResponse> response = patternAnalysisService.getPatternsByDateRange(startDate, endDate);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting patterns by date range", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get high-risk patterns
     */
    @GetMapping("/high-risk")
    public ResponseEntity<List<PatternAnalysisResponse>> getHighRiskPatterns() {
        log.info("Getting high-risk patterns");
        
        try {
            List<PatternAnalysisResponse> response = patternAnalysisService.getHighRiskPatterns();
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting high-risk patterns", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get recent patterns
     */
    @GetMapping("/recent")
    public ResponseEntity<List<PatternAnalysisResponse>> getRecentPatterns(
            @RequestParam(defaultValue = "24") int hoursAgo) {
        
        log.info("Getting recent patterns from {} hours ago", hoursAgo);
        
        try {
            LocalDateTime since = LocalDateTime.now().minusHours(hoursAgo);
            List<PatternAnalysisResponse> response = patternAnalysisService.getRecentPatterns(since);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting recent patterns", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get pattern statistics
     */
    @GetMapping("/stats")
    public ResponseEntity<Object> getPatternStatistics() {
        log.info("Getting pattern statistics");
        
        try {
            Object response = patternAnalysisService.getPatternStatistics();
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting pattern statistics", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Delete pattern analysis
     */
    @DeleteMapping("/{analysisId}")
    public ResponseEntity<Void> deletePatternAnalysis(@PathVariable UUID analysisId) {
        log.info("Deleting pattern analysis: {}", analysisId);
        
        try {
            patternAnalysisService.deletePatternAnalysis(analysisId);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.error("Error deleting pattern analysis", e);
            return ResponseEntity.internalServerError().build();
        }
    }
}
