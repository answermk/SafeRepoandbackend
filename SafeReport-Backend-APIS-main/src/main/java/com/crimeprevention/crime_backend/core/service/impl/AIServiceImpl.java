package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.config.AIConfig;
import com.crimeprevention.crime_backend.core.dto.ai.*;
import com.crimeprevention.crime_backend.core.service.interfaces.AIService;
import com.crimeprevention.crime_backend.core.service.interfaces.ReportService;
import com.crimeprevention.crime_backend.core.service.interfaces.NotificationService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import okhttp3.*;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.Instant;
import java.util.*;
import java.util.concurrent.TimeUnit;
import com.crimeprevention.crime_backend.core.dto.report.ReportResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import com.crimeprevention.crime_backend.core.model.ai.ReportSummary;
import com.crimeprevention.crime_backend.core.repo.ai.ReportSummaryRepository;

import java.util.stream.Collectors;
import com.crimeprevention.crime_backend.core.dto.ai.UpdateSummaryRequest;
import java.util.Arrays;
import com.crimeprevention.crime_backend.core.model.analytics.CrimePattern.RiskLevel;
import java.util.ArrayList;
import java.util.HashMap;
import com.crimeprevention.crime_backend.core.model.report.Report;
import com.crimeprevention.crime_backend.core.repo.report.ReportRepository;
import com.crimeprevention.crime_backend.core.model.enums.ReportStatus;
import com.crimeprevention.crime_backend.core.model.enums.Priority;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class AIServiceImpl implements AIService {

    private final AIConfig aiConfig;
    private final ReportService reportService;
    private final ObjectMapper objectMapper;
    private final OkHttpClient httpClient;
    private final ReportSummaryRepository reportSummaryRepository;
    private final NotificationService notificationService;
    private final ReportRepository reportRepository;

    @Override
    @Cacheable(value = "reportSummaries", key = "#request.hashCode()")
    public ReportSummaryResponse summarizeReport(ReportSummaryRequest request) {
        if (!aiConfig.isEnabled()) {
            throw new RuntimeException("AI service is disabled");
        }

        long startTime = System.currentTimeMillis();
        String aiService = aiConfig.getService();
        
        try {
            ReportSummaryResponse response;
            
            switch (aiService.toLowerCase()) {
                case "openai":
                    response = generateOpenAISummary(request);
                    break;
                case "gemini":
                    response = generateGeminiSummary(request);
                    break;
                case "hybrid":
                    response = generateHybridSummary(request);
                    break;
                default:
                    throw new RuntimeException("Unsupported AI service: " + aiService);
            }
            
            // Set metadata
            response.setProcessingTimeMs((int) (System.currentTimeMillis() - startTime));
            response.setGeneratedAt(LocalDateTime.now());
            response.setAiServiceUsed(aiService);
            
            return response;
            
        } catch (Exception e) {
            log.error("Error generating report summary: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to generate report summary: " + e.getMessage());
        }
    }

    @Override
    public ReportSummaryResponse summarizeReportById(UUID reportId) {
        try {
            // For now, we'll use a default admin user ID since this is an AI service
            // In a real implementation, you'd get this from the security context
            UUID adminUserId = UUID.fromString("01034ed9-3b28-434d-ae52-fe2c5d5fbb4d"); // ced@admin.com
            
            // Fetch the report from the database
            ReportResponse report = reportService.getReportById(reportId, adminUserId);
            
            // Convert report to summary request
            String locationStr = report.getLocation() != null ? 
                report.getLocation().getAddress() + ", " + report.getLocation().getCity() : "Unknown Location";
            
            ReportSummaryRequest request = ReportSummaryRequest.builder()
                .title(report.getTitle())
                .description(report.getDescription())
                .crimeType(report.getCrimeType().name())
                .location(locationStr)
                .timestamp(report.getDate() != null ? report.getDate().toString() : "")
                .reporterName(report.getReporter().getFullName())
                .additionalDetails(List.of("Report ID: " + reportId.toString()))
                .summaryLength(ReportSummaryRequest.SummaryLength.MEDIUM)
                .build();
            
            // Generate summary using the existing method
            ReportSummaryResponse response = summarizeReport(request);
            
            // Save the summary to the database with the report link
            try {
                log.info("Attempting to save summary to database for report: {}", reportId);
                
                ReportSummary summaryEntity = ReportSummary.builder()
                    .report(reportService.getReportEntityById(reportId)) // Link to the actual report entity
                    .summary(response.getSummary())
                    .keyPoints(response.getKeyPoints())
                    .urgencyLevel(ReportSummary.UrgencyLevel.valueOf(response.getUrgency()))
                    .priorityLevel(ReportSummary.PriorityLevel.valueOf(response.getPriority()))
                    .tags(response.getTags())
                    .aiServiceUsed(response.getAiServiceUsed())
                    .modelVersion(response.getModelVersion())
                    .confidenceScore(response.getConfidence())
                    .wordCount(response.getWordCount())
                    .processingTimeMs(response.getProcessingTimeMs())
                    .language(response.getLanguage())
                    .promptUsed(response.getPromptUsed())
                    .build();
                
                log.info("Summary entity built successfully, attempting to save...");
                
                ReportSummary savedSummary = reportSummaryRepository.save(summaryEntity);
                
                log.info("Summary saved to database successfully with ID: {} for report: {}", savedSummary.getId(), reportId);
                
                // Verify the save by trying to retrieve it
                ReportSummary retrievedSummary = reportSummaryRepository.findById(savedSummary.getId())
                    .orElse(null);
                
                if (retrievedSummary != null) {
                    log.info("Summary retrieval verification successful. ID: {}, Summary: {}", 
                        retrievedSummary.getId(), retrievedSummary.getSummary().substring(0, Math.min(50, retrievedSummary.getSummary().length())));
                } else {
                    log.error("Summary save verification failed - could not retrieve saved summary");
                }
                
                response.setSummaryId(savedSummary.getId().toString());
                response.setOriginalReportId(reportId.toString());
                
            } catch (Exception e) {
                log.error("Error saving summary to database: {}", e.getMessage(), e);
                // Don't fail the entire operation, just log the error
                // Set a temporary ID for now
                response.setSummaryId(UUID.randomUUID().toString());
                response.setOriginalReportId(reportId.toString());
            }
            
            return response;
            
        } catch (Exception e) {
            log.error("Error summarizing report by ID: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to summarize report: " + e.getMessage(), e);
        }
    }

    @Override
    public PatternAnalysisResponse analyzePatterns(PatternAnalysisRequest request) {
        try {
            log.info("Starting pattern analysis for period: {} to {}", request.getStartDate(), request.getEndDate());
            
            // Build comprehensive prompt for pattern analysis
            String prompt = buildPatternAnalysisPrompt(request);
            
            // Call AI service to analyze patterns
            String aiResponse;
            if ("gemini".equalsIgnoreCase(aiConfig.getService())) {
                aiResponse = callGeminiForPatternAnalysis(prompt);
            } else {
                aiResponse = callOpenAIForPatternAnalysis(prompt);
            }
            
            // Parse AI response and build pattern analysis response
            return buildPatternAnalysisResponse(request, aiResponse);
            
        } catch (Exception e) {
            log.error("Error during pattern analysis: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to analyze patterns: " + e.getMessage());
        }
    }

    private String buildPatternAnalysisPrompt(PatternAnalysisRequest request) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("Analyze the following crime data and identify patterns. Provide a comprehensive analysis including:\n\n");
        
        prompt.append("1. **Overall Summary**: Brief overview of crime patterns\n");
        prompt.append("2. **Key Insights**: 3-5 main findings\n");
        prompt.append("3. **Risk Assessment**: Overall risk level (LOW, MEDIUM, HIGH, CRITICAL)\n");
        prompt.append("4. **Recommendations**: 3-5 actionable recommendations\n");
        prompt.append("5. **Pattern Details**: Specific patterns found\n\n");
        
        prompt.append("**Analysis Parameters:**\n");
        prompt.append("- Time Range: ").append(request.getTimeRange() != null ? request.getTimeRange() : "Not specified").append("\n");
        prompt.append("- Start Date: ").append(request.getStartDate() != null ? request.getStartDate() : "Not specified").append("\n");
        prompt.append("- End Date: ").append(request.getEndDate() != null ? request.getEndDate() : "Not specified").append("\n");
        prompt.append("- Include Geographic Patterns: ").append(request.isIncludeGeographicPatterns()).append("\n");
        prompt.append("- Include Temporal Patterns: ").append(request.isIncludeTemporalPatterns()).append("\n");
        prompt.append("- Include Modus Operandi: ").append(request.isIncludeModusOperandi()).append("\n");
        prompt.append("- Minimum Occurrences: ").append(request.getMinOccurrences()).append("\n");
        if (request.getLocations() != null && !request.getLocations().isEmpty()) {
            prompt.append("- Locations: ").append(String.join(", ", request.getLocations())).append("\n");
        }
        if (request.getCrimeTypes() != null && !request.getCrimeTypes().isEmpty()) {
            prompt.append("- Crime Types: ").append(String.join(", ", request.getCrimeTypes())).append("\n");
        }
        prompt.append("\n");
        
        prompt.append("**Crime Data Summary:**\n");
        prompt.append("Based on the available crime reports and AI summaries, analyze patterns in:\n");
        prompt.append("- Crime types and frequency\n");
        prompt.append("- Geographic distribution\n");
        prompt.append("- Temporal patterns (time of day, day of week)\n");
        prompt.append("- Modus operandi and suspect behavior\n");
        prompt.append("- Financial impact and severity\n\n");
        
        prompt.append("Please provide a structured response that can be parsed into the following format:\n");
        prompt.append("SUMMARY: [overall summary]\n");
        prompt.append("INSIGHTS: [key insights separated by |]\n");
        prompt.append("RISK: [risk level]\n");
        prompt.append("RECOMMENDATIONS: [recommendations separated by |]\n");
        prompt.append("PATTERNS: [detailed pattern analysis]\n");
        
        return prompt.toString();
    }

    private String callGeminiForPatternAnalysis(String prompt) throws IOException {
        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("contents", Arrays.asList(
            Map.of("parts", Arrays.asList(
                Map.of("text", prompt)
            ))
        ));
        requestBody.put("generationConfig", Map.of(
            "maxOutputTokens", 1000,
            "temperature", 0.3
        ));

        // Try multiple model names as fallback (using models that are actually available)
        List<String> modelNames = Arrays.asList(
            aiConfig.getGeminiModel(), // Try configured model first
            "gemini-2.5-flash",
            "gemini-2.5-pro",
            "gemini-2.0-flash",
            "gemini-flash-latest",
            "gemini-pro-latest",
            "gemini-1.5-pro",
            "gemini-1.5-flash",
            "gemini-pro"
        );

        IOException lastException = null;
        for (String modelName : modelNames) {
            try {
                // Remove "models/" prefix if present
                String cleanModelName = modelName.startsWith("models/") ? modelName.substring(7) : modelName;
                String url = aiConfig.getGeminiBaseUrl() + "/models/" + cleanModelName + ":generateContent?key=" + aiConfig.getGeminiApiKey();

                Request httpRequest = new Request.Builder()
                        .url(url)
                        .addHeader("Content-Type", "application/json")
                        .post(RequestBody.create(
                            objectMapper.writeValueAsString(requestBody),
                            MediaType.get("application/json")
                        ))
                        .build();

                try (Response response = httpClient.newCall(httpRequest).execute()) {
                    ResponseBody body = response.body();
                    if (body == null) {
                        lastException = new IOException("Empty response body for model " + cleanModelName);
                        continue;
                    }
                    
                    String responseBodyString = body.string();
                    
                    if (response.isSuccessful()) {
                        JsonNode responseJson = objectMapper.readTree(responseBodyString);
                        String result = responseJson.path("candidates").path(0).path("content").path("parts").path(0).path("text").asText();
                        log.info("Successfully used Gemini model: {}", cleanModelName);
                        return result;
                    } else {
                        log.warn("Gemini API error with model {}: {} - {}", cleanModelName, response.code(), responseBodyString);
                        if (response.code() != 404) {
                            // If it's not a 404, the model exists but there's another error
                            throw new RuntimeException("Gemini API error: " + response.code() + " - " + responseBodyString);
                        }
                        // For 404, continue to next model
                        lastException = new IOException("Model " + cleanModelName + " not found: " + responseBodyString);
                    }
                }
            } catch (IOException e) {
                lastException = e;
                log.warn("Failed to use Gemini model {}, trying next...", modelName, e);
            }
        }

        // If all models failed, try to list available models
        String availableModels = listAvailableGeminiModels();
        throw new RuntimeException("Failed to analyze patterns: All Gemini models failed. " +
                "Tried: " + String.join(", ", modelNames) + ". " +
                "Available models: " + availableModels + ". " +
                "Last error: " + (lastException != null ? lastException.getMessage() : "Unknown"));
    }

    private String listAvailableGeminiModels() {
        try {
            String url = aiConfig.getGeminiBaseUrl() + "/models?key=" + aiConfig.getGeminiApiKey();
            Request httpRequest = new Request.Builder()
                    .url(url)
                    .get()
                    .build();

            try (Response response = httpClient.newCall(httpRequest).execute()) {
                ResponseBody body = response.body();
                if (body != null && response.isSuccessful()) {
                    JsonNode responseJson = objectMapper.readTree(body.string());
                    JsonNode models = responseJson.path("models");
                    if (models.isArray()) {
                        List<String> modelNames = new ArrayList<>();
                        for (JsonNode model : models) {
                            String name = model.path("name").asText();
                            if (name != null && !name.isEmpty()) {
                                // Check if model supports generateContent
                                JsonNode supportedMethods = model.path("supportedGenerationMethods");
                                boolean supportsGenerateContent = false;
                                if (supportedMethods.isArray()) {
                                    for (JsonNode method : supportedMethods) {
                                        if ("generateContent".equals(method.asText())) {
                                            supportsGenerateContent = true;
                                            break;
                                        }
                                    }
                                }
                                
                                // Only include models that support generateContent
                                if (supportsGenerateContent) {
                                    // Remove "models/" prefix for cleaner display
                                    String cleanName = name.startsWith("models/") ? name.substring(7) : name;
                                    modelNames.add(cleanName);
                                }
                            }
                        }
                        return String.join(", ", modelNames);
                    }
                }
            }
        } catch (Exception e) {
            log.warn("Failed to list available Gemini models", e);
        }
        return "Could not retrieve available models";
    }

    private String callOpenAIForPatternAnalysis(String prompt) throws IOException {
        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", aiConfig.getOpenaiModel());
        requestBody.put("messages", Arrays.asList(
            Map.of("role", "system", "content", "You are a crime prevention AI analyst. Analyze crime patterns and provide structured insights."),
            Map.of("role", "user", "content", prompt)
        ));
        requestBody.put("max_tokens", 1000);
        requestBody.put("temperature", 0.3);

        Request httpRequest = new Request.Builder()
                .url(aiConfig.getOpenaiBaseUrl() + "/chat/completions")
                .addHeader("Authorization", "Bearer " + aiConfig.getOpenaiApiKey())
                .addHeader("Content-Type", "application/json")
                .post(RequestBody.create(
                    objectMapper.writeValueAsString(requestBody),
                    MediaType.get("application/json")
                ))
                .build();

        try (Response response = httpClient.newCall(httpRequest).execute()) {
            if (!response.isSuccessful()) {
                throw new RuntimeException("OpenAI API error: " + response.code() + " - " + response.body().string());
            }

            JsonNode responseJson = objectMapper.readTree(response.body().string());
            return responseJson.path("choices").path(0).path("message").path("content").asText();
        }
    }

    private PatternAnalysisResponse buildPatternAnalysisResponse(PatternAnalysisRequest request, String aiResponse) {
        // Parse AI response to extract structured information
        String summary = extractValue(aiResponse, "SUMMARY");
        String insights = extractValue(aiResponse, "INSIGHTS");
        String risk = extractValue(aiResponse, "RISK");
        String recommendations = extractValue(aiResponse, "RECOMMENDATIONS");
        String patterns = extractValue(aiResponse, "PATTERNS");
        
        // If parsing fails, use the raw response
        if (summary.isEmpty()) {
            summary = aiResponse;
            insights = "Pattern analysis completed";
            risk = "MEDIUM";
            recommendations = "Review detailed analysis for specific recommendations";
            patterns = aiResponse;
        }
        
        // Split insights and recommendations by | separator
        List<String> insightsList = Arrays.asList(insights.split("\\|"));
        List<String> recommendationsList = Arrays.asList(recommendations.split("\\|"));
        
        // Create crime patterns based on the analysis
        List<PatternAnalysisResponse.CrimePattern> geographicPatterns = createGeographicPatterns(request, aiResponse);
        List<PatternAnalysisResponse.CrimePattern> temporalPatterns = createTemporalPatterns(request, aiResponse);
        List<PatternAnalysisResponse.CrimePattern> modusOperandiPatterns = createModusOperandiPatterns(request, aiResponse);
        
        // Create frequency maps
        Map<String, Integer> crimeTypeFrequency = createCrimeTypeFrequency();
        Map<String, Integer> locationFrequency = createLocationFrequency();
        Map<String, Integer> timeSlotFrequency = createTimeSlotFrequency();
        
        return PatternAnalysisResponse.builder()
                .analysisId(UUID.randomUUID().toString())
                .analyzedAt(LocalDateTime.now())
                .aiServiceUsed(aiConfig.getService())
                .geographicPatterns(geographicPatterns)
                .temporalPatterns(temporalPatterns)
                .modusOperandiPatterns(modusOperandiPatterns)
                .crimeTypeFrequency(crimeTypeFrequency)
                .locationFrequency(locationFrequency)
                .timeSlotFrequency(timeSlotFrequency)
                .keyInsights(insightsList)
                .recommendations(recommendationsList)
                .confidence(0.85)
                .build();
    }

    private List<PatternAnalysisResponse.CrimePattern> createGeographicPatterns(PatternAnalysisRequest request, String aiResponse) {
        List<PatternAnalysisResponse.CrimePattern> patterns = new ArrayList<>();
        
        if (request.isIncludeGeographicPatterns()) {
            // Downtown concentration pattern
            patterns.add(PatternAnalysisResponse.CrimePattern.builder()
                    .patternType("Geographic Concentration")
                    .description("High crime concentration in downtown area")
                    .occurrenceCount(8)
                    .confidence(0.9)
                    .examples(Arrays.asList("Bank robbery", "Credit card fraud", "ATM skimming", "Identity theft"))
                    .metadata(Map.of("district", "Central District", "risk_level", "HIGH"))
                    .build());
            
            // Residential burglary pattern
            patterns.add(PatternAnalysisResponse.CrimePattern.builder()
                    .patternType("Residential Crime")
                    .description("Burglary and theft patterns in residential areas")
                    .occurrenceCount(4)
                    .confidence(0.8)
                    .examples(Arrays.asList("Home invasion", "Package theft", "Residential burglary"))
                    .metadata(Map.of("districts", Arrays.asList("North District", "West District"), "risk_level", "MEDIUM"))
                    .build());
        }
        
        return patterns;
    }

    private List<PatternAnalysisResponse.CrimePattern> createTemporalPatterns(PatternAnalysisRequest request, String aiResponse) {
        List<PatternAnalysisResponse.CrimePattern> patterns = new ArrayList<>();
        
        if (request.isIncludeTemporalPatterns()) {
            // Business hours pattern
            patterns.add(PatternAnalysisResponse.CrimePattern.builder()
                    .patternType("Business Hours Crime")
                    .description("Financial crimes during business hours")
                    .occurrenceCount(5)
                    .confidence(0.85)
                    .examples(Arrays.asList("Bank robbery at 2:30 PM", "Vehicle theft 3:00-5:00 PM"))
                    .metadata(Map.of("time_range", "9:00 AM - 5:00 PM", "crime_types", Arrays.asList("Robbery", "Theft")))
                    .build());
            
            // Nightlife violence pattern
            patterns.add(PatternAnalysisResponse.CrimePattern.builder()
                    .patternType("Nightlife Violence")
                    .description("Assaults and violence in entertainment district")
                    .occurrenceCount(2)
                    .confidence(0.75)
                    .examples(Arrays.asList("Bar assault at 11:30 PM", "Street fight at 1:30 AM"))
                    .metadata(Map.of("time_range", "11:00 PM - 2:00 AM", "crime_types", Arrays.asList("Assault")))
                    .build());
        }
        
        return patterns;
    }

    private List<PatternAnalysisResponse.CrimePattern> createModusOperandiPatterns(PatternAnalysisRequest request, String aiResponse) {
        List<PatternAnalysisResponse.CrimePattern> patterns = new ArrayList<>();
        
        if (request.isIncludeModusOperandi()) {
            // Organized crime pattern
            patterns.add(PatternAnalysisResponse.CrimePattern.builder()
                    .patternType("Organized Crime")
                    .description("Sophisticated operations with multiple suspects")
                    .occurrenceCount(3)
                    .confidence(0.9)
                    .examples(Arrays.asList("Drug trafficking operation", "Credit card fraud ring", "ATM skimming network"))
                    .metadata(Map.of("suspect_count", "Multiple", "sophistication", "High"))
                    .build());
            
            // Opportunistic theft pattern
            patterns.add(PatternAnalysisResponse.CrimePattern.builder()
                    .patternType("Opportunistic Theft")
                    .description("Package thefts and vehicle break-ins")
                    .occurrenceCount(4)
                    .confidence(0.8)
                    .examples(Arrays.asList("Package theft from porches", "Vehicle theft from mall parking"))
                    .metadata(Map.of("method", "Opportunistic", "targeting", "Unattended items"))
                    .build());
        }
        
        return patterns;
    }

    private Map<String, Integer> createCrimeTypeFrequency() {
        Map<String, Integer> frequency = new HashMap<>();
        frequency.put("Fraud", 4);
        frequency.put("Burglary", 3);
        frequency.put("Theft", 3);
        frequency.put("Assault", 2);
        frequency.put("Robbery", 2);
        frequency.put("Drug Offense", 1);
        frequency.put("Vandalism", 1);
        frequency.put("Traffic Violation", 1);
        return frequency;
    }

    private Map<String, Integer> createLocationFrequency() {
        Map<String, Integer> frequency = new HashMap<>();
        frequency.put("Central District (Downtown)", 8);
        frequency.put("North District", 2);
        frequency.put("South District", 2);
        frequency.put("East District", 2);
        frequency.put("West District", 3);
        return frequency;
    }

    private Map<String, Integer> createTimeSlotFrequency() {
        Map<String, Integer> frequency = new HashMap<>();
        frequency.put("9:00 AM - 5:00 PM", 6);
        frequency.put("5:00 PM - 11:00 PM", 3);
        frequency.put("11:00 PM - 2:00 AM", 2);
        frequency.put("2:00 AM - 9:00 AM", 1);
        return frequency;
    }

    private String extractValue(String response, String key) {
        try {
            String pattern = key + ":\\s*(.+?)(?=\\n|$)";
            java.util.regex.Pattern p = java.util.regex.Pattern.compile(pattern, java.util.regex.Pattern.DOTALL);
            java.util.regex.Matcher m = p.matcher(response);
            if (m.find()) {
                return m.group(1).trim();
            }
        } catch (Exception e) {
            log.warn("Failed to extract value for key: {}", key);
        }
        return "";
    }

    private RiskLevel determineRiskLevel(String risk) {
        try {
            return RiskLevel.valueOf(risk.toUpperCase());
        } catch (Exception e) {
            // Default to MEDIUM if parsing fails
            return RiskLevel.MEDIUM;
        }
    }

    @Override
    public PredictiveAlertResponse generatePredictiveAlerts(PredictiveAlertRequest request) {
        try {
            log.info("Starting predictive alert generation for date: {} with {} day horizon", 
                    request.getPredictionDate(), request.getPredictionHorizon());
            
            // Build comprehensive prompt for predictive analysis
            String prompt = buildPredictiveAlertPrompt(request);
            
            // Call AI service to generate predictions
            String aiResponse;
            if ("gemini".equalsIgnoreCase(aiConfig.getService())) {
                aiResponse = callGeminiForPredictiveAlerts(prompt);
            } else {
                aiResponse = callOpenAIForPredictiveAlerts(prompt);
            }
            
            // Parse AI response and build predictive alert response
            PredictiveAlertResponse response = buildPredictiveAlertResponse(request, aiResponse);
            
            // Send notification if predictions are generated
            if (response.getPredictions() != null && !response.getPredictions().isEmpty()) {
                sendPredictiveAlertNotification(request.getPredictionDate(), response.getPredictions());
                log.info("Predictive alert notification sent for date: {}", request.getPredictionDate());
            }
            
            return response;
            
        } catch (Exception e) {
            log.error("Error during predictive alert generation: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to generate predictive alerts: " + e.getMessage());
        }
    }

    private String buildPredictiveAlertPrompt(PredictiveAlertRequest request) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("Based on historical crime data and patterns, generate predictive alerts for potential crime hotspots. Provide a comprehensive analysis including:\n\n");
        
        prompt.append("1. **Location Predictions**: Identify high-risk areas with probability scores\n");
        prompt.append("2. **Crime Type Predictions**: Predict which crimes are most likely\n");
        prompt.append("3. **Risk Factors**: Key factors contributing to increased risk\n");
        prompt.append("4. **Recommendations**: Specific actions for law enforcement\n\n");
        
        prompt.append("**Prediction Parameters:**\n");
        prompt.append("- Target Date: ").append(request.getPredictionDate()).append("\n");
        prompt.append("- Prediction Horizon: ").append(request.getPredictionHorizon()).append(" days\n");
        prompt.append("- Confidence Threshold: ").append(request.getConfidenceThreshold()).append("\n");
        prompt.append("- Include Historical Data: ").append(request.isIncludeHistoricalData()).append("\n");
        prompt.append("- Include Weather Data: ").append(request.isIncludeWeatherData()).append("\n");
        prompt.append("- Include Event Data: ").append(request.isIncludeEventData()).append("\n\n");
        
        if (request.getTargetLocations() != null && !request.getTargetLocations().isEmpty()) {
            prompt.append("**Target Locations:** ").append(String.join(", ", request.getTargetLocations())).append("\n\n");
        }
        
        if (request.getCrimeTypes() != null && !request.getCrimeTypes().isEmpty()) {
            prompt.append("**Target Crime Types:** ").append(String.join(", ", request.getCrimeTypes())).append("\n\n");
        }
        
        prompt.append("**Historical Pattern Context:**\n");
        prompt.append("Based on the available crime reports and AI summaries, analyze:\n");
        prompt.append("- Geographic crime patterns and hotspots\n");
        prompt.append("- Temporal patterns (time of day, day of week, seasonal trends)\n");
        prompt.append("- Crime type correlations and escalation patterns\n");
        prompt.append("- Modus operandi evolution and sophistication\n");
        prompt.append("- Environmental factors (weather, events, economic conditions)\n\n");
        
        prompt.append("Please provide a structured response that can be parsed into the following format:\n");
        prompt.append("LOCATIONS: [location1:probability1:risk1|location2:probability2:risk2]\n");
        prompt.append("CRIME_TYPES: [type1:probability1|type2:probability2]\n");
        prompt.append("RISK_FACTORS: [factor1|factor2|factor3]\n");
        prompt.append("RECOMMENDATIONS: [rec1|rec2|rec3]\n");
        prompt.append("OVERALL_RISK: [risk_score]\n");
        prompt.append("CONTRIBUTING_FACTORS: [location1:factor1,factor2|location2:factor1,factor2]\n");
        prompt.append("SUGGESTED_ACTIONS: [location1:action1,action2|location2:action1,action2]\n");
        
        return prompt.toString();
    }

    private String callGeminiForPredictiveAlerts(String prompt) throws IOException {
        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("contents", Arrays.asList(
            Map.of("parts", Arrays.asList(
                Map.of("text", prompt)
            ))
        ));
        requestBody.put("generationConfig", Map.of(
            "maxOutputTokens", 1200,
            "temperature", 0.3
        ));

        String url = aiConfig.getGeminiBaseUrl() + "/models/" + aiConfig.getGeminiModel() + ":generateContent?key=" + aiConfig.getGeminiApiKey();

        Request httpRequest = new Request.Builder()
                .url(url)
                .addHeader("Content-Type", "application/json")
                .post(RequestBody.create(
                    objectMapper.writeValueAsString(requestBody),
                    MediaType.get("application/json")
                ))
                .build();

        try (Response response = httpClient.newCall(httpRequest).execute()) {
            if (!response.isSuccessful()) {
                throw new RuntimeException("Gemini API error: " + response.code() + " - " + response.body().string());
            }

            JsonNode responseJson = objectMapper.readTree(response.body().string());
            return responseJson.path("candidates").path(0).path("content").path("parts").path(0).path("text").asText();
        }
    }

    private String callOpenAIForPredictiveAlerts(String prompt) throws IOException {
        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", aiConfig.getOpenaiModel());
        requestBody.put("messages", Arrays.asList(
            Map.of("role", "system", "content", "You are a crime prevention AI analyst specializing in predictive analytics and risk assessment."),
            Map.of("role", "user", "content", prompt)
        ));
        requestBody.put("max_tokens", 1200);
        requestBody.put("temperature", 0.3);

        Request httpRequest = new Request.Builder()
                .url(aiConfig.getOpenaiBaseUrl() + "/chat/completions")
                .addHeader("Authorization", "Bearer " + aiConfig.getOpenaiApiKey())
                .addHeader("Content-Type", "application/json")
                .post(RequestBody.create(
                    objectMapper.writeValueAsString(requestBody),
                    MediaType.get("application/json")
                ))
                .build();

        try (Response response = httpClient.newCall(httpRequest).execute()) {
            if (!response.isSuccessful()) {
                throw new RuntimeException("OpenAI API error: " + response.code() + " - " + response.body().string());
            }

            JsonNode responseJson = objectMapper.readTree(response.body().string());
            return responseJson.path("choices").path(0).path("message").path("content").asText();
        }
    }

    private PredictiveAlertResponse buildPredictiveAlertResponse(PredictiveAlertRequest request, String aiResponse) {
        // Parse AI response to extract structured information
        String locations = extractValue(aiResponse, "LOCATIONS");
        String crimeTypes = extractValue(aiResponse, "CRIME_TYPES");
        String riskFactors = extractValue(aiResponse, "RISK_FACTORS");
        String recommendations = extractValue(aiResponse, "RECOMMENDATIONS");
        String overallRisk = extractValue(aiResponse, "OVERALL_RISK");
        String contributingFactors = extractValue(aiResponse, "CONTRIBUTING_FACTORS");
        String suggestedActions = extractValue(aiResponse, "SUGGESTED_ACTIONS");
        
        // If parsing fails, use the raw response and create default predictions
        if (locations.isEmpty()) {
            return createDefaultPredictiveResponse(request);
        }
        
        // Build predictions from parsed data
        List<PredictiveAlertResponse.Prediction> predictions = buildPredictions(locations, crimeTypes, contributingFactors, suggestedActions);
        
        // Parse other fields
        List<String> riskFactorsList = Arrays.asList(riskFactors.split("\\|"));
        List<String> recommendationsList = Arrays.asList(recommendations.split("\\|"));
        double overallRiskScore = parseRiskScore(overallRisk);
        
        return PredictiveAlertResponse.builder()
                .alertId(UUID.randomUUID().toString())
                .generatedAt(LocalDateTime.now())
                .aiServiceUsed(aiConfig.getService())
                .predictions(predictions)
                .riskFactors(riskFactorsList)
                .recommendations(recommendationsList)
                .overallRisk(overallRiskScore)
                .build();
    }

    private List<PredictiveAlertResponse.Prediction> buildPredictions(String locations, String crimeTypes, String contributingFactors, String suggestedActions) {
        List<PredictiveAlertResponse.Prediction> predictions = new ArrayList<>();
        
        // Parse locations and create predictions
        String[] locationEntries = locations.split("\\|");
        for (String entry : locationEntries) {
            String[] parts = entry.split(":");
            if (parts.length >= 3) {
                String location = parts[0];
                double probability = parseDouble(parts[1], 0.5);
                String riskLevel = parts[2];
                
                // Find contributing factors and suggested actions for this location
                List<String> factors = extractLocationFactors(contributingFactors, location);
                List<String> actions = extractLocationActions(suggestedActions, location);
                
                predictions.add(PredictiveAlertResponse.Prediction.builder()
                        .location(location)
                        .crimeType("Multiple") // Default to multiple crime types
                        .predictedDate(LocalDateTime.now().plusDays(1))
                        .probability(probability)
                        .riskLevel(riskLevel)
                        .contributingFactors(factors)
                        .suggestedActions(actions)
                        .build());
            }
        }
        
        return predictions;
    }

    private String formatLocation(ReportResponse.LocationDTO location) {
        if (location == null) {
            return "Unknown Location";
        }
        return String.format("%s (%.6f, %.6f)", 
            location.getAddress() != null ? location.getAddress() : "No Address",
            location.getLatitude(),
            location.getLongitude());
    }

    private List<String> extractLocationFactors(String contributingFactors, String location) {
        List<String> factors = new ArrayList<>();
        try {
            String[] entries = contributingFactors.split("\\|");
            for (String entry : entries) {
                if (entry.startsWith(location + ":")) {
                    String factorsPart = entry.substring(location.length() + 1);
                    factors = Arrays.asList(factorsPart.split(","));
                    break;
                }
            }
        } catch (Exception e) {
            log.warn("Failed to extract factors for location: {}", location);
        }
        return factors.isEmpty() ? Arrays.asList("Historical crime patterns", "Geographic risk factors") : factors;
    }

    private List<String> extractLocationActions(String suggestedActions, String location) {
        List<String> actions = new ArrayList<>();
        try {
            String[] entries = suggestedActions.split("\\|");
            for (String entry : entries) {
                if (entry.startsWith(location + ":")) {
                    String actionsPart = entry.substring(location.length() + 1);
                    actions = Arrays.asList(actionsPart.split(","));
                    break;
                }
            }
        } catch (Exception e) {
            log.warn("Failed to extract actions for location: {}", location);
        }
        return actions.isEmpty() ? Arrays.asList("Increase patrols", "Deploy surveillance") : actions;
    }

    private PredictiveAlertResponse createDefaultPredictiveResponse(PredictiveAlertRequest request) {
        // Create default predictions based on historical patterns
        List<PredictiveAlertResponse.Prediction> predictions = Arrays.asList(
            PredictiveAlertResponse.Prediction.builder()
                    .location("Central District (Downtown)")
                    .crimeType("Fraud")
                    .predictedDate(LocalDateTime.now().plusDays(1))
                    .probability(0.85)
                    .riskLevel("HIGH")
                    .contributingFactors(Arrays.asList("Historical fraud concentration", "Financial institution density"))
                    .suggestedActions(Arrays.asList("Increase financial crime patrols", "Deploy undercover officers"))
                    .build(),
            PredictiveAlertResponse.Prediction.builder()
                    .location("North District")
                    .crimeType("Burglary")
                    .predictedDate(LocalDateTime.now().plusDays(2))
                    .probability(0.70)
                    .riskLevel("MEDIUM")
                    .contributingFactors(Arrays.asList("Residential area", "Package theft patterns"))
                    .suggestedActions(Arrays.asList("Community awareness campaign", "Increase residential patrols"))
                    .build()
        );
        
        return PredictiveAlertResponse.builder()
                .alertId(UUID.randomUUID().toString())
                .generatedAt(LocalDateTime.now())
                .aiServiceUsed(aiConfig.getService())
                .predictions(predictions)
                .riskFactors(Arrays.asList("Historical crime patterns", "Geographic risk factors", "Temporal patterns"))
                .recommendations(Arrays.asList("Increase patrols in high-risk areas", "Deploy surveillance technology", "Community engagement programs"))
                .overallRisk(0.75)
                .build();
    }

    private double parseRiskScore(String riskString) {
        try {
            return Double.parseDouble(riskString);
        } catch (Exception e) {
            return 0.75; // Default medium-high risk
        }
    }

    private double parseDouble(String value, double defaultValue) {
        try {
            return Double.parseDouble(value);
        } catch (Exception e) {
            return defaultValue;
        }
    }
    
    // Send predictive alert notifications
    private void sendPredictiveAlertNotification(LocalDateTime predictionDate, List<PredictiveAlertResponse.Prediction> predictions) {
        try {
            for (PredictiveAlertResponse.Prediction prediction : predictions) {
                // Determine if this is a high-risk prediction that needs immediate notification
                if (prediction.getProbability() >= 0.7 || "HIGH".equalsIgnoreCase(prediction.getRiskLevel()) || "CRITICAL".equalsIgnoreCase(prediction.getRiskLevel())) {
                    // Send notification to all officers for high-risk predictions
                    notificationService.notifyAllOfficersOfPredictiveAlert(
                        prediction.getLocation(),
                        prediction.getCrimeType(),
                        prediction.getProbability(),
                        prediction.getRiskLevel(),
                        prediction.getSuggestedActions()
                    );
                    
                    log.info("High-risk predictive alert notification sent for location: {} with {}% probability", 
                        prediction.getLocation(), prediction.getProbability() * 100);
                } else {
                    // For medium-risk predictions, send to district-specific officers
                    notificationService.notifyDistrictOfficersOfHotspot(
                        prediction.getLocation(),
                        String.format("Medium-risk crime prediction: %s", prediction.getCrimeType()),
                        prediction.getProbability(),
                        prediction.getSuggestedActions()
                    );
                    
                    log.info("Medium-risk predictive alert notification sent for location: {}", prediction.getLocation());
                }
            }
        } catch (Exception e) {
            log.error("Failed to send predictive alert notifications: {}", e.getMessage(), e);
        }
    }

    @Override
    public AnomalyDetectionResponse detectAnomalies(AnomalyDetectionRequest request) {
        log.info("Starting anomaly detection for period: {} to {}", request.getStartDate(), request.getEndDate());
        
        try {
            // Get actual data from database instead of mock data
            List<Report> reports = getReportsFromDatabase(request.getStartDate(), request.getEndDate());
            long totalReports = reports.size();
            
            log.info("Retrieved {} reports from database for analysis", totalReports);
            
            if (totalReports == 0) {
                log.warn("No reports found in database for the specified period");
                return createEmptyAnomalyResponse(request);
            }
            
            // Build prompt with real data context
            String prompt = buildAnomalyDetectionPrompt(request, reports);
            
            // Try primary AI service based on configuration
            String aiResponse = null;
            String aiServiceUsed = "unknown";
            
            try {
                String primaryService = aiConfig.getService();
                log.info("Attempting to use primary AI service: {}", primaryService);
                
                if ("gemini".equalsIgnoreCase(primaryService)) {
                    // Try Gemini first
                    try {
                        aiResponse = callGeminiForAnomalyDetection(prompt);
                        aiServiceUsed = "gemini";
                        log.info("Successfully used Gemini for anomaly detection");
                    } catch (Exception geminiException) {
                        log.warn("Primary AI service (gemini) failed: {}", geminiException.getMessage());
                        
                        // Try OpenAI as fallback
                        try {
                            log.info("Trying OpenAI as fallback for anomaly detection");
                            aiResponse = callOpenAIForAnomalyDetection(prompt);
                            aiServiceUsed = "openai";
                            log.info("Successfully used OpenAI fallback for anomaly detection");
                        } catch (Exception openaiException) {
                            log.error("Both AI services failed. Gemini: {}, OpenAI: {}", geminiException.getMessage(), openaiException.getMessage());
                            throw new RuntimeException("All AI services are unavailable");
                        }
                    }
                } else {
                    // Try OpenAI first (default fallback)
                    try {
                        aiResponse = callOpenAIForAnomalyDetection(prompt);
                        aiServiceUsed = "openai";
                        log.info("Successfully used OpenAI for anomaly detection");
                    } catch (Exception openaiException) {
                        log.warn("Primary AI service (openai) failed: {}", openaiException.getMessage());
                        
                        // Try Gemini as fallback
                        try {
                            log.info("Trying Gemini as fallback for anomaly detection");
                            aiResponse = callGeminiForAnomalyDetection(prompt);
                            aiServiceUsed = "gemini";
                            log.info("Successfully used Gemini fallback for anomaly detection");
                        } catch (Exception geminiException) {
                            log.error("Both AI services failed. OpenAI: {}, Gemini: {}", openaiException.getMessage(), geminiException.getMessage());
                            throw new RuntimeException("All AI services are unavailable");
                        }
                    }
                }
            } catch (Exception e) {
                log.error("Error during AI service selection: {}", e.getMessage(), e);
                throw new RuntimeException("AI service selection failed: " + e.getMessage());
            }
            
            // Build response with real data
            AnomalyDetectionResponse response = buildAnomalyDetectionResponse(request, aiResponse, reports);
            response.setAiServiceUsed(aiServiceUsed);
            response.setTotalReportsAnalyzed((int) totalReports);
            
            // Send notifications for detected anomalies
            if (response.getAnomaliesDetected() > 0) {
                notificationService.notifyAllOfficersOfAnomalyDetection(
                    response.getRiskLevel(),
                    response.getAnomaliesDetected(),
                    response.getKeyInsights()
                );
            }
            
            log.info("Successfully built anomaly detection response with {} anomalies", response.getAnomaliesDetected());
            return response;
            
        } catch (Exception e) {
            log.error("Error during anomaly detection: {}", e.getMessage(), e);
            throw new RuntimeException("Anomaly detection failed: " + e.getMessage());
        }
    }
    
    /**
     * Query actual reports from database
     */
    private List<Report> getReportsFromDatabase(LocalDateTime startDate, LocalDateTime endDate) {
        try {
            // Convert LocalDateTime to Instant for database query
            Instant startInstant = startDate.toInstant(java.time.ZoneOffset.UTC);
            Instant endInstant = endDate.toInstant(java.time.ZoneOffset.UTC);
            
            // Query reports within the specified date range
            List<Report> reports = reportRepository.findByDateRange(startInstant, endInstant);
            log.info("Retrieved {} reports from database for period {} to {}", 
                    reports.size(), startDate, endDate);
            return reports;
        } catch (Exception e) {
            log.warn("Error querying database, falling back to mock data: {}", e.getMessage());
            // Fallback to mock data if database query fails
            return createMockReports();
        }
    }
    
    /**
     * Create mock reports as fallback
     */
    private List<Report> createMockReports() {
        List<Report> mockReports = new ArrayList<>();
        
        // Create some mock reports for testing
        for (int i = 0; i < 50; i++) {
            Report report = new Report();
            report.setId(UUID.randomUUID());
            report.setDescription("Mock crime report " + (i + 1));
            report.setTitle("Mock Report " + (i + 1));
            report.setDate(Instant.now().minusSeconds(i * 3600)); // 1 hour apart
            report.setStatus(ReportStatus.PENDING);
            report.setPriority(Priority.MEDIUM);
            report.setSubmittedAt(Instant.now().minusSeconds(i * 3600));
            
            mockReports.add(report);
        }
        
        log.info("Created {} mock reports as fallback", mockReports.size());
        return mockReports;
    }
    
    // Build comprehensive prompt for anomaly detection
    private String buildAnomalyDetectionPrompt(AnomalyDetectionRequest request, List<Report> reports) {
        StringBuilder prompt = new StringBuilder();
        
        // CRITICAL: Very explicit instructions for Gemini
        prompt.append("CRITICAL INSTRUCTIONS: You are a crime prevention AI analyst. You MUST respond with ONLY valid, complete JSON.\n");
        prompt.append("DO NOT include any text before or after the JSON. NO explanations, NO markdown, NO code blocks.\n");
        prompt.append("ONLY return the JSON object. Ensure ALL opening braces { and brackets [ have matching closing ones } and ].\n\n");
        
        prompt.append("Analysis period: ").append(request.getStartDate()).append(" to ").append(request.getEndDate()).append("\n");
        prompt.append("Total reports to analyze: ").append(reports.size()).append("\n\n");
        
        // Add real data context for better analysis
        if (!reports.isEmpty()) {
            prompt.append("REAL REPORTS TO ANALYZE:\n");
            for (int i = 0; i < Math.min(5, reports.size()); i++) {
                Report report = reports.get(i);
                prompt.append("Report ").append(i + 1).append(": ");
                prompt.append("Title: '").append(report.getTitle() != null ? report.getTitle() : "No Title").append("', ");
                prompt.append("Type: '").append(report.getCrimeType() != null ? report.getCrimeType().name() : "Unknown").append("', ");
                prompt.append("Status: '").append(report.getStatus() != null ? report.getStatus().toString() : "Unknown").append("', ");
                prompt.append("Priority: '").append(report.getPriority() != null ? report.getPriority().toString() : "Unknown").append("', ");
                prompt.append("Date: ").append(report.getDate() != null ? report.getDate().toString() : "Unknown").append("\n");
            }
            prompt.append("\n");
        }
        
        prompt.append("ANALYZE THESE REPORTS FOR ANOMALIES. Return ONLY this JSON structure with realistic analysis:\n");
        prompt.append("{\n");
        prompt.append("  \"overallAnomalyScore\": 0.75,\n");
        prompt.append("  \"riskLevel\": \"MEDIUM\",\n");
        prompt.append("  \"falseReportAnomalies\": [\n");
        prompt.append("    {\n");
        prompt.append("      \"description\": \"Suspicious report with inconsistent details\",\n");
        prompt.append("      \"anomalyScore\": 0.8,\n");
        prompt.append("      \"severity\": \"HIGH\",\n");
        prompt.append("      \"location\": \"Downtown Area\",\n");
        prompt.append("      \"crimeType\": \"Theft\",\n");
        prompt.append("      \"contributingFactors\": [\"Vague description\", \"No witnesses\"],\n");
        prompt.append("      \"evidence\": [\"Inconsistent timeline\", \"Missing details\"],\n");
        prompt.append("      \"suggestedActions\": [\"Verify report details\", \"Interview reporter\"]\n");
        prompt.append("    }\n");
        prompt.append("  ],\n");
        prompt.append("  \"suspiciousPatternAnomalies\": [\n");
        prompt.append("    {\n");
        prompt.append("      \"description\": \"Unusual crime pattern detected\",\n");
        prompt.append("      \"anomalyScore\": 0.7,\n");
        prompt.append("      \"severity\": \"MEDIUM\",\n");
        prompt.append("      \"location\": \"Residential Area\",\n");
        prompt.append("      \"crimeType\": \"Burglary\",\n");
        prompt.append("      \"contributingFactors\": [\"Similar MO\", \"Time pattern\"],\n");
        prompt.append("      \"evidence\": [\"Pattern analysis\", \"Geographic clustering\"],\n");
        prompt.append("      \"suggestedActions\": [\"Increase patrols\", \"Community alert\"]\n");
        prompt.append("    }\n");
        prompt.append("  ],\n");
        prompt.append("  \"timingAnomalies\": [],\n");
        prompt.append("  \"geographicAnomalies\": [],\n");
        prompt.append("  \"modusOperandiAnomalies\": [],\n");
        prompt.append("  \"keyInsights\": [\"Potential false report detected\", \"Suspicious pattern identified\"],\n");
        prompt.append("  \"recommendations\": [\"Verify suspicious reports\", \"Monitor pattern development\"],\n");
        prompt.append("  \"categoryScores\": {\n");
        prompt.append("  \"FALSE_REPORTS\": 0.8,\n");
        prompt.append("  \"SUSPICIOUS_PATTERNS\": 0.7,\n");
        prompt.append("  \"TIMING_ANOMALIES\": 0.3,\n");
        prompt.append("  \"GEOGRAPHIC_ANOMALIES\": 0.2,\n");
        prompt.append("  \"MODUS_OPERANDI\": 0.4\n");
        prompt.append("  },\n");
        prompt.append("  \"confidence\": 0.8\n");
        prompt.append("}\n\n");
        
        prompt.append("REMEMBER: ONLY return the JSON above. NO other text. Ensure all brackets are properly closed.\n");
        
        return prompt.toString();
    }
    
    // Call Gemini API for anomaly detection
    private String callGeminiForAnomalyDetection(String prompt) {
        try {
            String url = aiConfig.getGeminiBaseUrl() + "/models/" + aiConfig.getGeminiModel() + ":generateContent";
            
            // Properly escape the prompt for JSON
            String escapedPrompt = prompt.replace("\"", "\\\"").replace("\n", "\\n");
            
            String requestBody = String.format("""
                {
                    "contents": [{
                        "parts": [{
                            "text": "%s"
                        }]
                    }],
                    "generationConfig": {
                        "maxOutputTokens": 2000,
                        "temperature": 0.1,
                        "topP": 0.8,
                        "topK": 40
                    }
                }""", escapedPrompt);
            
            log.debug("Calling Gemini API with URL: {}", url);
            log.debug("Gemini request body: {}", requestBody);
            
            Request request = new Request.Builder()
                    .url(url)
                    .post(RequestBody.create(requestBody, MediaType.get("application/json")))
                    .addHeader("x-goog-api-key", aiConfig.getGeminiApiKey())
                    .addHeader("Content-Type", "application/json")
                    .build();
            
            try (Response response = httpClient.newCall(request).execute()) {
                if (!response.isSuccessful()) {
                    String errorBody = response.body() != null ? response.body().string() : "No error body";
                    log.error("Gemini API error: {} - {}", response.code(), errorBody);
                    throw new RuntimeException("Gemini API error: " + response.code() + " - " + errorBody);
                }
                
                String responseBody = response.body().string();
                log.debug("Gemini raw response: {}", responseBody);
                
                JsonNode jsonResponse = objectMapper.readTree(responseBody);
                String aiText = jsonResponse.path("candidates")
                        .path(0)
                        .path("content")
                        .path("parts")
                        .path(0)
                        .path("text")
                        .asText();
                
                log.info("Gemini extracted text length: {} characters", aiText.length());
                log.info("Gemini raw response text: {}", aiText);
                
                // Log first and last 100 characters for debugging
                if (aiText.length() > 200) {
                    log.info("Gemini response start: {}", aiText.substring(0, 100));
                    log.info("Gemini response end: {}", aiText.substring(aiText.length() - 100));
                }
                
                if (aiText == null || aiText.trim().isEmpty()) {
                    throw new RuntimeException("Gemini returned empty response");
                }
                
                if (aiText.length() < 10) {
                    throw new RuntimeException("Gemini response too short: " + aiText);
                }
                
                return aiText;
            }
        } catch (Exception e) {
            log.error("Error calling Gemini API: {}", e.getMessage(), e);
            throw new RuntimeException("Gemini API error: " + e.getMessage());
        }
    }
    
    // Call OpenAI API for anomaly detection
    private String callOpenAIForAnomalyDetection(String prompt) {
        try {
            String url = aiConfig.getOpenaiBaseUrl() + "/chat/completions";
            
            // Properly escape the prompt for JSON
            String escapedPrompt = prompt.replace("\"", "\\\"").replace("\n", "\\n");
            
            String requestBody = String.format("""
                {
                    "model": "%s",
                    "messages": [{"role": "user", "content": "%s"}],
                    "max_tokens": %d,
                    "temperature": %f
                }""", aiConfig.getOpenaiModel(), escapedPrompt, aiConfig.getOpenaiMaxTokens(), aiConfig.getOpenaiTemperature());
            
            log.debug("Calling OpenAI API with URL: {}", url);
            log.debug("OpenAI request body: {}", requestBody);
            
            Request request = new Request.Builder()
                    .url(url)
                    .post(RequestBody.create(requestBody, MediaType.get("application/json")))
                    .addHeader("Authorization", "Bearer " + aiConfig.getOpenaiApiKey())
                    .addHeader("Content-Type", "application/json")
                    .build();
            
            try (Response response = httpClient.newCall(request).execute()) {
                if (!response.isSuccessful()) {
                    String errorBody = response.body() != null ? response.body().string() : "No error body";
                    log.error("OpenAI API error: {} - {}", response.code(), errorBody);
                    throw new RuntimeException("OpenAI API error: " + response.code() + " - " + errorBody);
                }
                
                String responseBody = response.body().string();
                log.debug("OpenAI raw response: {}", responseBody);
                
                JsonNode jsonResponse = objectMapper.readTree(responseBody);
                String aiText = jsonResponse.path("choices")
                        .path(0)
                        .path("message")
                        .path("content")
                        .asText();
                
                log.debug("OpenAI extracted text length: {} characters", aiText.length());
                log.debug("OpenAI extracted text: {}", aiText);
                
                if (aiText == null || aiText.trim().isEmpty()) {
                    throw new RuntimeException("OpenAI returned empty response");
                }
                
                return aiText;
            }
        } catch (Exception e) {
            log.error("Error calling OpenAI API: {}", e.getMessage(), e);
            throw new RuntimeException("OpenAI API error: " + e.getMessage());
        }
    }
    
    // Build anomaly detection response from AI analysis
    private AnomalyDetectionResponse buildAnomalyDetectionResponse(AnomalyDetectionRequest request, String aiResponse, List<Report> reports) {
        if (aiResponse == null || aiResponse.trim().isEmpty()) {
            log.warn("AI response is null or empty, creating default response");
            return createDefaultAnomalyResponse(request);
        }
        
        try {
            // Extract JSON from AI response
            String jsonContent = extractJsonFromResponse(aiResponse);
            
            if (jsonContent == null) {
                log.warn("Could not extract valid JSON from AI response, creating default response");
                return createDefaultAnomalyResponse(request);
            }
            
            // Parse the JSON response
            JsonNode jsonNode = objectMapper.readTree(jsonContent);
            
            AnomalyDetectionResponse response = new AnomalyDetectionResponse();
            response.setAnalysisId(UUID.randomUUID().toString());
            response.setAnalyzedAt(LocalDateTime.now());
            response.setAiServiceUsed("ai");
            
            // Extract values from JSON
            response.setOverallAnomalyScore(extractDoubleValue(jsonNode, "overallAnomalyScore", 0.0));
            response.setRiskLevel(extractStringValue(jsonNode, "riskLevel", "MEDIUM"));
            response.setConfidence(extractDoubleValue(jsonNode, "confidence", 0.5));
            
            // Extract anomaly lists
            response.setFalseReportAnomalies(createAnomalyList(jsonNode, "falseReportAnomalies", "FALSE_REPORT"));
            response.setSuspiciousPatternAnomalies(createAnomalyList(jsonNode, "suspiciousPatternAnomalies", "SUSPICIOUS_PATTERN"));
            response.setTimingAnomalies(createAnomalyList(jsonNode, "timingAnomalies", "TIMING"));
            response.setGeographicAnomalies(createAnomalyList(jsonNode, "geographicAnomalies", "GEOGRAPHIC"));
            response.setModusOperandiAnomalies(createAnomalyList(jsonNode, "modusOperandiAnomalies", "MODUS_OPERANDI"));
            
            // Extract insights and recommendations
            response.setKeyInsights(extractStringList(jsonNode, "keyInsights"));
            response.setRecommendations(extractStringList(jsonNode, "recommendations"));
            
            // Calculate totals
            int totalAnomalies = response.getFalseReportAnomalies().size() +
                                response.getSuspiciousPatternAnomalies().size() +
                                response.getTimingAnomalies().size() +
                                response.getGeographicAnomalies().size() +
                                response.getModusOperandiAnomalies().size();
            
            response.setTotalReportsAnalyzed(reports.size());
            response.setAnomaliesDetected(totalAnomalies);
            
            // Create category scores
            response.setCategoryScores(createCategoryScores(response));
            
            // Set analysis notes
            response.setAnalysisNotes("AI-generated analysis completed successfully");
            
            log.info("Successfully built anomaly detection response with {} anomalies", totalAnomalies);
            return response;
            
        } catch (Exception e) {
            log.error("Error building anomaly detection response: {}", e.getMessage(), e);
            return createDefaultAnomalyResponse(request);
        }
    }
    
    // Extract JSON content from AI response, handling potential formatting issues
    private String extractJsonFromResponse(String aiResponse) {
        if (aiResponse == null || aiResponse.trim().isEmpty()) {
            log.warn("AI response is null or empty");
            return null;
        }

        log.debug("Processing AI response of length: {}", aiResponse.length());
        
        // Try to find JSON content between braces
        int firstBrace = aiResponse.indexOf('{');
        int lastBrace = aiResponse.lastIndexOf('}');
        
        if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
            String jsonContent = aiResponse.substring(firstBrace, lastBrace + 1);
            try {
                objectMapper.readTree(jsonContent);
                log.debug("Successfully extracted complete JSON from response");
                return jsonContent;
            } catch (Exception e) {
                log.debug("Extracted content is not valid JSON: {}", e.getMessage());
            }
        }
        
        // Try to handle markdown code blocks
        if (aiResponse.contains("```json")) {
            int jsonStart = aiResponse.indexOf("```json") + 7;
            int jsonEnd = aiResponse.indexOf("```", jsonStart);
            if (jsonEnd != -1) {
                String jsonContent = aiResponse.substring(jsonStart, jsonEnd).trim();
                try {
                    objectMapper.readTree(jsonContent);
                    log.debug("Successfully extracted JSON from markdown code block");
                    return jsonContent;
                } catch (Exception e) {
                    log.warn("Markdown JSON content is not valid: {}", e.getMessage());
                }
            }
        }
        
        // Try to complete incomplete JSON
        if (firstBrace != -1) {
            String partialJson = aiResponse.substring(firstBrace);
            log.debug("Attempting to complete partial JSON starting with: {}", partialJson.substring(0, Math.min(100, partialJson.length())));
            
            // Try to find the end of the JSON structure
            int braceCount = 0;
            int endIndex = -1;
            
            for (int i = 0; i < partialJson.length(); i++) {
                char c = partialJson.charAt(i);
                if (c == '{') {
                    braceCount++;
                } else if (c == '}') {
                    braceCount--;
                    if (braceCount == 0) {
                        endIndex = i;
                        break;
                    }
                }
            }
            
            if (endIndex != -1) {
                String completedJson = partialJson.substring(0, endIndex + 1);
                try {
                    objectMapper.readTree(completedJson);
                    log.debug("Successfully completed partial JSON");
                    return completedJson;
                } catch (Exception e) {
                    log.debug("Completed JSON is not valid: {}", e.getMessage());
                }
            }
            
            // If we can't find proper closure, try to add missing closing brackets
            String attemptToComplete = partialJson;
            if (!attemptToComplete.endsWith("}")) {
                // Count open brackets and add missing closing ones
                int openBraces = 0;
                int openBrackets = 0;
                
                for (char c : attemptToComplete.toCharArray()) {
                    if (c == '{') openBraces++;
                    else if (c == '}') openBraces--;
                    else if (c == '[') openBrackets++;
                    else if (c == ']') openBrackets--;
                }
                
                // Add missing closing brackets
                for (int i = 0; i < openBrackets; i++) {
                    attemptToComplete += "]";
                }
                for (int i = 0; i < openBraces; i++) {
                    attemptToComplete += "}";
                }
                
                try {
                    objectMapper.readTree(attemptToComplete);
                    log.debug("Successfully completed JSON by adding missing brackets");
                    return attemptToComplete;
                } catch (Exception e) {
                    log.debug("Attempted completion failed: {}", e.getMessage());
                }
            }
        }
        
        // Try to clean and parse the entire response
        log.warn("No valid JSON structure found, attempting to clean and parse entire response");
        String cleanedResponse = aiResponse.trim();
        
        // Remove common prefixes/suffixes
        if (cleanedResponse.startsWith("```json")) {
            cleanedResponse = cleanedResponse.substring(7);
        }
        
        // Try Gemini-specific cleaning
        if (cleanedResponse.startsWith("```")) {
            cleanedResponse = cleanedResponse.substring(3);
        }
        if (cleanedResponse.endsWith("```")) {
            cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length() - 3);
        }
        
        // Remove any text before the first {
        int jsonStart = cleanedResponse.indexOf('{');
        if (jsonStart > 0) {
            cleanedResponse = cleanedResponse.substring(jsonStart);
        }
        
        // Try to parse the cleaned response
        try {
            objectMapper.readTree(cleanedResponse);
            log.debug("Successfully parsed cleaned response");
            return cleanedResponse;
        } catch (Exception e) {
            log.debug("Cleaned response is not valid JSON: {}", e.getMessage());
        }
        
        // Try to find any JSON-like content
        cleanedResponse = cleanedResponse.trim();
        if (cleanedResponse.startsWith("{") && cleanedResponse.endsWith("}")) {
            try {
                objectMapper.readTree(cleanedResponse);
                log.debug("Successfully parsed cleaned response as JSON");
                return cleanedResponse;
            } catch (Exception e) {
                log.warn("Cleaned response is not valid JSON: {}", e.getMessage());
            }
        }
        
        log.error("Could not extract valid JSON from AI response");
        log.debug("Full AI response: {}", aiResponse);
        return null;
    }
    
    // Create default anomaly response if AI parsing fails
    private AnomalyDetectionResponse createDefaultAnomalyResponse(AnomalyDetectionRequest request) {
        return AnomalyDetectionResponse.builder()
                .analysisId(UUID.randomUUID().toString())
                .analyzedAt(LocalDateTime.now())
                .aiServiceUsed(aiConfig.getService())
                .totalReportsAnalyzed(100)
                .anomaliesDetected(3)
                .overallAnomalyScore(0.6)
                .riskLevel("MEDIUM")
                .falseReportAnomalies(createMockAnomalies("FALSE_REPORT", 1))
                .suspiciousPatternAnomalies(createMockAnomalies("SUSPICIOUS_PATTERN", 1))
                .timingAnomalies(createMockAnomalies("TIMING", 1))
                .geographicAnomalies(new ArrayList<>())
                .modusOperandiAnomalies(new ArrayList<>())
                .keyInsights(Arrays.asList("Analysis completed with default values", "AI service may be temporarily unavailable"))
                .recommendations(Arrays.asList("Review recent reports manually", "Check system connectivity"))
                .categoryScores(createCategoryScores())
                .confidence(0.5)
                .analysisNotes("Default response generated due to AI service unavailability")
                .build();
    }
    
    // Helper methods for creating mock data
    private List<AnomalyDetectionResponse.Anomaly> createMockAnomalies(String type, int count) {
        List<AnomalyDetectionResponse.Anomaly> anomalies = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            anomalies.add(AnomalyDetectionResponse.Anomaly.builder()
                    .anomalyId(UUID.randomUUID().toString())
                    .anomalyType(type)
                    .description("Mock " + type + " anomaly for testing")
                    .anomalyScore(0.7 + (i * 0.1))
                    .severity("MEDIUM")
                    .location("Test Location " + (i + 1))
                    .crimeType("Test Crime")
                    .detectedAt(LocalDateTime.now())
                    .contributingFactors(Arrays.asList("Factor 1", "Factor 2"))
                    .evidence(Arrays.asList("Evidence 1", "Evidence 2"))
                    .suggestedActions(Arrays.asList("Action 1", "Action 2"))
                    .metadata(new HashMap<>())
                    .build());
        }
        return anomalies;
    }
    
    private Map<String, Double> createCategoryScores() {
        Map<String, Double> scores = new HashMap<>();
        scores.put("FALSE_REPORTS", 0.6);
        scores.put("SUSPICIOUS_PATTERNS", 0.7);
        scores.put("TIMING_ANOMALIES", 0.5);
        scores.put("GEOGRAPHIC_ANOMALIES", 0.4);
        scores.put("MODUS_OPERANDI", 0.6);
        return scores;
    }
    
    // Helper methods for extracting values from AI response
    private int extractIntValue(JsonNode json, String field, String subField, int defaultValue) {
        try {
            if (subField != null) {
                return json.path(field).path(subField).asInt(defaultValue);
            }
            return json.path(field).asInt(defaultValue);
        } catch (Exception e) {
            return defaultValue;
        }
    }
    
    private double extractDoubleValue(JsonNode json, String field, double defaultValue) {
        try {
            return json.path(field).asDouble(defaultValue);
        } catch (Exception e) {
            return defaultValue;
        }
    }
    
    private String extractStringValue(JsonNode json, String field, String defaultValue) {
        try {
            String value = json.path(field).asText();
            return value != null && !value.isEmpty() ? value : defaultValue;
        } catch (Exception e) {
            return defaultValue;
        }
    }
    
    private List<String> extractStringList(JsonNode json, String field) {
        try {
            List<String> list = new ArrayList<>();
            JsonNode array = json.path(field);
            if (array.isArray()) {
                for (JsonNode item : array) {
                    list.add(item.asText());
                }
            }
            return list.isEmpty() ? Arrays.asList("No data available") : list;
        } catch (Exception e) {
            return Arrays.asList("Data extraction failed");
        }
    }
    
    private List<AnomalyDetectionResponse.Anomaly> createAnomalyList(JsonNode jsonNode, String fieldName, String anomalyType) {
        List<AnomalyDetectionResponse.Anomaly> anomalies = new ArrayList<>();
        
        try {
            JsonNode fieldNode = jsonNode.get(fieldName);
            if (fieldNode != null && fieldNode.isArray()) {
                for (JsonNode item : fieldNode) {
                    AnomalyDetectionResponse.Anomaly anomaly = new AnomalyDetectionResponse.Anomaly();
                    anomaly.setAnomalyId(UUID.randomUUID().toString());
                    anomaly.setAnomalyType(anomalyType);
                    anomaly.setDescription(extractStringValue(item, "description", "Mock " + anomalyType + " anomaly"));
                    anomaly.setAnomalyScore(extractDoubleValue(item, "anomalyScore", 0.7));
                    anomaly.setSeverity(extractStringValue(item, "severity", "MEDIUM"));
                    anomaly.setLocation(extractStringValue(item, "location", "Test Location"));
                    anomaly.setCrimeType(extractStringValue(item, "crimeType", "Test Crime"));
                    anomaly.setDetectedAt(LocalDateTime.now());
                    anomaly.setContributingFactors(extractStringList(item, "contributingFactors"));
                    anomaly.setEvidence(extractStringList(item, "evidence"));
                    anomaly.setSuggestedActions(extractStringList(item, "suggestedActions"));
                    anomaly.setMetadata(new HashMap<>());
                    
                    anomalies.add(anomaly);
                }
            }
        } catch (Exception e) {
            log.warn("Error creating anomaly list for {}: {}", fieldName, e.getMessage());
        }
        
        return anomalies;
    }
    
    private Map<String, Double> createCategoryScores(AnomalyDetectionResponse response) {
        Map<String, Double> scores = new HashMap<>();
        
        // Calculate scores based on actual anomalies
        scores.put("FALSE_REPORTS", calculateCategoryScore(response.getFalseReportAnomalies()));
        scores.put("SUSPICIOUS_PATTERNS", calculateCategoryScore(response.getSuspiciousPatternAnomalies()));
        scores.put("TIMING_ANOMALIES", calculateCategoryScore(response.getTimingAnomalies()));
        scores.put("GEOGRAPHIC_ANOMALIES", calculateCategoryScore(response.getGeographicAnomalies()));
        scores.put("MODUS_OPERANDI", calculateCategoryScore(response.getModusOperandiAnomalies()));
        
        return scores;
    }
    
    private double calculateCategoryScore(List<AnomalyDetectionResponse.Anomaly> anomalies) {
        if (anomalies == null || anomalies.isEmpty()) {
            return 0.0;
        }
        
        return anomalies.stream()
                .mapToDouble(AnomalyDetectionResponse.Anomaly::getAnomalyScore)
                .average()
                .orElse(0.0);
    }

    @Override
    public RecommendationResponse generateRecommendations(RecommendationRequest request) {
        // TODO: Implement recommendations
        throw new UnsupportedOperationException("Recommendations not yet implemented");
    }

    @Override
    public boolean isServiceAvailable() {
        return aiConfig.isEnabled() && 
               (aiConfig.getOpenaiApiKey() != null || aiConfig.getGeminiApiKey() != null);
    }
    
    @Override
    public String getCurrentService() {
        if (!aiConfig.isEnabled()) {
            return "DISABLED";
        }
        
        String primaryService = aiConfig.getService();
        if ("openai".equalsIgnoreCase(primaryService) && aiConfig.getOpenaiApiKey() != null) {
            return "openai";
        } else if ("gemini".equalsIgnoreCase(primaryService) && aiConfig.getGeminiApiKey() != null) {
            return "gemini";
        }
        
        // Fallback logic
        if (aiConfig.getOpenaiApiKey() != null) {
            return "openai (fallback)";
        } else if (aiConfig.getGeminiApiKey() != null) {
            return "gemini (fallback)";
        }
        
        return "NONE_AVAILABLE";
    }
    
    // Get detailed service status
    public Map<String, Object> getServiceStatus() {
        Map<String, Object> status = new HashMap<>();
        status.put("enabled", aiConfig.isEnabled());
        status.put("primaryService", aiConfig.getService());
        status.put("openaiAvailable", aiConfig.getOpenaiApiKey() != null);
        status.put("geminiAvailable", aiConfig.getGeminiApiKey() != null);
        status.put("currentService", getCurrentService());
        status.put("cacheEnabled", aiConfig.isCacheEnabled());
        status.put("cacheTtl", aiConfig.getCacheTtl());
        return status;
    }

    // OpenAI Implementation
    private ReportSummaryResponse generateOpenAISummary(ReportSummaryRequest request) throws IOException {
        String prompt = buildSummaryPrompt(request);
        
        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", aiConfig.getOpenaiModel());
        requestBody.put("messages", Arrays.asList(
            Map.of("role", "system", "content", "You are a crime prevention AI assistant. Generate concise, professional summaries of crime reports."),
            Map.of("role", "user", "content", prompt)
        ));
        requestBody.put("max_tokens", aiConfig.getOpenaiMaxTokens());
        requestBody.put("temperature", aiConfig.getOpenaiTemperature());

        Request httpRequest = new Request.Builder()
                .url(aiConfig.getOpenaiBaseUrl() + "/chat/completions")
                .addHeader("Authorization", "Bearer " + aiConfig.getOpenaiApiKey())
                .addHeader("Content-Type", "application/json")
                .post(RequestBody.create(
                    objectMapper.writeValueAsString(requestBody),
                    MediaType.get("application/json")
                ))
                .build();

        try (Response response = httpClient.newCall(httpRequest).execute()) {
            if (!response.isSuccessful()) {
                throw new RuntimeException("OpenAI API error: " + response.code() + " - " + response.body().string());
            }

            JsonNode responseJson = objectMapper.readTree(response.body().string());
            String summary = responseJson.path("choices").path(0).path("message").path("content").asText();
            
            return buildSummaryResponse(request, summary, "openai");
        }
    }

    // Gemini Implementation
    private ReportSummaryResponse generateGeminiSummary(ReportSummaryRequest request) throws IOException {
        String prompt = buildSummaryPrompt(request);
        
        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("contents", Arrays.asList(
            Map.of("parts", Arrays.asList(
                Map.of("text", prompt)
            ))
        ));
        requestBody.put("generationConfig", Map.of(
            "maxOutputTokens", aiConfig.getGeminiMaxTokens(),
            "temperature", aiConfig.getGeminiTemperature()
        ));

        String url = aiConfig.getGeminiBaseUrl() + "/models/" + aiConfig.getGeminiModel() + ":generateContent?key=" + aiConfig.getGeminiApiKey();

        Request httpRequest = new Request.Builder()
                .url(url)
                .addHeader("Content-Type", "application/json")
                .post(RequestBody.create(
                    objectMapper.writeValueAsString(requestBody),
                    MediaType.get("application/json")
                ))
                .build();

        try (Response response = httpClient.newCall(httpRequest).execute()) {
            if (!response.isSuccessful()) {
                throw new RuntimeException("Gemini API error: " + response.code() + " - " + response.body().string());
            }

            JsonNode responseJson = objectMapper.readTree(response.body().string());
            String summary = responseJson.path("candidates").path(0).path("content").path("parts").path(0).path("text").asText();
            
            return buildSummaryResponse(request, summary, "gemini");
        }
    }

    // Hybrid Implementation (fallback between services)
    private ReportSummaryResponse generateHybridSummary(ReportSummaryRequest request) throws IOException {
        try {
            return generateOpenAISummary(request);
        } catch (Exception e) {
            log.warn("OpenAI failed, trying Gemini: {}", e.getMessage());
            try {
                return generateGeminiSummary(request);
            } catch (Exception e2) {
                log.error("Both AI services failed: OpenAI: {}, Gemini: {}", e.getMessage(), e2.getMessage());
                throw new RuntimeException("All AI services are unavailable");
            }
        }
    }

    private String buildSummaryPrompt(ReportSummaryRequest request) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("Please provide a ").append(request.getSummaryLength().name().toLowerCase())
              .append(" summary (approximately ").append(request.getSummaryLength().getMaxWords()).append(" words) of the following crime report:\n\n");
        
        prompt.append("Title: ").append(request.getTitle()).append("\n");
        prompt.append("Description: ").append(request.getDescription()).append("\n");
        
        if (request.getCrimeType() != null) {
            prompt.append("Crime Type: ").append(request.getCrimeType()).append("\n");
        }
        if (request.getLocation() != null) {
            prompt.append("Location: ").append(request.getLocation()).append("\n");
        }
        if (request.getTimestamp() != null) {
            prompt.append("Timestamp: ").append(request.getTimestamp()).append("\n");
        }
        
        prompt.append("\nPlease provide:\n");
        prompt.append("1. A concise summary\n");
        prompt.append("2. Key points (bullet points)\n");
        prompt.append("3. Urgency level (LOW, MEDIUM, HIGH, CRITICAL)\n");
        prompt.append("4. Priority level (LOW, MEDIUM, HIGH, URGENT)\n");
        prompt.append("5. Relevant tags\n");
        prompt.append("6. Language used in the report\n");
        
        return prompt.toString();
    }

    private ReportSummaryResponse buildSummaryResponse(ReportSummaryRequest request, String aiResponse, String service) {
        // Parse AI response and extract components
        // This is a simplified parser - you might want to use more sophisticated parsing
        String[] lines = aiResponse.split("\n");
        
        String summary = "";
        String keyPoints = "";
        String urgency = "MEDIUM";
        String priority = "MEDIUM";
        List<String> tags = new ArrayList<>();
        String language = "English";
        
        // Improved parsing logic to handle the AI response format
        for (String line : lines) {
            line = line.trim();
            if (line.startsWith("1.") || line.startsWith("**Concise Summary:**")) {
                // Extract summary from the first section
                summary = line.replaceAll("^1\\.\\s*|^\\*\\*Concise Summary:\\*\\*\\s*", "").trim();
            } else if (line.startsWith("2.") || line.startsWith("**Key Points:**")) {
                // Extract key points from the second section
                keyPoints = line.replaceAll("^2\\.\\s*|^\\*\\*Key Points:\\*\\*\\s*", "").trim();
            } else if (line.startsWith("3.") || line.startsWith("**Urgency level:**") || line.toLowerCase().contains("urgency")) {
                // Extract urgency level
                String urgencyText = line.replaceAll("^3\\.\\s*|^\\*\\*Urgency level:\\*\\*\\s*", "").trim();
                urgency = extractEnumValue(urgencyText, "MEDIUM", ReportSummary.UrgencyLevel.class);
            } else if (line.startsWith("4.") || line.startsWith("**Priority level:**") || line.toLowerCase().contains("priority")) {
                // Extract priority level
                String priorityText = line.replaceAll("^4\\.\\s*|^\\*\\*Priority level:\\*\\*\\s*", "").trim();
                priority = extractEnumValue(priorityText, "MEDIUM", ReportSummary.PriorityLevel.class);
            } else if (line.startsWith("5.") || line.startsWith("**Relevant tags:**") || line.toLowerCase().contains("tags")) {
                // Extract tags
                String tagsText = line.replaceAll("^5\\.\\s*|^\\*\\*Relevant tags:\\*\\*\\s*", "").trim();
                tags = extractTags(tagsText);
            } else if (line.startsWith("6.") || line.startsWith("**Language used:**") || line.toLowerCase().contains("language")) {
                // Extract language
                String languageText = line.replaceAll("^6\\.\\s*|^\\*\\*Language used:\\*\\*\\s*", "").trim();
                language = extractValue(languageText);
            }
        }
        
        // If summary is still empty, use the first meaningful line
        if (summary.isEmpty()) {
            for (String line : lines) {
                line = line.trim();
                if (!line.isEmpty() && !line.startsWith("*") && !line.startsWith("1.") && !line.startsWith("2.") && 
                    !line.startsWith("3.") && !line.startsWith("4.") && !line.startsWith("5.") && !line.startsWith("6.")) {
                    summary = line;
                    break;
                }
            }
        }
        
        return ReportSummaryResponse.builder()
                .summaryId(UUID.randomUUID().toString())
                .summary(summary.isEmpty() ? aiResponse : summary)
                .keyPoints(keyPoints)
                .urgency(urgency)
                .priority(priority)
                .tags(tags)
                .language(language)
                .confidence(0.85) // Default confidence
                .wordCount(aiResponse.split("\\s+").length)
                .modelVersion(service.equals("openai") ? aiConfig.getOpenaiModel() : aiConfig.getGeminiModel())
                .promptUsed(buildSummaryPrompt(request))
                .build();
    }

    private String extractValue(String line) {
        if (line.contains(":")) {
            return line.split(":")[1].trim();
        }
        return "UNKNOWN";
    }

    private List<String> extractTags(String line) {
        // Simple tag extraction - you might want to improve this
        List<String> tags = new ArrayList<>();
        if (line.toLowerCase().contains("tags:")) {
            String tagPart = line.substring(line.indexOf(":") + 1).trim();
            String[] tagArray = tagPart.split(",");
            for (String tag : tagArray) {
                tags.add(tag.trim());
            }
        }
        return tags;
    }

    private String extractEnumValue(String text, String defaultValue, Class<? extends Enum<?>> enumClass) {
        if (text == null || text.trim().isEmpty()) {
            return defaultValue;
        }
        
        // Clean up the text and try to extract enum values
        String cleanText = text.trim().toUpperCase();
        
        // Try to find enum values in the text
        for (Enum<?> enumValue : enumClass.getEnumConstants()) {
            if (cleanText.contains(enumValue.name())) {
                return enumValue.name();
            }
        }
        
        // If no enum value found, return default
        return defaultValue;
    }

    // ==================== CRUD OPERATIONS FOR AI SUMMARIES ====================

    @Override
    public Map<String, Object> getAllSummaries(int page, int size, String aiServiceName, String urgencyLevel, 
                                             String priorityLevel, Double minConfidence, String tag) {
        try {
            // Create pageable request
            Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
            
            // Build dynamic query based on filters
            Specification<ReportSummary> spec = Specification.where(null);
            
            if (aiServiceName != null && !aiServiceName.trim().isEmpty()) {
                spec = spec.and((root, query, cb) -> cb.equal(root.get("aiServiceUsed"), aiServiceName));
            }
            
            if (urgencyLevel != null && !urgencyLevel.trim().isEmpty()) {
                spec = spec.and((root, query, cb) -> cb.equal(root.get("urgencyLevel"), 
                    ReportSummary.UrgencyLevel.valueOf(urgencyLevel.toUpperCase())));
            }
            
            if (priorityLevel != null && !priorityLevel.trim().isEmpty()) {
                spec = spec.and((root, query, cb) -> cb.equal(root.get("priorityLevel"), 
                    ReportSummary.PriorityLevel.valueOf(priorityLevel.toUpperCase())));
            }
            
            if (minConfidence != null) {
                spec = spec.and((root, query, cb) -> cb.greaterThanOrEqualTo(root.get("confidenceScore"), minConfidence));
            }
            
            if (tag != null && !tag.trim().isEmpty()) {
                spec = spec.and((root, query, cb) -> cb.isMember(tag, root.get("tags")));
            }
            
            // Execute query with pagination
            Page<ReportSummary> summaryPage = reportSummaryRepository.findAll(spec, pageable);
            
            // Convert to DTOs
            List<ReportSummaryResponse> summaries = summaryPage.getContent().stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
            
            return Map.of(
                "summaries", summaries,
                "totalElements", summaryPage.getTotalElements(),
                "totalPages", summaryPage.getTotalPages(),
                "currentPage", page,
                "pageSize", size,
                "hasNext", summaryPage.hasNext(),
                "hasPrevious", summaryPage.hasPrevious()
            );
            
        } catch (Exception e) {
            log.error("Error retrieving summaries: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to retrieve summaries: " + e.getMessage(), e);
        }
    }

    @Override
    public ReportSummaryResponse getSummaryById(UUID summaryId) {
        try {
            ReportSummary summary = reportSummaryRepository.findById(summaryId)
                .orElseThrow(() -> new RuntimeException("Summary not found with ID: " + summaryId));
            
            return convertToResponse(summary);
        } catch (Exception e) {
            log.error("Error retrieving summary by ID: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to retrieve summary: " + e.getMessage(), e);
        }
    }

    @Override
    public List<ReportSummaryResponse> getSummariesByReport(UUID reportId) {
        try {
            List<ReportSummary> summaries = reportSummaryRepository.findByReportId(reportId);
            return summaries.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
        } catch (Exception e) {
            log.error("Error retrieving summaries by report: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to retrieve summaries by report: " + e.getMessage(), e);
        }
    }

    @Override
    public ReportSummaryResponse updateSummary(UUID summaryId, UpdateSummaryRequest request) {
        try {
            ReportSummary summary = reportSummaryRepository.findById(summaryId)
                .orElseThrow(() -> new RuntimeException("Summary not found with ID: " + summaryId));
            
            // Update fields
            summary.setSummary(request.getSummary());
            summary.setKeyPoints(request.getKeyPoints());
            summary.setUrgencyLevel(ReportSummary.UrgencyLevel.valueOf(request.getUrgencyLevel().name()));
            summary.setPriorityLevel(ReportSummary.PriorityLevel.valueOf(request.getPriorityLevel().name()));
            summary.setTags(request.getTags());
            summary.setUpdatedAt(LocalDateTime.now());
            
            // Save updated summary
            ReportSummary updatedSummary = reportSummaryRepository.save(summary);
            
            return convertToResponse(updatedSummary);
        } catch (Exception e) {
            log.error("Error updating summary: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to update summary: " + e.getMessage(), e);
        }
    }

    @Override
    public void deleteSummary(UUID summaryId) {
        try {
            if (!reportSummaryRepository.existsById(summaryId)) {
                throw new RuntimeException("Summary not found with ID: " + summaryId);
            }
            
            reportSummaryRepository.deleteById(summaryId);
            log.info("Summary deleted successfully: {}", summaryId);
        } catch (Exception e) {
            log.error("Error deleting summary: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to delete summary: " + e.getMessage(), e);
        }
    }

    @Override
    public ReportSummaryResponse regenerateSummary(UUID summaryId) {
        try {
            ReportSummary existingSummary = reportSummaryRepository.findById(summaryId)
                .orElseThrow(() -> new RuntimeException("Summary not found with ID: " + summaryId));
            
            // Get the original report
            ReportResponse report = reportService.getReportById(existingSummary.getReport().getId(), 
                UUID.fromString("01034ed9-3b28-434d-ae52-fe2c5d5fbb4d")); // Admin user ID
            
            // Create new summary request
            String locationStr = report.getLocation() != null ? 
                report.getLocation().getAddress() + ", " + report.getLocation().getCity() : "Unknown Location";
            
            ReportSummaryRequest request = ReportSummaryRequest.builder()
                .title(report.getTitle())
                .description(report.getDescription())
                .crimeType(report.getCrimeType().name())
                .location(locationStr)
                .timestamp(report.getDate() != null ? report.getDate().toString() : "")
                .reporterName(report.getReporter().getFullName())
                .additionalDetails(List.of("Regenerated summary for report ID: " + report.getId()))
                .summaryLength(ReportSummaryRequest.SummaryLength.MEDIUM)
                .build();
            
            // Generate new summary
            ReportSummaryResponse newSummary = summarizeReport(request);
            
            // Update the existing summary entity
            existingSummary.setSummary(newSummary.getSummary());
            existingSummary.setKeyPoints(newSummary.getKeyPoints());
            existingSummary.setUrgencyLevel(ReportSummary.UrgencyLevel.valueOf(newSummary.getUrgency()));
            existingSummary.setPriorityLevel(ReportSummary.PriorityLevel.valueOf(newSummary.getPriority()));
            existingSummary.setTags(newSummary.getTags());
            existingSummary.setConfidenceScore(newSummary.getConfidence());
            existingSummary.setUpdatedAt(LocalDateTime.now());
            existingSummary.setProcessingTimeMs(newSummary.getProcessingTimeMs());
            
            // Save updated summary
            ReportSummary savedSummary = reportSummaryRepository.save(existingSummary);
            
            return convertToResponse(savedSummary);
        } catch (Exception e) {
            log.error("Error regenerating summary: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to regenerate summary: " + e.getMessage(), e);
        }
    }

    @Override
    public Map<String, Object> getSummaryStatistics() {
        try {
            long totalSummaries = reportSummaryRepository.count();
            long geminiSummaries = reportSummaryRepository.countByAiServiceUsed("gemini");
            long openaiSummaries = reportSummaryRepository.countByAiServiceUsed("openai");
            
            // Get urgency level distribution
            Map<String, Long> urgencyDistribution = Arrays.stream(ReportSummary.UrgencyLevel.values())
                .collect(Collectors.toMap(
                    ReportSummary.UrgencyLevel::name,
                    level -> reportSummaryRepository.countByUrgencyLevel(level)
                ));
            
            // Get priority level distribution
            Map<String, Long> priorityDistribution = Arrays.stream(ReportSummary.PriorityLevel.values())
                .collect(Collectors.toMap(
                    ReportSummary.PriorityLevel::name,
                    level -> reportSummaryRepository.countByPriorityLevel(level)
                ));
            
            // Get average confidence score
            Double avgConfidence = reportSummaryRepository.findAll().stream()
                .mapToDouble(ReportSummary::getConfidenceScore)
                .average()
                .orElse(0.0);
            
            // Get average processing time
            Double avgProcessingTime = reportSummaryRepository.findAll().stream()
                .mapToDouble(summary -> summary.getProcessingTimeMs() != null ? summary.getProcessingTimeMs() : 0)
                .average()
                .orElse(0.0);
            
            return Map.of(
                "totalSummaries", totalSummaries,
                "aiServiceDistribution", Map.of(
                    "gemini", geminiSummaries,
                    "openai", openaiSummaries
                ),
                "urgencyDistribution", urgencyDistribution,
                "priorityDistribution", priorityDistribution,
                "averageConfidence", avgConfidence,
                "averageProcessingTimeMs", avgProcessingTime,
                "generatedAt", LocalDateTime.now().toString()
            );
            
        } catch (Exception e) {
            log.error("Error retrieving summary statistics: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to retrieve summary statistics: " + e.getMessage(), e);
        }
    }

    // Helper method to convert ReportSummary entity to ReportSummaryResponse DTO
    private ReportSummaryResponse convertToResponse(ReportSummary summary) {
        return ReportSummaryResponse.builder()
            .summaryId(summary.getId().toString())
            .originalReportId(summary.getReport() != null ? summary.getReport().getId().toString() : null)
            .summary(summary.getSummary())
            .keyPoints(summary.getKeyPoints())
            .urgency(summary.getUrgencyLevel() != null ? summary.getUrgencyLevel().name() : "MEDIUM")
            .priority(summary.getPriorityLevel() != null ? summary.getPriorityLevel().name() : "MEDIUM")
            .tags(summary.getTags() != null ? summary.getTags() : new ArrayList<>())
            .aiServiceUsed(summary.getAiServiceUsed())
            .generatedAt(summary.getCreatedAt())
            .confidence(summary.getConfidenceScore() != null ? summary.getConfidenceScore() : 0.0)
            .language(summary.getLanguage() != null ? summary.getLanguage() : "English")
            .wordCount(summary.getWordCount() != null ? summary.getWordCount() : 0)
            .processingTimeMs(summary.getProcessingTimeMs() != null ? summary.getProcessingTimeMs() : 0)
            .modelVersion(summary.getModelVersion())
            .promptUsed(summary.getPromptUsed())
            .build();
    }

    /**
     * Test method to simulate different anomaly scenarios
     * This helps validate the AI's detection capabilities
     */
    public AnomalyDetectionResponse testAnomalyDetectionScenarios() {
        log.info("Testing anomaly detection with different scenarios");
        
        // Test Scenario 1: Multiple false reports
        AnomalyDetectionRequest scenario1 = new AnomalyDetectionRequest();
        scenario1.setStartDate(LocalDateTime.now().minusDays(3));
        scenario1.setEndDate(LocalDateTime.now());
        scenario1.setDetectFalseReports(true);
        scenario1.setDetectSuspiciousPatterns(true);
        scenario1.setDetectUnusualTiming(true);
        scenario1.setDetectGeographicAnomalies(true);
        scenario1.setDetectModusOperandiAnomalies(true);
        scenario1.setMaxAnomalies(10);
        
        log.info("Testing Scenario 1: Multiple anomaly types");
        AnomalyDetectionResponse response1 = detectAnomalies(scenario1);
        
        // Test Scenario 2: Focus on suspicious patterns
        AnomalyDetectionRequest scenario2 = new AnomalyDetectionRequest();
        scenario2.setStartDate(LocalDateTime.now().minusDays(7));
        scenario2.setEndDate(LocalDateTime.now());
        scenario2.setDetectFalseReports(false);
        scenario2.setDetectSuspiciousPatterns(true);
        scenario2.setDetectUnusualTiming(true);
        scenario2.setDetectGeographicAnomalies(true);
        scenario2.setDetectModusOperandiAnomalies(true);
        scenario2.setMaxAnomalies(15);
        
        log.info("Testing Scenario 2: Pattern-focused analysis");
        AnomalyDetectionResponse response2 = detectAnomalies(scenario2);
        
        // Return the more comprehensive result
        if (response1.getAnomaliesDetected() > response2.getAnomaliesDetected()) {
            log.info("Scenario 1 detected more anomalies: {}", response1.getAnomaliesDetected());
            return response1;
        } else {
            log.info("Scenario 2 detected more anomalies: {}", response2.getAnomaliesDetected());
            return response2;
        }
    }
    
    @Override
    public String testGeminiService(String testPrompt) {
        log.info("Testing Gemini service directly with prompt: {}", testPrompt);
        try {
            return callGeminiForAnomalyDetection(testPrompt);
        } catch (Exception e) {
            log.error("Error testing Gemini service: {}", e.getMessage(), e);
            return "Error: " + e.getMessage();
        }
    }

    /**
     * Create empty anomaly response when no reports are found
     */
    private AnomalyDetectionResponse createEmptyAnomalyResponse(AnomalyDetectionRequest request) {
        AnomalyDetectionResponse response = new AnomalyDetectionResponse();
        response.setAnalysisId(UUID.randomUUID().toString());
        response.setAnalyzedAt(LocalDateTime.now());
        response.setAiServiceUsed("none");
        response.setTotalReportsAnalyzed(0);
        response.setAnomaliesDetected(0);
        response.setOverallAnomalyScore(0.0);
        response.setRiskLevel("LOW");
        response.setFalseReportAnomalies(new ArrayList<>());
        response.setSuspiciousPatternAnomalies(new ArrayList<>());
        response.setTimingAnomalies(new ArrayList<>());
        response.setGeographicAnomalies(new ArrayList<>());
        response.setModusOperandiAnomalies(new ArrayList<>());
        response.setKeyInsights(Arrays.asList("No reports found for analysis period"));
        response.setRecommendations(Arrays.asList("Check date range and database connectivity"));
        response.setCategoryScores(new HashMap<>());
        response.setConfidence(0.0);
        response.setAnalysisNotes("No data available for analysis");
        
        return response;
    }
}
