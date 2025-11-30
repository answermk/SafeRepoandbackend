package com.crimeprevention.crime_backend.core.dto.analytics;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PatternAnalysisRequest {
    
    private String analysisType; // DAILY, WEEKLY, MONTHLY, CUSTOM
    
    private LocalDateTime startDate;
    
    private LocalDateTime endDate;
    
    private List<String> crimeTypes; // Optional: specific crime types to analyze
    
    private List<String> locations; // Optional: specific locations to analyze
    
    private String aiService; // gemini, openai
    
    private String analysisFocus; // TEMPORAL, SPATIAL, CRIME_TYPE, CROSS_DIMENSIONAL
    
    private Integer maxPatterns; // Maximum number of patterns to identify
    
    private Boolean includeRecommendations; // Whether to include AI-generated recommendations
    
    private String customPrompt; // Optional: custom analysis instructions
}
