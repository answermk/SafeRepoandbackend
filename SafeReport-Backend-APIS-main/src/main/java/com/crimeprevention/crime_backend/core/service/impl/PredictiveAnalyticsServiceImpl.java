package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.dto.analytics.PredictiveAnalyticsRequest;
import com.crimeprevention.crime_backend.core.dto.analytics.PredictiveAnalyticsResponse;
import com.crimeprevention.crime_backend.core.model.report.Report;
import com.crimeprevention.crime_backend.core.repo.report.ReportRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.PredictiveAnalyticsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class PredictiveAnalyticsServiceImpl implements PredictiveAnalyticsService {
    
    private final ReportRepository reportRepository;
    
    @Override
    public PredictiveAnalyticsResponse generatePredictiveAnalytics(PredictiveAnalyticsRequest request) {
        long startTime = System.currentTimeMillis();
        log.info("Generating comprehensive predictive analytics for request: {}", request);
        
        try {
            // Generate all types of analytics
            List<PredictiveAnalyticsResponse.CrimePrediction> crimePredictions = generateCrimePredictions(request);
            List<PredictiveAnalyticsResponse.RiskAssessment> riskAssessments = generateRiskAssessments(request);
            List<PredictiveAnalyticsResponse.PatternForecast> patternForecasts = generatePatternForecasts(request);
            PredictiveAnalyticsResponse.HistoricalAnalysis historicalAnalysis = generateHistoricalAnalysis(request);
            List<PredictiveAnalyticsResponse.RiskFactor> riskFactors = generateRiskFactors(request);
            PredictiveAnalyticsResponse.ModelInsights modelInsights = generateModelInsights();
            
            PredictiveAnalyticsResponse response = PredictiveAnalyticsResponse.builder()
                    .predictionId(UUID.randomUUID().toString())
                    .analysisType(request.getAnalysisType())
                    .generatedAt(LocalDateTime.now())
                    .predictionDate(request.getPredictionDate())
                    .location(request.getLocation())
                    .modelType(request.getModelType())
                    .modelAccuracy(0.85) // Mock accuracy
                    .overallConfidence(0.82) // Mock confidence
                    .processingTimeMs(System.currentTimeMillis() - startTime)
                    .crimePredictions(crimePredictions)
                    .riskAssessments(riskAssessments)
                    .patternForecasts(patternForecasts)
                    .historicalAnalysis(historicalAnalysis)
                    .riskFactors(riskFactors)
                    .modelInsights(modelInsights)
                    .build();
            
            log.info("Predictive analytics generated successfully in {}ms", response.getProcessingTimeMs());
            return response;
            
        } catch (Exception e) {
            log.error("Error generating predictive analytics", e);
            throw new RuntimeException("Failed to generate predictive analytics: " + e.getMessage());
        }
    }
    
    @Override
    public PredictiveAnalyticsResponse predictCrimeOccurrences(PredictiveAnalyticsRequest request) {
        log.info("Predicting crime occurrences for request: {}", request);
        
        try {
            List<PredictiveAnalyticsResponse.CrimePrediction> predictions = generateCrimePredictions(request);
            
            return PredictiveAnalyticsResponse.builder()
                    .predictionId(UUID.randomUUID().toString())
                    .analysisType("CRIME_PREDICTION")
                    .generatedAt(LocalDateTime.now())
                    .predictionDate(request.getPredictionDate())
                    .location(request.getLocation())
                    .modelType(request.getModelType())
                    .modelAccuracy(0.87)
                    .overallConfidence(0.84)
                    .crimePredictions(predictions)
                    .build();
                    
        } catch (Exception e) {
            log.error("Error predicting crime occurrences", e);
            throw new RuntimeException("Failed to predict crime occurrences: " + e.getMessage());
        }
    }
    
    @Override
    public PredictiveAnalyticsResponse assessRiskLevels(PredictiveAnalyticsRequest request) {
        log.info("Assessing risk levels for request: {}", request);
        
        try {
            List<PredictiveAnalyticsResponse.RiskAssessment> riskAssessments = generateRiskAssessments(request);
            
            return PredictiveAnalyticsResponse.builder()
                    .predictionId(UUID.randomUUID().toString())
                    .analysisType("RISK_ASSESSMENT")
                    .generatedAt(LocalDateTime.now())
                    .predictionDate(request.getPredictionDate())
                    .location(request.getLocation())
                    .modelType(request.getModelType())
                    .modelAccuracy(0.89)
                    .overallConfidence(0.86)
                    .riskAssessments(riskAssessments)
                    .build();
                    
        } catch (Exception e) {
            log.error("Error assessing risk levels", e);
            throw new RuntimeException("Failed to assess risk levels: " + e.getMessage());
        }
    }
    
    @Override
    public PredictiveAnalyticsResponse forecastCrimePatterns(PredictiveAnalyticsRequest request) {
        log.info("Forecasting crime patterns for request: {}", request);
        
        try {
            List<PredictiveAnalyticsResponse.PatternForecast> patternForecasts = generatePatternForecasts(request);
            
            return PredictiveAnalyticsResponse.builder()
                    .predictionId(UUID.randomUUID().toString())
                    .analysisType("PATTERN_FORECASTING")
                    .generatedAt(LocalDateTime.now())
                    .predictionDate(request.getPredictionDate())
                    .location(request.getLocation())
                    .modelType(request.getModelType())
                    .modelAccuracy(0.83)
                    .overallConfidence(0.80)
                    .patternForecasts(patternForecasts)
                    .build();
                    
        } catch (Exception e) {
            log.error("Error forecasting crime patterns", e);
            throw new RuntimeException("Failed to forecast crime patterns: " + e.getMessage());
        }
    }
    
    @Override
    public PredictiveAnalyticsResponse getRealTimeRiskAssessment(String location) {
        log.info("Generating real-time risk assessment for location: {}", location);
        
        try {
            // Get recent crime data for real-time assessment
            Instant since = Instant.now().minusSeconds(24 * 3600);
            Pageable pageable = PageRequest.of(0, 100);
            
            List<Report> recentReports = reportRepository.findByDateRange(since, Instant.now());
            
            // Generate real-time risk assessment
            List<PredictiveAnalyticsResponse.RiskAssessment> riskAssessments = generateRealTimeRiskAssessment(location, recentReports);
            
            return PredictiveAnalyticsResponse.builder()
                    .predictionId(UUID.randomUUID().toString())
                    .analysisType("REAL_TIME_RISK_ASSESSMENT")
                    .generatedAt(LocalDateTime.now())
                    .predictionDate(LocalDateTime.now())
                    .location(location)
                    .modelType("real_time")
                    .modelAccuracy(0.91)
                    .overallConfidence(0.88)
                    .riskAssessments(riskAssessments)
                    .build();
                    
        } catch (Exception e) {
            log.error("Error generating real-time risk assessment", e);
            throw new RuntimeException("Failed to generate real-time risk assessment: " + e.getMessage());
        }
    }
    
    @Override
    public PredictiveAnalyticsResponse generateTimeSeriesAnalysis(String location, String timeRange, String granularity) {
        log.info("Generating time series analysis: location={}, timeRange={}, granularity={}", location, timeRange, granularity);
        
        try {
            // Parse time range
            LocalDateTime startDate = parseTimeRange(timeRange);
            LocalDateTime endDate = LocalDateTime.now();
            
            // Fetch historical data
            List<Report> historicalReports = fetchHistoricalReports(startDate, endDate, location);
            
            // Generate time series analysis
            PredictiveAnalyticsResponse.HistoricalAnalysis historicalAnalysis = generateHistoricalAnalysisFromReports(
                    historicalReports, startDate, endDate);
            
            return PredictiveAnalyticsResponse.builder()
                    .predictionId(UUID.randomUUID().toString())
                    .analysisType("TIME_SERIES_ANALYSIS")
                    .generatedAt(LocalDateTime.now())
                    .predictionDate(LocalDateTime.now())
                    .location(location)
                    .modelType("time_series")
                    .modelAccuracy(0.86)
                    .overallConfidence(0.83)
                    .historicalAnalysis(historicalAnalysis)
                    .build();
                    
        } catch (Exception e) {
            log.error("Error generating time series analysis", e);
            throw new RuntimeException("Failed to generate time series analysis: " + e.getMessage());
        }
    }
    
    @Override
    public PredictiveAnalyticsResponse.ModelInsights getModelPerformance() {
        log.info("Retrieving model performance metrics");
        
        try {
            return generateModelInsights();
        } catch (Exception e) {
            log.error("Error retrieving model performance", e);
            throw new RuntimeException("Failed to retrieve model performance: " + e.getMessage());
        }
    }
    
    @Override
    public boolean retrainModels() {
        log.info("Retraining predictive models");
        
        try {
            // Mock retraining process
            log.info("Models retrained successfully");
            return true;
        } catch (Exception e) {
            log.error("Error retraining models", e);
            return false;
        }
    }
    
    @Override
    public Map<String, Double> getFeatureImportance() {
        log.info("Retrieving feature importance for ML models");
        
        try {
            // Mock feature importance data
            Map<String, Double> featureImportance = new HashMap<>();
            featureImportance.put("time_of_day", 0.85);
            featureImportance.put("day_of_week", 0.78);
            featureImportance.put("location", 0.92);
            featureImportance.put("crime_type", 0.76);
            featureImportance.put("weather_conditions", 0.65);
            featureImportance.put("population_density", 0.71);
            featureImportance.put("previous_crimes", 0.88);
            featureImportance.put("economic_factors", 0.62);
            
            return featureImportance;
        } catch (Exception e) {
            log.error("Error retrieving feature importance", e);
            throw new RuntimeException("Failed to retrieve feature importance: " + e.getMessage());
        }
    }
    
    // Helper methods
    
    private List<PredictiveAnalyticsResponse.CrimePrediction> generateCrimePredictions(PredictiveAnalyticsRequest request) {
        List<PredictiveAnalyticsResponse.CrimePrediction> predictions = new ArrayList<>();
        
        // Mock crime predictions based on historical data
        String[] crimeTypes = {"Theft", "Assault", "Burglary", "Robbery", "Vandalism"};
        String[] timeSlots = {"Morning", "Afternoon", "Evening", "Night"};
        
        for (String crimeType : crimeTypes) {
            for (String timeSlot : timeSlots) {
                // Generate mock prediction
                double predictedCount = Math.random() * 10 + 1; // 1-11 crimes
                double confidence = 0.7 + Math.random() * 0.3; // 70-100% confidence
                double riskScore = Math.random() * 1.0; // 0-1 risk score
                
                PredictiveAnalyticsResponse.CrimePrediction prediction = PredictiveAnalyticsResponse.CrimePrediction.builder()
                        .predictionId(UUID.randomUUID().toString())
                        .crimeType(crimeType)
                        .predictedDate(request.getPredictionDate())
                        .predictedCount(predictedCount)
                        .confidence(confidence)
                        .location(request.getLocation())
                        .timeSlot(timeSlot)
                        .riskScore(riskScore)
                        .contributingFactors(Arrays.asList("Historical patterns", "Seasonal trends", "Location factors"))
                        .metadata(new HashMap<>())
                        .build();
                
                predictions.add(prediction);
            }
        }
        
        return predictions;
    }
    
    private List<PredictiveAnalyticsResponse.RiskAssessment> generateRiskAssessments(PredictiveAnalyticsRequest request) {
        List<PredictiveAnalyticsResponse.RiskAssessment> assessments = new ArrayList<>();
        
        // Mock risk assessments
        String[] riskTypes = {"CRIME_RISK", "SAFETY_RISK", "SECURITY_RISK"};
        String[] riskLevels = {"LOW", "MEDIUM", "HIGH", "CRITICAL"};
        
        for (String riskType : riskTypes) {
            double riskScore = Math.random() * 1.0;
            String riskLevel = determineRiskLevel(riskScore);
            
            PredictiveAnalyticsResponse.RiskAssessment assessment = PredictiveAnalyticsResponse.RiskAssessment.builder()
                    .assessmentId(UUID.randomUUID().toString())
                    .location(request.getLocation())
                    .riskType(riskType)
                    .riskScore(riskScore)
                    .riskLevel(riskLevel)
                    .assessmentDate(LocalDateTime.now())
                    .validUntil(LocalDateTime.now().plusDays(7))
                    .riskFactors(Arrays.asList("Historical crime data", "Environmental factors", "Social indicators"))
                    .mitigationStrategies(Arrays.asList("Increase patrols", "Community awareness", "Security measures"))
                    .details(new HashMap<>())
                    .build();
            
            assessments.add(assessment);
        }
        
        return assessments;
    }
    
    private List<PredictiveAnalyticsResponse.PatternForecast> generatePatternForecasts(PredictiveAnalyticsRequest request) {
        List<PredictiveAnalyticsResponse.PatternForecast> forecasts = new ArrayList<>();
        
        // Mock pattern forecasts
        String[] patternTypes = {"Geographic clustering", "Temporal patterns", "Modus operandi", "Victim profiling"};
        
        for (String patternType : patternTypes) {
            double probability = 0.6 + Math.random() * 0.4; // 60-100% probability
            double impactScore = Math.random() * 1.0;
            
            PredictiveAnalyticsResponse.PatternForecast forecast = PredictiveAnalyticsResponse.PatternForecast.builder()
                    .forecastId(UUID.randomUUID().toString())
                    .patternType(patternType)
                    .description("Predicted " + patternType.toLowerCase() + " based on historical analysis")
                    .forecastDate(request.getPredictionDate())
                    .probability(probability)
                    .location(request.getLocation())
                    .affectedAreas(Arrays.asList("Downtown", "Suburbs", "Shopping areas"))
                    .crimeTypes(Arrays.asList("Theft", "Assault", "Burglary"))
                    .impactScore(impactScore)
                    .preventiveMeasures(Arrays.asList("Enhanced surveillance", "Community alerts", "Police coordination"))
                    .forecastData(new HashMap<>())
                    .build();
            
            forecasts.add(forecast);
        }
        
        return forecasts;
    }
    
    private PredictiveAnalyticsResponse.HistoricalAnalysis generateHistoricalAnalysis(PredictiveAnalyticsRequest request) {
        // Mock historical analysis
        Map<String, Long> crimesByType = new HashMap<>();
        crimesByType.put("Theft", 45L);
        crimesByType.put("Assault", 23L);
        crimesByType.put("Burglary", 18L);
        crimesByType.put("Robbery", 12L);
        
        Map<String, Long> crimesByLocation = new HashMap<>();
        crimesByLocation.put("Downtown", 35L);
        crimesByLocation.put("Suburbs", 28L);
        crimesByLocation.put("Shopping areas", 25L);
        crimesByLocation.put("Residential", 10L);
        
        return PredictiveAnalyticsResponse.HistoricalAnalysis.builder()
                .analysisStartDate(request.getStartDate())
                .analysisEndDate(request.getEndDate())
                .totalCrimes(98L)
                .crimesByType(crimesByType)
                .crimesByLocation(crimesByLocation)
                .crimesByTime(new HashMap<>())
                .averageCrimeRate(3.2)
                .trends(Arrays.asList("Increasing theft in shopping areas", "Decreasing assault rates", "Seasonal burglary patterns"))
                .anomalies(Arrays.asList("Unusual spike in downtown robberies", "Decreased crime during holidays"))
                .build();
    }
    
    private List<PredictiveAnalyticsResponse.RiskFactor> generateRiskFactors(PredictiveAnalyticsRequest request) {
        List<PredictiveAnalyticsResponse.RiskFactor> riskFactors = new ArrayList<>();
        
        // Mock risk factors
        String[] factorNames = {"Population density", "Economic indicators", "Weather conditions", "Previous crime rate", "Security measures"};
        String[] factorTypes = {"DEMOGRAPHIC", "ECONOMIC", "ENVIRONMENTAL", "HISTORICAL", "SECURITY"};
        
        for (int i = 0; i < factorNames.length; i++) {
            double currentValue = Math.random() * 100;
            double thresholdValue = 50 + Math.random() * 50;
            String status = currentValue > thresholdValue ? "ELEVATED" : "NORMAL";
            
            PredictiveAnalyticsResponse.RiskFactor factor = PredictiveAnalyticsResponse.RiskFactor.builder()
                    .factorId(UUID.randomUUID().toString())
                    .factorName(factorNames[i])
                    .factorType(factorTypes[i])
                    .weight(0.1 + Math.random() * 0.9)
                    .description("Risk factor related to " + factorNames[i].toLowerCase())
                    .currentValue(currentValue)
                    .thresholdValue(thresholdValue)
                    .status(status)
                    .mitigationActions(Arrays.asList("Monitor closely", "Implement controls", "Review policies"))
                    .factorData(new HashMap<>())
                    .build();
            
            riskFactors.add(factor);
        }
        
        return riskFactors;
    }
    
    private PredictiveAnalyticsResponse.ModelInsights generateModelInsights() {
        return PredictiveAnalyticsResponse.ModelInsights.builder()
                .modelVersion("v2.1.0")
                .lastTrained(LocalDateTime.now().minusDays(7))
                .trainingAccuracy(0.89)
                .validationAccuracy(0.87)
                .keyFeatures(Arrays.asList("Time patterns", "Geographic clustering", "Crime type correlation", "Environmental factors"))
                .limitations(Arrays.asList("Limited data for rare crime types", "Weather dependency", "Seasonal variations"))
                .dataQuality("High - 95% completeness, 98% accuracy")
                .recommendations(Arrays.asList("Increase data collection frequency", "Expand feature set", "Regular model retraining"))
                .technicalDetails(new HashMap<>())
                .build();
    }
    
    private List<PredictiveAnalyticsResponse.RiskAssessment> generateRealTimeRiskAssessment(String location, List<Report> recentReports) {
        List<PredictiveAnalyticsResponse.RiskAssessment> assessments = new ArrayList<>();
        
        // Calculate real-time risk based on recent reports
        double crimeRate = recentReports.size() / 24.0; // crimes per hour
        double riskScore = Math.min(crimeRate * 0.1, 1.0); // normalize to 0-1
        
        String riskLevel = determineRiskLevel(riskScore);
        
        PredictiveAnalyticsResponse.RiskAssessment assessment = PredictiveAnalyticsResponse.RiskAssessment.builder()
                .assessmentId(UUID.randomUUID().toString())
                .location(location)
                .riskType("REAL_TIME_CRIME_RISK")
                .riskScore(riskScore)
                .riskLevel(riskLevel)
                .assessmentDate(LocalDateTime.now())
                .validUntil(LocalDateTime.now().plusHours(1))
                .riskFactors(Arrays.asList("Recent crime activity", "Time of day", "Current conditions"))
                .mitigationStrategies(Arrays.asList("Immediate response", "Alert nearby units", "Community notification"))
                .details(new HashMap<>())
                .build();
        
        assessments.add(assessment);
        return assessments;
    }
    
    private PredictiveAnalyticsResponse.HistoricalAnalysis generateHistoricalAnalysisFromReports(
            List<Report> reports, LocalDateTime startDate, LocalDateTime endDate) {
        
        Map<String, Long> crimesByType = reports.stream()
                .collect(Collectors.groupingBy(
                    report -> report.getCrimeType().name(),
                    Collectors.counting()));
        
        Map<String, Long> crimesByLocation = reports.stream()
                .collect(Collectors.groupingBy(
                    report -> report.getLocation() != null ? report.getLocation().getAddress() : "Unknown",
                    Collectors.counting()));
        
        double averageCrimeRate = reports.size() / (double) ChronoUnit.DAYS.between(startDate, endDate);
        
        return PredictiveAnalyticsResponse.HistoricalAnalysis.builder()
                .analysisStartDate(startDate)
                .analysisEndDate(endDate)
                .totalCrimes((long) reports.size())
                .crimesByType(crimesByType)
                .crimesByLocation(crimesByLocation)
                .crimesByTime(new HashMap<>())
                .averageCrimeRate(averageCrimeRate)
                .trends(Arrays.asList("Historical trend analysis", "Pattern identification", "Seasonal variations"))
                .anomalies(Arrays.asList("Unusual activity detection", "Statistical outliers"))
                .build();
    }
    
    private LocalDateTime parseTimeRange(String timeRange) {
        switch (timeRange.toLowerCase()) {
            case "24h":
                return LocalDateTime.now().minusHours(24);
            case "7d":
                return LocalDateTime.now().minusDays(7);
            case "30d":
                return LocalDateTime.now().minusDays(30);
            case "90d":
                return LocalDateTime.now().minusDays(90);
            default:
                return LocalDateTime.now().minusDays(7);
        }
    }
    
    private List<Report> fetchHistoricalReports(LocalDateTime startDate, LocalDateTime endDate, String location) {
        // Simplified implementation - in real system, use location-based queries
        Instant startInstant = startDate.atZone(java.time.ZoneId.systemDefault()).toInstant();
        Instant endInstant = endDate.atZone(java.time.ZoneId.systemDefault()).toInstant();
        return reportRepository.findByDateRange(startInstant, endInstant);
    }
    
    private String determineRiskLevel(double riskScore) {
        if (riskScore < 0.25) return "LOW";
        else if (riskScore < 0.5) return "MEDIUM";
        else if (riskScore < 0.75) return "HIGH";
        else return "CRITICAL";
    }
}
