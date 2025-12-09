package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.service.interfaces.CommunityService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/community")
@RequiredArgsConstructor
@Slf4j
public class CommunityController {

    private final CommunityService communityService;

    /**
     * Get community status based on location
     * Returns: this week's reports, average response time, and safety level
     */
    @GetMapping("/status")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<?> getCommunityStatus(
            @RequestParam Double latitude,
            @RequestParam Double longitude,
            @RequestParam(defaultValue = "5.0") Double radiusKm) {
        
        log.info("Getting community status for location: lat={}, lng={}, radius={}km", latitude, longitude, radiusKm);
        
        try {
            var status = communityService.getCommunityStatus(latitude, longitude, radiusKm);
            return ResponseEntity.ok(status);
        } catch (Exception e) {
            log.error("Error getting community status", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get top active areas based on location
     * Returns: list of top areas with report counts and trends
     */
    @GetMapping("/top-areas")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<?> getTopActiveAreas(
            @RequestParam Double latitude,
            @RequestParam Double longitude,
            @RequestParam(defaultValue = "5.0") Double radiusKm,
            @RequestParam(defaultValue = "5") Integer limit) {
        
        log.info("Getting top active areas for location: lat={}, lng={}, radius={}km, limit={}", latitude, longitude, radiusKm, limit);
        
        try {
            var areas = communityService.getTopActiveAreas(latitude, longitude, radiusKm, limit);
            return ResponseEntity.ok(areas);
        } catch (Exception e) {
            log.error("Error getting top active areas", e);
            return ResponseEntity.internalServerError().build();
        }
    }
}

