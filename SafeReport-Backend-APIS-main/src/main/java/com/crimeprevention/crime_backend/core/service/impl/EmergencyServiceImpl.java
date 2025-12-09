package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.dto.emergency.EmergencyRequest;
import com.crimeprevention.crime_backend.core.dto.emergency.EmergencyResponse;
import com.crimeprevention.crime_backend.core.model.enums.CrimeType;
import com.crimeprevention.crime_backend.core.model.enums.DutyStatus;
import com.crimeprevention.crime_backend.core.model.enums.Priority;
import com.crimeprevention.crime_backend.core.model.enums.ReportStatus;
import com.crimeprevention.crime_backend.core.model.report.Report;
import com.crimeprevention.crime_backend.core.model.user.Officer;
import com.crimeprevention.crime_backend.core.repo.report.ReportRepository;
import com.crimeprevention.crime_backend.core.repo.user.OfficerRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.EmergencyService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmergencyServiceImpl implements EmergencyService {

    private final ReportRepository reportRepository;
    private final OfficerRepository officerRepository;
    
    // Average police vehicle speed in km/h (urban area)
    private static final double AVERAGE_POLICE_SPEED_KMH = 40.0;
    
    @Override
    @Transactional
    public EmergencyResponse createEmergencyRequest(UUID userId, EmergencyRequest request) {
        log.info("Creating emergency request for user: {}, location: lat={}, lng={}", userId, request.getLatitude(), request.getLongitude());
        
        // Create emergency report
        Report.Location location = Report.Location.builder()
            .latitude(request.getLatitude())
            .longitude(request.getLongitude())
            .address(request.getAddress())
            .build();
        
        String title = "EMERGENCY: " + (request.getEmergencyType() != null ? request.getEmergencyType() : "General Emergency");
        
        Report emergencyReport = Report.builder()
            .reportNumber(generateReportNumber())
            .title(title)
            .description(request.getDescription() != null ? request.getDescription() : "Emergency assistance requested")
            .location(location)
            .crimeType(CrimeType.OTHER)
            .priority(Priority.URGENT)
            .reporterId(userId)
            .status(ReportStatus.PENDING)
            .isAnonymous(false)
            .submittedAt(Instant.now())
            .date(Instant.now())
            .build();
        
        emergencyReport = reportRepository.save(emergencyReport);
        
        // Calculate ETA
        EmergencyResponse etaResponse = calculatePoliceETA(request.getLatitude(), request.getLongitude());
        
        // Try to assign nearest available officer
        Officer nearestOfficer = findNearestAvailableOfficer(request.getLatitude(), request.getLongitude());
        
        EmergencyResponse response = EmergencyResponse.builder()
            .emergencyId(emergencyReport.getId())
            .etaMinutes(etaResponse.getEtaMinutes())
            .etaMin(etaResponse.getEtaMin())
            .etaMax(etaResponse.getEtaMax())
            .status("DISPATCHED")
            .message("Emergency request received. Help is on the way.")
            .assignedOfficerId(nearestOfficer != null ? nearestOfficer.getId() : null)
            .assignedOfficerName(nearestOfficer != null ? nearestOfficer.getFullName() : null)
            .build();
        
        log.info("Emergency request created: {}, ETA: {} minutes", emergencyReport.getId(), response.getEtaMinutes());
        
        return response;
    }

    private String generateReportNumber() {
        String datePart = LocalDate.now(ZoneOffset.UTC).format(DateTimeFormatter.BASIC_ISO_DATE); // YYYYMMDD
        long suffix = Math.abs(System.currentTimeMillis() % 1_000_000);
        String suffixStr = String.format("%06d", suffix);
        return "SR" + datePart + suffixStr;
    }
    
    @Override
    @Transactional(readOnly = true)
    public EmergencyResponse getPoliceETA(Double latitude, Double longitude) {
        log.info("Calculating police ETA for location: lat={}, lng={}", latitude, longitude);
        return calculatePoliceETA(latitude, longitude);
    }
    
    @Override
    @Transactional(readOnly = true)
    public EmergencyResponse getEmergencyStatus(UUID emergencyId) {
        log.info("Getting emergency status for: {}", emergencyId);
        
        Report report = reportRepository.findById(emergencyId)
            .orElseThrow(() -> new RuntimeException("Emergency request not found"));
        
        // Recalculate ETA based on current status
        EmergencyResponse etaResponse = calculatePoliceETA(
            report.getLocation().getLatitude(),
            report.getLocation().getLongitude()
        );
        
        String status = "DISPATCHED";
        if (report.getStatus() == ReportStatus.UNDER_INVESTIGATION) {
            status = "IN_PROGRESS";
        } else if (report.getStatus() == ReportStatus.RESOLVED) {
            status = "ARRIVED";
        }
        
        return EmergencyResponse.builder()
            .emergencyId(emergencyId)
            .etaMinutes(etaResponse.getEtaMinutes())
            .etaMin(etaResponse.getEtaMin())
            .etaMax(etaResponse.getEtaMax())
            .status(status)
            .message("Emergency response in progress")
            .build();
    }
    
    /**
     * Calculate police ETA based on nearest available officers
     */
    private EmergencyResponse calculatePoliceETA(Double latitude, Double longitude) {
        // Find available officers
        List<Officer> availableOfficers = officerRepository.findByDutyStatus(DutyStatus.AVAILABLE);
        
        if (availableOfficers.isEmpty()) {
            // No available officers - use default ETA
            return EmergencyResponse.builder()
                .etaMinutes(15)
                .etaMin(12)
                .etaMax(18)
                .build();
        }
        
        // Find nearest officer
        Officer nearestOfficer = findNearestAvailableOfficer(latitude, longitude);
        
        if (nearestOfficer == null || nearestOfficer.getLocation() == null ||
            nearestOfficer.getLocation().getLatitude() == null ||
            nearestOfficer.getLocation().getLongitude() == null) {
            // Officer location unknown - use default ETA
            return EmergencyResponse.builder()
                .etaMinutes(10)
                .etaMin(8)
                .etaMax(12)
                .build();
        }
        
        // Calculate distance
        double distanceKm = calculateDistance(
            latitude, longitude,
            nearestOfficer.getLocation().getLatitude(),
            nearestOfficer.getLocation().getLongitude()
        );
        
        // Calculate ETA (distance / speed * 60 minutes)
        double etaMinutes = (distanceKm / AVERAGE_POLICE_SPEED_KMH) * 60;
        
        // Add buffer for traffic and response time
        int minEta = (int) Math.max(3, Math.round(etaMinutes * 0.8)); // 20% faster (best case)
        int maxEta = (int) Math.round(etaMinutes * 1.3); // 30% slower (worst case with traffic)
        int avgEta = (int) Math.round(etaMinutes);
        
        return EmergencyResponse.builder()
            .etaMinutes(avgEta)
            .etaMin(minEta)
            .etaMax(maxEta)
            .build();
    }
    
    /**
     * Find nearest available officer to emergency location
     */
    private Officer findNearestAvailableOfficer(Double latitude, Double longitude) {
        List<Officer> availableOfficers = officerRepository.findByDutyStatus(DutyStatus.AVAILABLE);
        
        if (availableOfficers.isEmpty()) {
            return null;
        }
        
        return availableOfficers.stream()
            .filter(officer -> officer.getLocation() != null &&
                             officer.getLocation().getLatitude() != null &&
                             officer.getLocation().getLongitude() != null)
            .min(Comparator.comparingDouble(officer -> {
                double distance = calculateDistance(
                    latitude, longitude,
                    officer.getLocation().getLatitude(),
                    officer.getLocation().getLongitude()
                );
                return distance;
            }))
            .orElse(null);
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
}

