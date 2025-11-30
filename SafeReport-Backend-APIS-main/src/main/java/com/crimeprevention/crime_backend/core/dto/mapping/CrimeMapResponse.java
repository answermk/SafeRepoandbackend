package com.crimeprevention.crime_backend.core.dto.mapping;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CrimeMapResponse {
    
    private String mapId;
    private String mapType;
    private LocalDateTime generatedAt;
    private Long totalCrimes;
    private Long processingTimeMs;
    
    // GeoJSON Feature Collection
    private List<CrimeFeature> features;
    
    // Heatmap data (for heatmap visualization)
    private List<HeatmapPoint> heatmapData;
    
    // Clustering data (for cluster visualization)
    private List<CrimeCluster> clusters;
    
    // Statistics for the mapped area
    private MapStatistics statistics;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CrimeFeature {
        private String type = "Feature";
        private CrimeGeometry geometry;
        private CrimeProperties properties;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CrimeGeometry {
        private String type = "Point";
        private List<Double> coordinates; // [longitude, latitude]
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CrimeProperties {
        private String crimeId;
        private String title;
        private String crimeType;
        private String status;
        private String priority;
        private LocalDateTime crimeDate;
        private String location;
        private Double riskScore;
        private Map<String, Object> additionalData;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class HeatmapPoint {
        private Double latitude;
        private Double longitude;
        private Double weight; // Crime intensity/weight
        private String crimeType;
        private Integer crimeCount;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CrimeCluster {
        private String clusterId;
        private Double latitude;
        private Double longitude;
        private Integer crimeCount;
        private List<String> crimeTypes;
        private Double averageRiskScore;
        private LocalDateTime firstCrime;
        private LocalDateTime lastCrime;
        private List<CrimeProperties> sampleCrimes; // Sample crimes in cluster
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MapStatistics {
        private Long totalCrimes;
        private Long resolvedCrimes;
        private Long pendingCrimes;
        private Map<String, Long> crimesByType;
        private Map<String, Long> crimesByStatus;
        private Map<String, Long> crimesByPriority;
        private Double averageRiskScore;
        private String highestRiskArea;
        private String mostCommonCrimeType;
        private LocalDateTime crimePeakTime;
    }
}
