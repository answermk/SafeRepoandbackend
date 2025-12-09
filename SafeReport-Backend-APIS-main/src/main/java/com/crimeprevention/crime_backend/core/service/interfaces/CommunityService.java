package com.crimeprevention.crime_backend.core.service.interfaces;

import java.util.List;
import java.util.Map;

public interface CommunityService {
    /**
     * Get community status based on location
     * @param latitude User's latitude
     * @param longitude User's longitude
     * @param radiusKm Radius in kilometers to search for reports
     * @return Map containing thisWeekReports, avgResponseTime, safetyLevel
     */
    Map<String, Object> getCommunityStatus(Double latitude, Double longitude, Double radiusKm);
    
    /**
     * Get top active areas based on location
     * @param latitude User's latitude
     * @param longitude User's longitude
     * @param radiusKm Radius in kilometers to search for reports
     * @param limit Maximum number of areas to return
     * @return List of top active areas with name, count, and trend
     */
    List<Map<String, Object>> getTopActiveAreas(Double latitude, Double longitude, Double radiusKm, int limit);
}

