package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.dto.mapping.*;

import com.crimeprevention.crime_backend.core.model.report.Report;
import com.crimeprevention.crime_backend.core.repo.report.ReportRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.CrimeMapService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
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
public class CrimeMapServiceImpl implements CrimeMapService {
    
    private final ReportRepository reportRepository;
    
    @Override
    public CrimeMapResponse generateCrimeMap(CrimeMapRequest request) {
        long startTime = System.currentTimeMillis();
        log.info("Generating crime map for request: {}", request);
        
        try {
                    // Parse time range
        Instant startDate = parseTimeRangeInstant(request);
        Instant endDate = Instant.now();
            
            // Fetch crime reports
            List<Report> reports = fetchCrimeReports(startDate, endDate, request);
            
            // Generate map data based on type
            CrimeMapResponse response;
            switch (request.getMapType().toLowerCase()) {
                case "heatmap":
                    response = generateHeatmapData(reports, request);
                    break;
                case "clusters":
                    response = generateClusterData(reports, request);
                    break;
                case "individual":
                default:
                    response = generateIndividualPoints(reports, request);
                    break;
            }
            
            // Set metadata
            response.setMapId(UUID.randomUUID().toString());
            response.setMapType(request.getMapType());
            response.setGeneratedAt(LocalDateTime.now());
            response.setTotalCrimes((long) reports.size());
            response.setProcessingTimeMs(System.currentTimeMillis() - startTime);
            
            // Generate statistics
            response.setStatistics(generateMapStatistics(reports));
            
            log.info("Crime map generated successfully in {}ms", response.getProcessingTimeMs());
            return response;
            
        } catch (Exception e) {
            log.error("Error generating crime map", e);
            throw new RuntimeException("Failed to generate crime map: " + e.getMessage());
        }
    }
    
    @Override
    public CrimeMapResponse getCrimeHeatmap(CrimeMapRequest request) {
        request.setMapType("heatmap");
        return generateCrimeMap(request);
    }
    
    @Override
    public CrimeMapResponse getCrimeClusters(CrimeMapRequest request) {
        request.setMapType("clusters");
        return generateCrimeMap(request);
    }
    
    @Override
    public CrimeMapResponse getCrimePoints(CrimeMapRequest request) {
        request.setMapType("individual");
        return generateCrimeMap(request);
    }
    
    @Override
    public List<LiveIncidentResponse> getLiveIncidents() {
        log.info("Fetching live incidents");
        
        try {
                    // Get recent reports (last 7 days to ensure we have data)
        Instant since = Instant.now().minusSeconds(7 * 24 * 3600);
        
        List<Report> recentReports = reportRepository.findByDateRange(since, Instant.now());
        log.info("Found {} reports for live incidents from {} to {}", recentReports.size(), since, Instant.now());
            
            return recentReports.stream()
                    .map(this::convertToLiveIncident)
                    .collect(Collectors.toList());
                    
        } catch (Exception e) {
            log.error("Error fetching live incidents", e);
            throw new RuntimeException("Failed to fetch live incidents: " + e.getMessage());
        }
    }
    
    @Override
    public List<LiveIncidentResponse> getLiveIncidentsInArea(
            Double latitude, Double longitude, Double radiusKm, String timeRange) {
        log.info("Fetching live incidents in area: lat={}, lng={}, radius={}km, timeRange={}", latitude, longitude, radiusKm, timeRange);
        
        try {
            // Parse time range
            Instant startDate = parseTimeRangeInstant(timeRange);
            Instant endDate = Instant.now();
            
            // Get reports within time range
            List<Report> reports = reportRepository.findByDateRange(startDate, endDate);
            
            // Filter by distance and convert to LiveIncidentResponse
            return reports.stream()
                    .filter(report -> {
                        if (report.getLocation() == null || 
                            report.getLocation().getLatitude() == null || 
                            report.getLocation().getLongitude() == null) {
                            return false;
                        }
                        double distance = calculateDistance(
                            latitude, longitude,
                            report.getLocation().getLatitude(),
                            report.getLocation().getLongitude()
                        );
                        return distance <= radiusKm;
                    })
                    .map(this::convertToLiveIncident)
                    .collect(Collectors.toList());
                    
        } catch (Exception e) {
            log.error("Error fetching live incidents in area", e);
            throw new RuntimeException("Failed to fetch live incidents in area: " + e.getMessage());
        }
    }
    
