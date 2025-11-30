package com.crimeprevention.crime_backend.core.dto.report;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.UUID;

/**
 * DTO for case note response.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CaseNoteResponse {
    
    private UUID id;
    private String note;
    private UUID reportId;
    private OfficerInfo officer;
    private Instant createdAt;
    private Instant updatedAt;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class OfficerInfo {
        private UUID id;
        private String fullName;
        private String email;
    }
}

