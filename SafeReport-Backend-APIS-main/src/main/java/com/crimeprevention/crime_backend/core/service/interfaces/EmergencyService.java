package com.crimeprevention.crime_backend.core.service.interfaces;

import com.crimeprevention.crime_backend.core.dto.emergency.EmergencyRequest;
import com.crimeprevention.crime_backend.core.dto.emergency.EmergencyResponse;

import java.util.UUID;

public interface EmergencyService {
    /**
     * Create an emergency request
     * @param userId User requesting emergency
     * @param request Emergency request details
     * @return Emergency response with ETA
     */
    EmergencyResponse createEmergencyRequest(UUID userId, EmergencyRequest request);
    
    /**
     * Get police ETA for a location
     * @param latitude Emergency location latitude
     * @param longitude Emergency location longitude
     * @return ETA in minutes (min and max range)
     */
    EmergencyResponse getPoliceETA(Double latitude, Double longitude);
    
    /**
     * Get emergency status
     * @param emergencyId Emergency request ID
     * @return Current emergency status and ETA
     */
    EmergencyResponse getEmergencyStatus(UUID emergencyId);
}

