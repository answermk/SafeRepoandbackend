package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.model.location.Location;
import com.crimeprevention.crime_backend.core.repo.location.LocationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/locations")
@RequiredArgsConstructor
@Slf4j
public class LocationController {

    private final LocationRepository locationRepository;

    @GetMapping
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<List<Location>> getAllLocations() {
        List<Location> locations = locationRepository.findAll();
        return ResponseEntity.ok(locations);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<Location> getLocationById(@PathVariable String id) {
        Location location = locationRepository.findById(java.util.UUID.fromString(id))
                .orElse(null);
        if (location == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(location);
    }

    /**
     * Reverse geocoding endpoint that proxies Nominatim API to avoid CORS issues
     */
    @GetMapping("/reverse-geocode")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'OFFICER', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<Map<String, Object>> reverseGeocode(
            @RequestParam Double lat,
            @RequestParam Double lon) {
        try {
            // Use Nominatim API for reverse geocoding
            String nominatimUrl = String.format(
                    "https://nominatim.openstreetmap.org/reverse?format=json&lat=%.6f&lon=%.6f&zoom=18&addressdetails=1",
                    lat, lon
            );

            HttpClient client = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(10))
                    .build();

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(nominatimUrl))
                    .header("User-Agent", "CrimePreventionApp/1.0") // Required by Nominatim usage policy
                    .timeout(Duration.ofSeconds(10))
                    .GET()
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200) {
                // Parse JSON response
                com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
                Map<String, Object> result = mapper.readValue(response.body(), Map.class);
                return ResponseEntity.ok(result);
            } else {
                log.warn("Nominatim API returned status code: {}", response.statusCode());
                return ResponseEntity.status(response.statusCode()).build();
            }
        } catch (Exception e) {
            log.error("Error calling Nominatim API: {}", e.getMessage(), e);
            return ResponseEntity.status(500).build();
        }
    }
} 