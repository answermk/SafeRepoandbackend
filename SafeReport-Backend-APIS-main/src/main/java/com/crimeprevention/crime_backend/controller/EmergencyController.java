package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.dto.emergency.EmergencyRequest;
import com.crimeprevention.crime_backend.core.dto.emergency.EmergencyResponse;
import com.crimeprevention.crime_backend.core.service.interfaces.EmergencyService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/emergency")
@RequiredArgsConstructor
@Slf4j
public class EmergencyController {

    private final EmergencyService emergencyService;

    /**
     * Create an emergency request
     */
    @PostMapping("/request")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<EmergencyResponse> createEmergencyRequest(
            @Valid @RequestBody EmergencyRequest request,
            Authentication authentication) {
        
        log.info("Emergency request received from user: {}", authentication.getName());
        
        try {
            UUID userId = UUID.fromString(authentication.getName());
            EmergencyResponse response = emergencyService.createEmergencyRequest(userId, request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            log.error("Error creating emergency request", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get police ETA for a location
     */
    @GetMapping("/eta")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<EmergencyResponse> getPoliceETA(
            @RequestParam Double latitude,
            @RequestParam Double longitude) {
        
        log.info("Getting police ETA for location: lat={}, lng={}", latitude, longitude);
        
        try {
            EmergencyResponse response = emergencyService.getPoliceETA(latitude, longitude);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting police ETA", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get emergency status
     */
    @GetMapping("/{emergencyId}/status")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<EmergencyResponse> getEmergencyStatus(
            @PathVariable UUID emergencyId) {
        
        log.info("Getting emergency status for: {}", emergencyId);
        
        try {
            EmergencyResponse response = emergencyService.getEmergencyStatus(emergencyId);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting emergency status", e);
            return ResponseEntity.internalServerError().build();
        }
    }
}

