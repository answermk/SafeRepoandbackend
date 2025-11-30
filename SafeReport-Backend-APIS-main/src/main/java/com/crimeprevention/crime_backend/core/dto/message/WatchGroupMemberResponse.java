package com.crimeprevention.crime_backend.core.dto.message;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WatchGroupMemberResponse {
    private UUID id;
    private UUID userId;
    private String userName;
    private String userEmail;
    private UUID groupId;
    private String groupName;
    private Instant joinedAt;
    
    @JsonProperty("isAdmin")
    private boolean isAdmin;
    
    private Instant createdAt;
    private Instant updatedAt;
} 