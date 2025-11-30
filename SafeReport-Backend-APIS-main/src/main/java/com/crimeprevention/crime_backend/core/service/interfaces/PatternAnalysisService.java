package com.crimeprevention.crime_backend.core.service.interfaces;

import com.crimeprevention.crime_backend.core.dto.analytics.PatternAnalysisRequest;
import com.crimeprevention.crime_backend.core.dto.analytics.PatternAnalysisResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface PatternAnalysisService {
    
    /**
     * Analyze crime patterns using AI
     */
    PatternAnalysisResponse analyzePatterns(PatternAnalysisRequest request);
    
    /**
     * Get pattern analysis by ID
     */
    PatternAnalysisResponse getPatternAnalysisById(UUID analysisId);
    
    /**
     * Get all pattern analyses with pagination
     */
    Page<PatternAnalysisResponse> getAllPatternAnalyses(Pageable pageable);
    
    /**
     * Get patterns by type
     */
    List<PatternAnalysisResponse> getPatternsByType(String patternType);
    
    /**
     * Get patterns by risk level
     */
    List<PatternAnalysisResponse> getPatternsByRiskLevel(String riskLevel);
    
    /**
     * Get patterns within date range
     */
    List<PatternAnalysisResponse> getPatternsByDateRange(LocalDateTime startDate, LocalDateTime endDate);
    
    /**
     * Get high-risk patterns
     */
    List<PatternAnalysisResponse> getHighRiskPatterns();
    
    /**
     * Get recent patterns
     */
    List<PatternAnalysisResponse> getRecentPatterns(LocalDateTime since);
    
    /**
     * Get pattern statistics
     */
    Object getPatternStatistics();
    
    /**
     * Delete pattern analysis
     */
    void deletePatternAnalysis(UUID analysisId);
}
