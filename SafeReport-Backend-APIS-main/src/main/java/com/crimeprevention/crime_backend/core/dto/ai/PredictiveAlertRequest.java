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
public class PredictiveAlertRequest {
    
    private LocalDateTime predictionDate;
    private List<String> targetLocations;
    private List<String> crimeTypes;
    private int predictionHorizon = 7; // days
    private double confidenceThreshold = 0.7;
    private boolean includeHistoricalData = true;
    private boolean includeWeatherData = true;
    private boolean includeEventData = true;
}
