package com.crimeprevention.crime_backend.core.dto.ai;

import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class PatternAnalysisRequest {
    
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private List<String> crimeTypes;
    private List<String> locations;
    private List<String> districts;
    private String timeRange; // daily, weekly, monthly
    private int minOccurrences = 3;
    private boolean includeGeographicPatterns = true;
    private boolean includeTemporalPatterns = true;
    private boolean includeModusOperandi = true;
}
