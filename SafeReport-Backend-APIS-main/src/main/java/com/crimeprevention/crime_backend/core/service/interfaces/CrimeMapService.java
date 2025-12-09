package com.crimeprevention.crime_backend.core.service.interfaces;

import com.crimeprevention.crime_backend.core.dto.mapping.CrimeMapRequest;
import com.crimeprevention.crime_backend.core.dto.mapping.CrimeMapResponse;
import com.crimeprevention.crime_backend.core.dto.mapping.LiveIncidentResponse;

import java.util.List;

public interface CrimeMapService {
    
    /**
     * Generate crime map data for visualization
     */
    CrimeMapResponse generateCrimeMap(CrimeMapRequest request);
    
    /**
     * Get crime heatmap data for specific area
     */
    CrimeMapResponse getCrimeHeatmap(CrimeMapRequest request);
    
    /**
     * Get crime clusters for geographic analysis
     */
    CrimeMapResponse getCrimeClusters(CrimeMapRequest request);
    
    /**
     * Get individual crime points for map plotting
     */
    CrimeMapResponse getCrimePoints(CrimeMapRequest request);
    
    /**
     * Get live incidents for real-time mapping
     */
    List<LiveIncidentResponse> getLiveIncidents();
    
    /**
     * Get live incidents within specific area
     */
    List<LiveIncidentResponse> getLiveIncidentsInArea(
            Double latitude, 
            Double longitude, 
            Double radiusKm,
            String timeRange);
    
    /**
     * Get crime statistics for specific geographic area
     */
    CrimeMapResponse.MapStatistics getAreaStatistics(
            Double latitude, 
            Double longitude, 
            Double radiusKm);
    
    /**
     * Get crime trends for specific location over time
     */
    CrimeMapResponse getCrimeTrends(
            String location, 
            String timeRange);
}
