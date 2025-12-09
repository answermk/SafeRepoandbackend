package com.crimeprevention.crime_backend.core.dto.report;

import com.crimeprevention.crime_backend.core.model.enums.CrimeType;
import com.crimeprevention.crime_backend.core.model.enums.Priority;
import com.crimeprevention.crime_backend.core.model.enums.ReportStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReportResponse {
    private UUID id;
    private String reportNumber;
    private String title;
    private String description;
    private CrimeType crimeType;
    private LocationDTO location;
    private String weatherCondition;
    private Priority priority;
    private Instant date;
    private Instant submittedAt;
    private ReportStatus status;
    private List<EvidenceFileDTO> evidence;
    private ReporterDTO reporter;
    private String crimeRelationship;
    private String witnessInfo;
    private boolean isAnonymous;
    private Instant createdAt;
    private Instant updatedAt;

    public String getReporterName() {
        return reporter != null ? reporter.getFullName() : null;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class LocationDTO {
        private double latitude;
        private double longitude;
        private String address;
        private String city;
        private String state;
        private String zipCode;
        private String area;
        private String district;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class EvidenceFileDTO {
        private UUID id;
        private String fileName;
        private String fileType;
        private String fileUrl;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ReporterDTO {
        private UUID id;
        private String fullName;
        private String email;
        private String phoneNumber;
    }
}
