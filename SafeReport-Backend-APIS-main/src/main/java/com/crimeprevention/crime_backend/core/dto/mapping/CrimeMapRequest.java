package com.crimeprevention.crime_backend.core.dto.mapping;

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
public class CrimeMapRequest {
    
    private String timeRange; // "24h", "7d", "30d", "custom"
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private List<String> crimeTypes; // Optional: filter by crime types
    private List<String> locations; // Optional: filter by locations
    private Double latitude; // Optional: center point for map
    private Double longitude; // Optional: center point for map
    private Double radiusKm; // Optional: radius for area analysis
    private String mapType; // "heatmap", "clusters", "individual"
    private Integer maxPoints; // Maximum number of points to return
    private Boolean includeDetails; // Whether to include full crime details
}
