package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.model.enums.ReportStatus;
import com.crimeprevention.crime_backend.core.model.report.Report;
import com.crimeprevention.crime_backend.core.repo.report.ReportRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.CommunityService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class CommunityServiceImpl implements CommunityService {

    private final ReportRepository reportRepository;

    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getCommunityStatus(Double latitude, Double longitude, Double radiusKm) {
        log.info("Calculating community status for location: lat={}, lng={}, radius={}km", latitude, longitude, radiusKm);
        
        // Get all reports (we'll filter by location in memory for now)
        // In production, use a spatial query or PostGIS
        List<Report> allReports = reportRepository.findAll();
        
        // Filter reports within radius
        List<Report> nearbyReports = allReports.stream()
            .filter(report -> {
                if (report.getLocation() == null || 
                    report.getLocation().getLatitude() == null || 
                    report.getLocation().getLongitude() == null) {
                    return false;
                }
                double distance = calculateDistance(
                    latitude, longitude,
                    report.getLocation().getLatitude(),
                    report.getLocation().getLongitude()
                );
                return distance <= radiusKm;
            })
            .toList();
        
        // Calculate this week's reports
        Instant weekAgo = Instant.now().minus(7, ChronoUnit.DAYS);
        long thisWeekReports = nearbyReports.stream()
            .filter(report -> report.getCreatedAt() != null && report.getCreatedAt().isAfter(weekAgo))
            .count();
        
        // Calculate average response time (time from submission to status update)
        // For resolved reports, calculate time from submittedAt to updatedAt
        double avgResponseTimeMinutes = nearbyReports.stream()
            .filter(report -> report.getStatus() == ReportStatus.RESOLVED && 
                            report.getSubmittedAt() != null && 
                            report.getUpdatedAt() != null)
            .mapToLong(report -> {
                long minutes = ChronoUnit.MINUTES.between(
                    report.getSubmittedAt(),
                    report.getUpdatedAt()
                );
                return minutes > 0 ? minutes : 0;
            })
            .average()
            .orElse(0.0);
        
        // If no resolved reports, use a default or calculate from pending reports
        if (avgResponseTimeMinutes == 0.0 && !nearbyReports.isEmpty()) {
            // Estimate based on current time - submission time for pending reports
            avgResponseTimeMinutes = nearbyReports.stream()
                .filter(report -> report.getStatus() == ReportStatus.PENDING && 
                                report.getSubmittedAt() != null)
                .mapToLong(report -> ChronoUnit.MINUTES.between(
                    report.getSubmittedAt(),
                    Instant.now()
                ))
                .average()
                .orElse(15.0); // Default 15 minutes if no data
        }
        
        // Calculate safety level based on:
        // - Crime density (reports per km²)
        // - Average risk score (if available)
        // - Recent trend (increasing/decreasing)
        String safetyLevel = calculateSafetyLevel(nearbyReports, thisWeekReports, radiusKm);
        
        Map<String, Object> result = new HashMap<>();
        result.put("thisWeekReports", thisWeekReports);
        result.put("avgResponseTimeMinutes", Math.round(avgResponseTimeMinutes));
        result.put("avgResponse", formatResponseTime(avgResponseTimeMinutes));
        result.put("safetyLevel", safetyLevel);
        result.put("totalReports", (long) nearbyReports.size());
        result.put("resolvedReports", nearbyReports.stream()
            .filter(r -> r.getStatus() == ReportStatus.RESOLVED)
            .count());
        result.put("pendingReports", nearbyReports.stream()
            .filter(r -> r.getStatus() == ReportStatus.PENDING)
            .count());
        
        return result;
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getTopActiveAreas(Double latitude, Double longitude, Double radiusKm, int limit) {
        log.info("Getting top active areas for location: lat={}, lng={}, radius={}km, limit={}", latitude, longitude, radiusKm, limit);
        
        // Get all reports
        List<Report> allReports = reportRepository.findAll();
        
        // Filter reports within radius
        List<Report> nearbyReports = allReports.stream()
            .filter(report -> {
                if (report.getLocation() == null || 
                    report.getLocation().getLatitude() == null || 
                    report.getLocation().getLongitude() == null) {
                    return false;
                }
                double distance = calculateDistance(
                    latitude, longitude,
                    report.getLocation().getLatitude(),
                    report.getLocation().getLongitude()
                );
                return distance <= radiusKm;
            })
            .toList();
        
        // Group reports by area (prefer district, then area, then address)
        Map<String, List<Report>> areaGroups = nearbyReports.stream()
            .collect(Collectors.groupingBy(report -> {
                Report.Location loc = report.getLocation();
                if (loc == null) return "Unknown";
                
                // Prefer district, then area, then address
                if (loc.getDistrict() != null && !loc.getDistrict().trim().isEmpty()) {
                    return loc.getDistrict();
                } else if (loc.getArea() != null && !loc.getArea().trim().isEmpty()) {
                    return loc.getArea();
                } else if (loc.getAddress() != null && !loc.getAddress().trim().isEmpty()) {
                    // Extract area name from address (first part before comma)
                    String address = loc.getAddress();
                    int commaIndex = address.indexOf(',');
                    return commaIndex > 0 ? address.substring(0, commaIndex).trim() : address;
                } else {
                    return "Unknown";
                }
            }));
        
        // Calculate current week and previous week for trend
        Instant now = Instant.now();
        Instant weekAgo = now.minus(7, ChronoUnit.DAYS);
        Instant twoWeeksAgo = now.minus(14, ChronoUnit.DAYS);
        
        // Create area statistics
        List<Map<String, Object>> areaStats = new ArrayList<>();
        
        for (Map.Entry<String, List<Report>> entry : areaGroups.entrySet()) {
            String areaName = entry.getKey();
            List<Report> areaReports = entry.getValue();
            
            // Count reports in current week
            long currentWeekCount = areaReports.stream()
                .filter(r -> r.getCreatedAt() != null && r.getCreatedAt().isAfter(weekAgo))
                .count();
            
            // Count reports in previous week
            long previousWeekCount = areaReports.stream()
                .filter(r -> r.getCreatedAt() != null && 
                           r.getCreatedAt().isAfter(twoWeeksAgo) && 
                           r.getCreatedAt().isBefore(weekAgo))
                .count();
            
            // Determine trend
            String trend = "stable";
            if (currentWeekCount > previousWeekCount) {
                trend = "up";
            } else if (currentWeekCount < previousWeekCount) {
                trend = "down";
            }
            
            Map<String, Object> areaData = new HashMap<>();
            areaData.put("name", areaName);
            areaData.put("count", (long) areaReports.size());
            areaData.put("currentWeekCount", currentWeekCount);
            areaData.put("trend", trend);
            
            areaStats.add(areaData);
        }
        
        // Sort by count (descending) and limit
        return areaStats.stream()
            .sorted((a, b) -> Long.compare((Long) b.get("count"), (Long) a.get("count")))
            .limit(limit)
            .collect(Collectors.toList());
    }
    
    /**
     * Calculate distance between two coordinates using Haversine formula
     * Returns distance in kilometers
     */
    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371; // Earth's radius in kilometers
        
        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        
        return R * c;
    }
    
    /**
     * Calculate safety level based on crime statistics
     */
    private String calculateSafetyLevel(List<Report> reports, long thisWeekReports, double radiusKm) {
        if (reports.isEmpty()) {
            return "Excellent";
        }
        
        // Calculate crime density (reports per km²)
        double areaKm2 = Math.PI * radiusKm * radiusKm;
        double crimeDensity = reports.size() / areaKm2;
        double weeklyDensity = thisWeekReports / areaKm2;
        
        // Safety level thresholds
        if (weeklyDensity < 0.5 && crimeDensity < 2.0) {
            return "Excellent";
        } else if (weeklyDensity < 1.0 && crimeDensity < 5.0) {
            return "Good";
        } else if (weeklyDensity < 2.0 && crimeDensity < 10.0) {
            return "Moderate";
        } else if (weeklyDensity < 4.0 && crimeDensity < 20.0) {
            return "Caution";
        } else {
            return "High Risk";
        }
    }
    
    /**
     * Format response time in a human-readable format
     */
    private String formatResponseTime(double minutes) {
        if (minutes < 1) {
            return "< 1 minute";
        } else if (minutes < 60) {
            return String.format("%.0f minutes", minutes);
        } else {
            long hours = (long) (minutes / 60);
            long mins = (long) (minutes % 60);
            if (mins == 0) {
                return hours + (hours == 1 ? " hour" : " hours");
            } else {
                return hours + (hours == 1 ? " hour" : " hours") + " " + mins + " min";
            }
        }
    }
}

