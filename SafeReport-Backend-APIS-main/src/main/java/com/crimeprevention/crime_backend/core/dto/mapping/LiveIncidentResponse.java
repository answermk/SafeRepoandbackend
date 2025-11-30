package com.crimeprevention.crime_backend.core.dto.mapping;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LiveIncidentResponse {
    
    private String incidentId;
    private String title;
    private String description;
    private String crimeType;
    private String status;
    private String priority;
    private Double latitude;
    private Double longitude;
    private String location;
    private LocalDateTime reportedAt;
    private LocalDateTime lastUpdated;
    private String reporterName;
    private Boolean isAnonymous;
    private Double riskScore;
    private List<String> tags;
    private Map<String, Object> metadata;
    
    // Real-time updates
    private String updateType; // "NEW", "UPDATED", "RESOLVED"
    private String updateMessage;
    private LocalDateTime updateTimestamp;
    
    // Officer assignment info
    private String assignedOfficerId;
    private String assignedOfficerName;
    private String assignmentStatus;
    
    // Evidence and media
    private List<String> mediaUrls;
    private Integer evidenceCount;
    private String evidenceStatus;
}
