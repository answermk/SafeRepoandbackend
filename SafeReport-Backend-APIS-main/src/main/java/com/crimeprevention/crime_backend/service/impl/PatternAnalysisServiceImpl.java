package com.crimeprevention.crime_backend.service.impl;

import com.crimeprevention.crime_backend.config.AIConfig;
import com.crimeprevention.crime_backend.core.dto.analytics.PatternAnalysisRequest;
import com.crimeprevention.crime_backend.core.dto.analytics.PatternAnalysisResponse;
import com.crimeprevention.crime_backend.core.model.analytics.CrimePattern;
import com.crimeprevention.crime_backend.core.repo.analytics.CrimePatternRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.PatternAnalysisService;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import okhttp3.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class PatternAnalysisServiceImpl implements PatternAnalysisService {
    
    private final AIConfig aiConfig;
    private final CrimePatternRepository crimePatternRepository;
    private final ObjectMapper objectMapper;
    private final OkHttpClient httpClient;
    
    @Override
    public PatternAnalysisResponse analyzePatterns(PatternAnalysisRequest request) {
        long startTime = System.currentTimeMillis();
        
        try {
            log.info("Starting pattern analysis for period: {} to {}", request.getStartDate(), request.getEndDate());
            
            // Build the prompt for Gemini API
            String prompt = buildPatternAnalysisPrompt(request);
            
            // Call Gemini API
            String aiResponse = callGeminiAPI(prompt);
            
            // Parse the AI response
            PatternAnalysisResponse response = parsePatternAnalysisResponse(request, aiResponse);
            
            // Save patterns to database
            savePatternsToDatabase(request, response);
            
            long processingTime = System.currentTimeMillis() - startTime;
            response.setProcessingTimeMs(processingTime);
            response.setGeneratedAt(LocalDateTime.now());
            
            log.info("Pattern analysis completed in {}ms", processingTime);
            
            return response;
            
        } catch (Exception e) {
            log.error("Error during pattern analysis", e);
            throw new RuntimeException("Failed to analyze patterns: " + e.getMessage());
        }
    }
    
    private String buildPatternAnalysisPrompt(PatternAnalysisRequest request) {
        StringBuilder prompt = new StringBuilder();
        
        prompt.append("You are an expert crime analyst. Analyze the following crime data and provide a structured response.\n\n");
        prompt.append("ANALYSIS PARAMETERS:\n");
        prompt.append("- Analysis Period: ").append(request.getAnalysisType()).append("\n");
        prompt.append("- Date Range: ").append(request.getStartDate()).append(" to ").append(request.getEndDate()).append("\n");
        prompt.append("- Focus Area: ").append(request.getAnalysisFocus()).append("\n");
        
        if (request.getCrimeTypes() != null && !request.getCrimeTypes().isEmpty()) {
            prompt.append("- Crime Types: ").append(String.join(", ", request.getCrimeTypes())).append("\n");
        }
        
        if (request.getLocations() != null && !request.getLocations().isEmpty()) {
            prompt.append("- Locations: ").append(String.join(", ", request.getLocations())).append("\n");
        }
        
        prompt.append("\nREQUIRED RESPONSE FORMAT:\n");
        prompt.append("=== OVERALL SUMMARY ===\n");
        prompt.append("[Provide a brief overview of crime patterns found]\n\n");
        
        prompt.append("=== RISK ASSESSMENT ===\n");
        prompt.append("Overall risk level: [LOW/MEDIUM/HIGH/CRITICAL]\n\n");
        
        prompt.append("=== PATTERNS ===\n");
        prompt.append("PATTERN 1:\n");
        prompt.append("Type: [TEMPORAL/SPATIAL/CRIME_TYPE/CROSS_DIMENSIONAL/ANOMALY/TREND]\n");
        prompt.append("Summary: [Brief description of the pattern]\n");
        prompt.append("Insights: [What this pattern means]\n");
        prompt.append("Risk: [LOW/MEDIUM/HIGH/CRITICAL]\n");
        prompt.append("Locations: [Affected areas, comma-separated]\n");
        prompt.append("Crime Types: [Types involved, comma-separated]\n");
        prompt.append("Tags: [Keywords, comma-separated]\n");
        prompt.append("Recommendations: [Specific actions]\n\n");
        
        prompt.append("=== KEY RECOMMENDATIONS ===\n");
        prompt.append("• [Recommendation 1]\n");
        prompt.append("• [Recommendation 2]\n");
        prompt.append("• [Recommendation 3]\n\n");
        
        prompt.append("IMPORTANT: Always provide at least one pattern with complete information in the exact format above.\n");
        prompt.append("If you cannot identify specific patterns, create a general pattern based on the available data.\n");
        
        return prompt.toString();
    }
    
    private String callGeminiAPI(String prompt) throws IOException {
        String apiKey = aiConfig.getGemini();
        String model = aiConfig.getGeminiModel();
        
        String url = "https://generativelanguage.googleapis.com/v1beta/models/" + model + ":generateContent?key=" + apiKey;
        
        // Build the request body
        Map<String, Object> requestBody = new HashMap<>();
        Map<String, Object> content = new HashMap<>();
        content.put("parts", Arrays.asList(Map.of("text", prompt)));
        requestBody.put("contents", Arrays.asList(content));
        
        String jsonBody = objectMapper.writeValueAsString(requestBody);
        
        RequestBody body = RequestBody.create(jsonBody, MediaType.get("application/json"));
        Request request = new Request.Builder()
                .url(url)
                .post(body)
                .build();
        
        try (Response response = httpClient.newCall(request).execute()) {
            if (!response.isSuccessful()) {
                throw new IOException("Unexpected response code: " + response.code());
            }
            
            String responseBody = response.body().string();
            Map<String, Object> responseMap = objectMapper.readValue(responseBody, Map.class);
            
            // Extract the generated text from Gemini response
            List<Map<String, Object>> candidates = (List<Map<String, Object>>) responseMap.get("candidates");
            if (candidates != null && !candidates.isEmpty()) {
                Map<String, Object> candidate = candidates.get(0);
                Map<String, Object> content2 = (Map<String, Object>) candidate.get("content");
                List<Map<String, Object>> parts = (List<Map<String, Object>>) content2.get("parts");
                if (parts != null && !parts.isEmpty()) {
                    return (String) parts.get(0).get("text");
                }
            }
            
            throw new IOException("Invalid response format from Gemini API");
        }
    }
    
    private PatternAnalysisResponse parsePatternAnalysisResponse(PatternAnalysisRequest request, String aiResponse) {
        log.info("Parsing AI response for pattern analysis");
        
        String[] lines = aiResponse.split("\n");
        
        String overallSummary = "";
        String riskAssessment = "";
        List<String> keyRecommendations = new ArrayList<>();
        List<PatternAnalysisResponse.CrimePatternResponse> patterns = new ArrayList<>();
        
        boolean inPatternsSection = false;
        boolean inRecommendationsSection = false;
        PatternAnalysisResponse.CrimePatternResponse currentPattern = null;
        
        for (String line : lines) {
            line = line.trim();
            
            if (line.startsWith("=== OVERALL SUMMARY ===")) {
                continue;
            } else if (line.startsWith("=== RISK ASSESSMENT ===")) {
                continue;
            } else if (line.startsWith("=== PATTERNS ===")) {
                inPatternsSection = true;
                inRecommendationsSection = false;
                continue;
            } else if (line.startsWith("=== KEY RECOMMENDATIONS ===")) {
                inPatternsSection = false;
                inRecommendationsSection = true;
                continue;
            }
            
            if (inPatternsSection && line.startsWith("PATTERN")) {
                if (currentPattern != null) {
                    patterns.add(currentPattern);
                }
                currentPattern = new PatternAnalysisResponse.CrimePatternResponse();
                currentPattern.setPatternId(UUID.randomUUID());
                currentPattern.setConfidenceScore(0.85);
            } else if (inPatternsSection && currentPattern != null) {
                if (line.startsWith("Type:")) {
                    currentPattern.setPatternType(extractBracketValue(line));
                } else if (line.startsWith("Summary:")) {
                    currentPattern.setPatternSummary(extractBracketValue(line));
                } else if (line.startsWith("Insights:")) {
                    currentPattern.setKeyInsights(extractBracketValue(line));
                } else if (line.startsWith("Risk:")) {
                    currentPattern.setRiskLevel(extractBracketValue(line));
                } else if (line.startsWith("Locations:")) {
                    currentPattern.setAffectedLocations(extractBracketList(line));
                } else if (line.startsWith("Crime Types:")) {
                    currentPattern.setAffectedCrimeTypes(extractBracketList(line));
                } else if (line.startsWith("Tags:")) {
                    currentPattern.setTags(extractBracketList(line));
                } else if (line.startsWith("Recommendations:")) {
                    currentPattern.setRecommendations(extractBracketValue(line));
                }
            } else if (inRecommendationsSection && line.startsWith("•")) {
                keyRecommendations.add(line.replaceAll("^•\\s*", "").trim());
            } else if (!inPatternsSection && !inRecommendationsSection) {
                if (overallSummary.isEmpty() && !line.isEmpty() && !line.startsWith("===")) {
                    overallSummary = line;
                } else if (line.toLowerCase().contains("risk level:") && riskAssessment.isEmpty()) {
                    riskAssessment = extractBracketValue(line);
                }
            }
        }
        
        // Add the last pattern
        if (currentPattern != null) {
            patterns.add(currentPattern);
        }
        
        // If no patterns found or patterns are incomplete, create meaningful patterns from the data
        if (patterns.isEmpty() || patterns.stream().allMatch(p -> p.getPatternSummary().isEmpty())) {
            patterns = createPatternsFromData(request, overallSummary, keyRecommendations);
        }
        
        // Set default values for missing fields
        for (PatternAnalysisResponse.CrimePatternResponse pattern : patterns) {
            if (pattern.getPatternType() == null || pattern.getPatternType().isEmpty()) {
                pattern.setPatternType("CROSS_DIMENSIONAL");
            }
            if (pattern.getRiskLevel() == null || pattern.getRiskLevel().isEmpty()) {
                pattern.setRiskLevel(riskAssessment.isEmpty() ? "MEDIUM" : riskAssessment);
            }
            if (pattern.getAffectedLocations() == null || pattern.getAffectedLocations().isEmpty()) {
                pattern.setAffectedLocations(request.getLocations() != null ? request.getLocations() : new ArrayList<>());
            }
            if (pattern.getAffectedCrimeTypes() == null || pattern.getAffectedCrimeTypes().isEmpty()) {
                pattern.setAffectedCrimeTypes(request.getCrimeTypes() != null ? request.getCrimeTypes() : new ArrayList<>());
            }
            if (pattern.getTags() == null || pattern.getTags().isEmpty()) {
                pattern.setTags(Arrays.asList("ai-analysis", "pattern-detection"));
            }
            if (pattern.getConfidenceScore() == null) {
                pattern.setConfidenceScore(0.85);
            }
        }
        
        return PatternAnalysisResponse.builder()
                .analysisId(UUID.randomUUID().toString())
                .analysisType(request.getAnalysisType())
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .patterns(patterns)
                .overallSummary(overallSummary.isEmpty() ? "Pattern analysis completed with available data" : overallSummary)
                .riskAssessment(riskAssessment.isEmpty() ? "MEDIUM" : riskAssessment)
                .keyRecommendations(keyRecommendations.isEmpty() ? Arrays.asList("Collect more data", "Monitor trends") : keyRecommendations)
                .aiServiceUsed("gemini")
                .modelVersion(aiConfig.getGeminiModel())
                .confidenceScore(0.85)
                .build();
    }
    
    private List<PatternAnalysisResponse.CrimePatternResponse> createPatternsFromData(
            PatternAnalysisRequest request, String overallSummary, List<String> recommendations) {
        
        List<PatternAnalysisResponse.CrimePatternResponse> patterns = new ArrayList<>();
        
        // Create a primary pattern based on the analysis
        PatternAnalysisResponse.CrimePatternResponse primaryPattern = PatternAnalysisResponse.CrimePatternResponse.builder()
                .patternId(UUID.randomUUID())
                .patternType("CROSS_DIMENSIONAL")
                .patternSummary(overallSummary.isEmpty() ? "Crime pattern analysis for " + request.getAnalysisType() + " period" : overallSummary)
                .keyInsights("Analysis of crime data across multiple dimensions including time, location, and crime types")
                .riskLevel("MEDIUM")
                .confidenceScore(0.75)
                .affectedLocations(request.getLocations() != null ? request.getLocations() : new ArrayList<>())
                .affectedCrimeTypes(request.getCrimeTypes() != null ? request.getCrimeTypes() : new ArrayList<>())
                .tags(Arrays.asList("multi-dimensional", "crime-analysis", request.getAnalysisType().toLowerCase()))
                .recommendations(recommendations.isEmpty() ? "Continue monitoring and collect additional data for deeper analysis" : 
                               String.join("; ", recommendations))
                .build();
        
        patterns.add(primaryPattern);
        
        // If we have specific crime types, create additional patterns
        if (request.getCrimeTypes() != null && request.getCrimeTypes().size() > 1) {
            for (String crimeType : request.getCrimeTypes()) {
                PatternAnalysisResponse.CrimePatternResponse crimePattern = PatternAnalysisResponse.CrimePatternResponse.builder()
                        .patternId(UUID.randomUUID())
                        .patternType("CRIME_TYPE")
                        .patternSummary("Analysis of " + crimeType + " incidents")
                        .keyInsights("Focus on " + crimeType + " specific patterns and trends")
                        .riskLevel("MEDIUM")
                        .confidenceScore(0.7)
                        .affectedLocations(request.getLocations() != null ? request.getLocations() : new ArrayList<>())
                        .affectedCrimeTypes(Arrays.asList(crimeType))
                        .tags(Arrays.asList(crimeType.toLowerCase(), "crime-specific", "trend-analysis"))
                        .recommendations("Implement " + crimeType + " specific prevention strategies")
                        .build();
                
                patterns.add(crimePattern);
            }
        }
        
        return patterns;
    }
    
    private String extractBracketValue(String line) {
        if (line.contains("[") && line.contains("]")) {
            int start = line.indexOf("[") + 1;
            int end = line.indexOf("]", start);
            if (start > 0 && end > start) {
                return line.substring(start, end).trim();
            }
        }
        return "";
    }
    
    private List<String> extractBracketList(String line) {
        String value = extractBracketValue(line);
        if (!value.isEmpty()) {
            return Arrays.asList(value.split("\\s*,\\s*"));
        }
        return new ArrayList<>();
    }
    
    private void savePatternsToDatabase(PatternAnalysisRequest request, PatternAnalysisResponse response) {
        log.info("Saving {} patterns to database", response.getPatterns().size());
        
        for (PatternAnalysisResponse.CrimePatternResponse patternResponse : response.getPatterns()) {
            try {
                CrimePattern pattern = CrimePattern.builder()
                        .patternType(CrimePattern.PatternType.valueOf(patternResponse.getPatternType()))
                        .analysisPeriod(CrimePattern.AnalysisPeriod.valueOf(request.getAnalysisType()))
                        .startDate(request.getStartDate())
                        .endDate(request.getEndDate())
                        .patternSummary(patternResponse.getPatternSummary())
                        .keyInsights(patternResponse.getKeyInsights())
                        .riskLevel(CrimePattern.RiskLevel.valueOf(patternResponse.getRiskLevel()))
                        .confidenceScore(patternResponse.getConfidenceScore())
                        .affectedLocations(patternResponse.getAffectedLocations())
                        .affectedCrimeTypes(patternResponse.getAffectedCrimeTypes())
                        .tags(patternResponse.getTags())
                        .recommendations(patternResponse.getRecommendations())
                                        .aiServiceUsed("gemini")
                .modelVersion(aiConfig.getGeminiModel())
                .processingTimeMs(response.getProcessingTimeMs())
                        .build();
                
                crimePatternRepository.save(pattern);
                log.info("Saved pattern: {}", pattern.getId());
                
            } catch (Exception e) {
                log.error("Error saving pattern to database", e);
            }
        }
    }
    
    @Override
    public PatternAnalysisResponse getPatternAnalysisById(UUID analysisId) {
        // Implementation for getting pattern analysis by ID
        throw new UnsupportedOperationException("Not implemented yet");
    }
    
    @Override
    public Page<PatternAnalysisResponse> getAllPatternAnalyses(Pageable pageable) {
        // Implementation for getting all pattern analyses
        throw new UnsupportedOperationException("Not implemented yet");
    }
    
    @Override
    public List<PatternAnalysisResponse> getPatternsByType(String patternType) {
        // Implementation for getting patterns by type
        throw new UnsupportedOperationException("Not implemented yet");
    }
    
    @Override
    public List<PatternAnalysisResponse> getPatternsByRiskLevel(String riskLevel) {
        // Implementation for getting patterns by risk level
        throw new UnsupportedOperationException("Not implemented yet");
    }
    
    @Override
    public List<PatternAnalysisResponse> getPatternsByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        // Implementation for getting patterns by date range
        throw new UnsupportedOperationException("Not implemented yet");
    }
    
    @Override
    public List<PatternAnalysisResponse> getHighRiskPatterns() {
        // Implementation for getting high-risk patterns
        throw new UnsupportedOperationException("Not implemented yet");
    }
    
    @Override
    public List<PatternAnalysisResponse> getRecentPatterns(LocalDateTime since) {
        // Implementation for getting recent patterns
        throw new UnsupportedOperationException("Not implemented yet");
    }
    
    @Override
    public Object getPatternStatistics() {
        // Implementation for getting pattern statistics
        throw new UnsupportedOperationException("Not implemented yet");
    }
    
    @Override
    public void deletePatternAnalysis(UUID analysisId) {
        // Implementation for deleting pattern analysis
        throw new UnsupportedOperationException("Not implemented yet");
    }
}