    /**
     * Parse time range string to Instant
     */
    private Instant parseTimeRangeInstant(String timeRange) {
        if (timeRange == null || timeRange.isEmpty()) {
            return Instant.now().minusSeconds(7 * 24 * 3600); // Default: 7 days
        }
        
        timeRange = timeRange.toLowerCase().trim();
        Instant now = Instant.now();
        
        if (timeRange.equals("1h") || timeRange.equals("1hour")) {
            return now.minusSeconds(3600);
        } else if (timeRange.equals("24h") || timeRange.equals("1d") || timeRange.equals("1day")) {
            return now.minusSeconds(24 * 3600);
        } else if (timeRange.equals("7d") || timeRange.equals("week")) {
            return now.minusSeconds(7 * 24 * 3600);
        } else if (timeRange.equals("30d") || timeRange.equals("month")) {
            return now.minusSeconds(30L * 24 * 3600);
        } else if (timeRange.equals("1y") || timeRange.equals("year")) {
            return now.minusSeconds(365L * 24 * 3600);
        } else {
            // Default to 7 days
            return now.minusSeconds(7 * 24 * 3600);
        }
    }
    
    /**
     * Calculate distance between two coordinates using Haversine formula
     * Returns distance in kilometers
     */
    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371; // Earth's radius in kilometers
        
        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        
        return R * c;
    }
    
    @Override
    public CrimeMapResponse.MapStatistics getAreaStatistics(
            Double latitude, Double longitude, Double radiusKm) {
        log.info("Generating area statistics for: lat={}, lng={}, radius={}km", latitude, longitude, radiusKm);
        
        try {
            // Get incidents in area (default to 7 days)
            List<LiveIncidentResponse> incidents = getLiveIncidentsInArea(latitude, longitude, radiusKm, "7d");
            
            return generateStatisticsFromIncidents(incidents);
            
        } catch (Exception e) {
            log.error("Error generating area statistics", e);
            throw new RuntimeException("Failed to generate area statistics: " + e.getMessage());
        }
    }
    
    @Override
    public CrimeMapResponse getCrimeTrends(String location, String timeRange) {
        log.info("Generating crime trends for location: {}, timeRange: {}", location, timeRange);
        
        try {
            // Parse time range
            LocalDateTime startDate = parseTimeRangeString(timeRange);
            LocalDateTime endDate = LocalDateTime.now();
            
            // Fetch reports for location and time range
            List<Report> reports = fetchCrimeReportsByLocation(location, startDate, endDate);
            
            // Generate trend analysis
            CrimeMapResponse response = CrimeMapResponse.builder()
                    .mapId(UUID.randomUUID().toString())
                    .mapType("trends")
                    .generatedAt(LocalDateTime.now())
                    .totalCrimes((long) reports.size())
                    .statistics(generateMapStatistics(reports))
                    .build();
            
            return response;
            
        } catch (Exception e) {
            log.error("Error generating crime trends", e);
            throw new RuntimeException("Failed to generate crime trends: " + e.getMessage());
        }
    }
    
    // Helper methods
    
    private Instant parseTimeRangeInstant(CrimeMapRequest request) {
        if (request.getStartDate() != null) {
            return request.getStartDate().atZone(java.time.ZoneId.systemDefault()).toInstant();
        }
        
        switch (request.getTimeRange()) {
            case "24h":
                return Instant.now().minusSeconds(7 * 24 * 3600); // Use 7 days for 24h to get more data
            case "7d":
                return Instant.now().minusSeconds(7 * 24 * 3600);
            case "30d":
                return Instant.now().minusSeconds(30 * 24 * 3600);
            case "custom":
            default:
                return Instant.now().minusSeconds(7 * 24 * 3600); // Default to 7 days
        }
    }
    
    private LocalDateTime parseTimeRangeString(String timeRange) {
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
    
    private List<Report> fetchCrimeReports(Instant startDate, Instant endDate, CrimeMapRequest request) {
        // This is a simplified implementation
        // In a real system, you'd use JPA specifications or custom queries
        List<Report> reports = reportRepository.findByDateRange(startDate, endDate);
        log.info("Fetched {} reports from database for date range: {} to {}", reports.size(), startDate, endDate);
        
        // Apply filters
        if (request.getCrimeTypes() != null && !request.getCrimeTypes().isEmpty()) {
            reports = reports.stream()
                    .filter(report -> request.getCrimeTypes().contains(report.getCrimeType()))
                    .collect(Collectors.toList());
            log.info("After crime type filtering: {} reports", reports.size());
        }
        
        if (request.getMaxPoints() != null && request.getMaxPoints() > 0) {
            reports = reports.stream()
                    .limit(request.getMaxPoints())
                    .collect(Collectors.toList());
            log.info("After max points limiting: {} reports", reports.size());
        }
        
        return reports;
    }
    
    private List<Report> fetchCrimeReportsByLocation(String location, LocalDateTime startDate, LocalDateTime endDate) {
        // Simplified implementation - in real system, use location-based queries
        Instant startInstant = startDate.atZone(java.time.ZoneId.systemDefault()).toInstant();
        Instant endInstant = endDate.atZone(java.time.ZoneId.systemDefault()).toInstant();
        return reportRepository.findByDateRange(startInstant, endInstant);
    }
    
    private CrimeMapResponse generateHeatmapData(List<Report> reports, CrimeMapRequest request) {
        // Generate heatmap points with clustering
        List<CrimeMapResponse.HeatmapPoint> heatmapData = new ArrayList<>();
        
        // Group reports by location (simplified clustering)
        Map<String, List<Report>> locationGroups = reports.stream()
                .collect(Collectors.groupingBy(report -> 
                    report.getLocation() != null ? report.getLocation().getAddress() : "Unknown"));
        
        for (Map.Entry<String, List<Report>> entry : locationGroups.entrySet()) {
            String address = entry.getKey();
            List<Report> locationReports = entry.getValue();
            
            // Calculate average coordinates (simplified)
            double avgLat = -1.9441; // Default coordinates for Rwanda
            double avgLng = 30.0619;
            
            // Create multiple heatmap points for better visualization
            for (int i = 0; i < Math.min(locationReports.size(), 5); i++) {
                // Add some variation to coordinates for better spread
                double latVariation = avgLat + (Math.random() - 0.5) * 0.01;
                double lngVariation = avgLng + (Math.random() - 0.5) * 0.01;
                
                // Calculate weight based on crime count and severity
                double weight = calculateCrimeWeight(locationReports);
                
                CrimeMapResponse.HeatmapPoint point = CrimeMapResponse.HeatmapPoint.builder()
                        .latitude(latVariation)
                        .longitude(lngVariation)
                        .weight(weight)
                        .crimeType(locationReports.get(0).getCrimeType().name())
                        .crimeCount(locationReports.size())
                        .build();
                
                heatmapData.add(point);
            }
        }
        
        return CrimeMapResponse.builder()
                .heatmapData(heatmapData)
                .build();
    }
    
    private CrimeMapResponse generateClusterData(List<Report> reports, CrimeMapRequest request) {
        // Generate geographic clusters
        List<CrimeMapResponse.CrimeCluster> clusters = new ArrayList<>();
        
        // Simple clustering by location (in real system, use DBSCAN or K-means)
        Map<String, List<Report>> locationGroups = reports.stream()
                .collect(Collectors.groupingBy(report -> 
                    report.getLocation() != null ? report.getLocation().getDistrict() : "Unknown"));
        
        int clusterId = 1;
        for (Map.Entry<String, List<Report>> entry : locationGroups.entrySet()) {
            String district = entry.getKey();
            List<Report> districtReports = entry.getValue();
            
            if (districtReports.size() < 2) continue; // Skip single reports
            
            // Calculate cluster center and statistics
            double avgLat = -1.9441; // Default coordinates
            double avgLng = 30.0619;
            double avgRiskScore = districtReports.stream()
                    .mapToDouble(report -> calculateRiskScore(report))
                    .average()
                    .orElse(0.5);
            
            CrimeMapResponse.CrimeCluster cluster = CrimeMapResponse.CrimeCluster.builder()
                    .clusterId("CLUSTER_" + clusterId++)
                    .latitude(avgLat)
                    .longitude(avgLng)
                    .crimeCount(districtReports.size())
                    .crimeTypes(districtReports.stream()
                            .map(report -> report.getCrimeType().name())
                            .distinct()
                            .collect(Collectors.toList()))
                    .averageRiskScore(avgRiskScore)
                    .firstCrime(districtReports.stream()
                            .map(Report::getSubmittedAt)
                            .min(Instant::compareTo)
                            .orElse(Instant.now())
                            .atZone(java.time.ZoneId.systemDefault()).toLocalDateTime())
                    .lastCrime(districtReports.stream()
                            .map(Report::getSubmittedAt)
                            .max(Instant::compareTo)
                            .orElse(Instant.now())
                            .atZone(java.time.ZoneId.systemDefault()).toLocalDateTime())
                    .sampleCrimes(districtReports.stream()
                            .limit(5)
                            .map(this::convertToCrimeProperties)
                            .collect(Collectors.toList()))
                    .build();
            
            clusters.add(cluster);
        }
        
        return CrimeMapResponse.builder()
                .clusters(clusters)
                .build();
    }
    
    private CrimeMapResponse generateIndividualPoints(List<Report> reports, CrimeMapRequest request) {
        // Generate individual crime points
        List<CrimeMapResponse.CrimeFeature> features = reports.stream()
                .map(this::convertToCrimeFeature)
                .collect(Collectors.toList());
        
        return CrimeMapResponse.builder()
                .features(features)
                .build();
    }
    
    private CrimeMapResponse.CrimeFeature convertToCrimeFeature(Report report) {
        CrimeMapResponse.CrimeGeometry geometry = CrimeMapResponse.CrimeGeometry.builder()
                .coordinates(Arrays.asList(30.0619, -1.9441)) // Default coordinates
                .build();
        
        CrimeMapResponse.CrimeProperties properties = convertToCrimeProperties(report);
        
        return CrimeMapResponse.CrimeFeature.builder()
                .geometry(geometry)
                .properties(properties)
                .build();
    }
    
    private CrimeMapResponse.CrimeProperties convertToCrimeProperties(Report report) {
        Map<String, Object> additionalData = new HashMap<>();
        additionalData.put("reporterId", report.getReporter().getId());
        additionalData.put("submittedAt", report.getSubmittedAt());
        
        return CrimeMapResponse.CrimeProperties.builder()
                .crimeId(report.getId().toString())
                .title(report.getTitle())
                .crimeType(report.getCrimeType().name())
                .status(report.getStatus().name())
                .priority(report.getPriority().name())
                .crimeDate(report.getDate().atZone(java.time.ZoneId.systemDefault()).toLocalDateTime())
                .location(report.getLocation() != null ? report.getLocation().getAddress() : "Unknown")
                .riskScore(calculateRiskScore(report))
                .additionalData(additionalData)
                .build();
    }
    
    private LiveIncidentResponse convertToLiveIncident(Report report) {
        // Get actual location coordinates
        Double latitude = -1.9441; // Default: Kigali
        Double longitude = 30.0619;
        String locationAddress = "Unknown";
        
        if (report.getLocation() != null) {
            if (report.getLocation().getLatitude() != null) {
                latitude = report.getLocation().getLatitude();
            }
            if (report.getLocation().getLongitude() != null) {
                longitude = report.getLocation().getLongitude();
            }
            if (report.getLocation().getAddress() != null && !report.getLocation().getAddress().trim().isEmpty()) {
                locationAddress = report.getLocation().getAddress();
            } else if (report.getLocation().getDistrict() != null && !report.getLocation().getDistrict().trim().isEmpty()) {
                locationAddress = report.getLocation().getDistrict();
            }
        }
        
        return LiveIncidentResponse.builder()
                .incidentId(report.getId().toString())
                .title(report.getTitle())
                .description(report.getDescription())
                .crimeType(report.getCrimeType() != null ? report.getCrimeType().name() : "OTHER")
                .status(report.getStatus() != null ? report.getStatus().name() : "PENDING")
                .priority(report.getPriority() != null ? report.getPriority().name() : "NORMAL")
                .latitude(latitude)
                .longitude(longitude)
                .location(locationAddress)
                .reportedAt(report.getSubmittedAt() != null ? 
                    report.getSubmittedAt().atZone(java.time.ZoneId.systemDefault()).toLocalDateTime() : 
                    LocalDateTime.now())
                .lastUpdated(report.getUpdatedAt() != null ? 
                    report.getUpdatedAt().atZone(java.time.ZoneId.systemDefault()).toLocalDateTime() : 
                    LocalDateTime.now())
                .reporterName(report.getReporter() != null && !report.isAnonymous() ? 
                    report.getReporter().getFullName() : "Anonymous")
                .isAnonymous(report.isAnonymous())
                .riskScore(calculateRiskScore(report))
                .tags(Arrays.asList(
                    report.getCrimeType() != null ? report.getCrimeType().name() : "OTHER",
                    report.getPriority() != null ? report.getPriority().name() : "NORMAL"
                ))
                .updateType("NEW")
                .updateMessage("New crime report filed")
                .updateTimestamp(LocalDateTime.now())
                .build();
    }
    
    private double calculateCrimeWeight(List<Report> reports) {
        // Calculate weight based on crime count and severity
        double baseWeight = reports.size() * 0.1;
        double severityBonus = reports.stream()
                .mapToDouble(report -> getPriorityWeight(report.getPriority().name()))
                .sum();
        
        return Math.min(baseWeight + severityBonus, 1.0);
    }
    
    private double calculateRiskScore(Report report) {
        // Calculate risk score based on crime type, priority, and status
        double baseScore = 0.5;
        
        // Priority weight
        baseScore += getPriorityWeight(report.getPriority().name());
        
        // Status weight
        if (report.getStatus().name().equals("PENDING")) {
            baseScore += 0.2;
        }
        
        // Crime type weight (simplified)
        if (report.getCrimeType().name().equals("ASSAULT") || 
            report.getCrimeType().name().equals("ROBBERY")) {
            baseScore += 0.3;
        }
        
        return Math.min(baseScore, 1.0);
    }
    
    private double getPriorityWeight(String priority) {
        switch (priority.toUpperCase()) {
            case "LOW": return 0.1;
            case "MEDIUM": return 0.2;
            case "HIGH": return 0.3;
            case "URGENT": return 0.5;
            case "CRITICAL": return 0.4;
            default: return 0.2;
        }
    }
    
    private boolean isWithinRadius(double lat1, double lng1, double lat2, double lng2, double radiusKm) {
        // Haversine formula for distance calculation
        double latDistance = Math.toRadians(lat2 - lat1);
        double lngDistance = Math.toRadians(lng2 - lng1);
        
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lngDistance / 2) * Math.sin(lngDistance / 2);
        
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double distance = 6371 * c; // Earth's radius in km
        
        return distance <= radiusKm;
    }
    
    private CrimeMapResponse.MapStatistics generateMapStatistics(List<Report> reports) {
        Map<String, Long> crimesByType = reports.stream()
                .collect(Collectors.groupingBy(
                    report -> report.getCrimeType().name(),
                    Collectors.counting()));
        
        Map<String, Long> crimesByStatus = reports.stream()
                .collect(Collectors.groupingBy(
                    report -> report.getStatus().name(),
                    Collectors.counting()));
        
        Map<String, Long> crimesByPriority = reports.stream()
                .collect(Collectors.groupingBy(
                    report -> report.getPriority().name(),
                    Collectors.counting()));
        
        double averageRiskScore = reports.stream()
                .mapToDouble(this::calculateRiskScore)
                .average()
                .orElse(0.5);
        
        String mostCommonCrimeType = crimesByType.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse("Unknown");
        
        return CrimeMapResponse.MapStatistics.builder()
                .totalCrimes((long) reports.size())
                .resolvedCrimes(crimesByStatus.getOrDefault("RESOLVED", 0L))
                .pendingCrimes(crimesByStatus.getOrDefault("PENDING", 0L))
                .crimesByType(crimesByType)
                .crimesByStatus(crimesByStatus)
                .crimesByPriority(crimesByPriority)
                .averageRiskScore(averageRiskScore)
                .mostCommonCrimeType(mostCommonCrimeType)
                .build();
    }
    
    private CrimeMapResponse.MapStatistics generateStatisticsFromIncidents(List<LiveIncidentResponse> incidents) {
        Map<String, Long> crimesByType = incidents.stream()
                .collect(Collectors.groupingBy(
                    LiveIncidentResponse::getCrimeType,
                    Collectors.counting()));
        
        Map<String, Long> crimesByStatus = incidents.stream()
                .collect(Collectors.groupingBy(
                    LiveIncidentResponse::getStatus,
                    Collectors.counting()));
        
        Map<String, Long> crimesByPriority = incidents.stream()
                .collect(Collectors.groupingBy(
                    LiveIncidentResponse::getPriority,
                    Collectors.counting()));
        
        double averageRiskScore = incidents.stream()
                .mapToDouble(LiveIncidentResponse::getRiskScore)
                .average()
                .orElse(0.5);
        
        String mostCommonCrimeType = crimesByType.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse("Unknown");
        
        return CrimeMapResponse.MapStatistics.builder()
                .totalCrimes((long) incidents.size())
                .resolvedCrimes(crimesByStatus.getOrDefault("RESOLVED", 0L))
                .pendingCrimes(crimesByStatus.getOrDefault("PENDING", 0L))
                .crimesByType(crimesByType)
                .crimesByStatus(crimesByStatus)
                .crimesByPriority(crimesByPriority)
                .averageRiskScore(averageRiskScore)
                .mostCommonCrimeType(mostCommonCrimeType)
                .build();
    }
}
