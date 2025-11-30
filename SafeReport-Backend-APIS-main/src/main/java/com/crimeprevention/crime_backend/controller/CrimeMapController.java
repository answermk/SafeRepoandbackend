package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.dto.mapping.*;
import com.crimeprevention.crime_backend.core.service.interfaces.CrimeMapService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/api/maps")
@RequiredArgsConstructor
@Slf4j
public class CrimeMapController {
    
    private final CrimeMapService crimeMapService;
    
    /**
     * Generate comprehensive crime map data
     */
    @PostMapping("/generate")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<CrimeMapResponse> generateCrimeMap(@Valid @RequestBody CrimeMapRequest request) {
        log.info("Generating crime map for request: {}", request);
        
        try {
            CrimeMapResponse response = crimeMapService.generateCrimeMap(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error generating crime map", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get crime heatmap data
     */
    @PostMapping("/heatmap")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<CrimeMapResponse> getCrimeHeatmap(@Valid @RequestBody CrimeMapRequest request) {
        log.info("Generating crime heatmap for request: {}", request);
        
        try {
            CrimeMapResponse response = crimeMapService.getCrimeHeatmap(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error generating crime heatmap", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get crime clusters for geographic analysis
     */
    @PostMapping("/clusters")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<CrimeMapResponse> getCrimeClusters(@Valid @RequestBody CrimeMapRequest request) {
        log.info("Generating crime clusters for request: {}", request);
        
        try {
            CrimeMapResponse response = crimeMapService.getCrimeClusters(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error generating crime clusters", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get individual crime points for map plotting
     */
    @PostMapping("/points")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<CrimeMapResponse> getCrimePoints(@Valid @RequestBody CrimeMapRequest request) {
        log.info("Generating crime points for request: {}", request);
        
        try {
            CrimeMapResponse response = crimeMapService.getCrimePoints(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error generating crime points", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get live incidents for real-time mapping
     */
    @GetMapping("/live-incidents")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<List<LiveIncidentResponse>> getLiveIncidents() {
        log.info("Fetching live incidents for real-time mapping");
        
        try {
            List<LiveIncidentResponse> incidents = crimeMapService.getLiveIncidents();
            return ResponseEntity.ok(incidents);
        } catch (Exception e) {
            log.error("Error fetching live incidents", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get live incidents within specific geographic area
     */
    @GetMapping("/live-incidents/area")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<List<LiveIncidentResponse>> getLiveIncidentsInArea(
            @RequestParam Double latitude,
            @RequestParam Double longitude,
            @RequestParam Double radiusKm) {
        
        log.info("Fetching live incidents in area: lat={}, lng={}, radius={}km", latitude, longitude, radiusKm);
        
        try {
            List<LiveIncidentResponse> incidents = crimeMapService.getLiveIncidentsInArea(latitude, longitude, radiusKm);
            return ResponseEntity.ok(incidents);
        } catch (Exception e) {
            log.error("Error fetching live incidents in area", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get crime statistics for specific geographic area
     */
    @GetMapping("/statistics/area")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<CrimeMapResponse.MapStatistics> getAreaStatistics(
            @RequestParam Double latitude,
            @RequestParam Double longitude,
            @RequestParam Double radiusKm) {
        
        log.info("Generating area statistics: lat={}, lng={}, radius={}km", latitude, longitude, radiusKm);
        
        try {
            CrimeMapResponse.MapStatistics statistics = crimeMapService.getAreaStatistics(latitude, longitude, radiusKm);
            return ResponseEntity.ok(statistics);
        } catch (Exception e) {
            log.error("Error generating area statistics", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get crime trends for specific location over time
     */
    @GetMapping("/trends")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<CrimeMapResponse> getCrimeTrends(
            @RequestParam String location,
            @RequestParam(defaultValue = "7d") String timeRange) {
        
        log.info("Generating crime trends for location: {}, timeRange: {}", location, timeRange);
        
        try {
            CrimeMapResponse response = crimeMapService.getCrimeTrends(location, timeRange);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error generating crime trends", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Quick crime map for common time ranges
     */
    @GetMapping("/quick/{timeRange}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<CrimeMapResponse> getQuickCrimeMap(
            @PathVariable String timeRange,
            @RequestParam(defaultValue = "heatmap") String mapType,
            @RequestParam(defaultValue = "100") Integer maxPoints) {
        
        log.info("Generating quick crime map: timeRange={}, mapType={}, maxPoints={}", timeRange, mapType, maxPoints);
        
        try {
            CrimeMapRequest request = CrimeMapRequest.builder()
                    .timeRange(timeRange)
                    .mapType(mapType)
                    .maxPoints(maxPoints)
                    .build();
            
            CrimeMapResponse response = crimeMapService.generateCrimeMap(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error generating quick crime map", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get crime map for specific crime type
     */
    @GetMapping("/crime-type/{crimeType}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<CrimeMapResponse> getCrimeMapByType(
            @PathVariable String crimeType,
            @RequestParam(defaultValue = "7d") String timeRange,
            @RequestParam(defaultValue = "heatmap") String mapType) {
        
        log.info("Generating crime map by type: crimeType={}, timeRange={}, mapType={}", crimeType, timeRange, mapType);
        
        try {
            CrimeMapRequest request = CrimeMapRequest.builder()
                    .timeRange(timeRange)
                    .mapType(mapType)
                    .crimeTypes(List.of(crimeType))
                    .build();
            
            CrimeMapResponse response = crimeMapService.generateCrimeMap(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error generating crime map by type", e);
            return ResponseEntity.internalServerError().build();
        }
    }
}
