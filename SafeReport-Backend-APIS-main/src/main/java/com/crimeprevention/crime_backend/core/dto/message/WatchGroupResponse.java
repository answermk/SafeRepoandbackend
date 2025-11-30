package com.crimeprevention.crime_backend.core.dto.message;

import com.fasterxml.jackson.annotation.JsonProperty;
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
public class WatchGroupResponse {
    private UUID id;
    private String name;
    private String description;
    private UUID createdBy;
    private String creatorName;
    private UUID assignedOfficerId;
    private String assignedOfficerName;
    private String status; // PENDING, APPROVED, REJECTED, ACTIVE
    private Instant createdAt;
    private Instant updatedAt;
    private List<WatchGroupMemberResponse> members;
    private int memberCount;
    
    // Location information
    private LocationInfo location;
    
    @JsonProperty("isMember")
    private boolean isMember;
    
    @JsonProperty("isAdmin")
    private boolean isAdmin;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class LocationInfo {
        private UUID id;
        private String address;
        private Double latitude;
        private Double longitude;
        private String district;
        private String sector;
        private String zone;
    }
} 