package com.crimeprevention.crime_backend.core.dto.message;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.UUID;

@Data
public class CreateWatchGroupRequest {
    @NotBlank(message = "Group name is required")
    private String name;
    
    private String description;
    
    @NotNull(message = "Location ID is required")
    private UUID locationId;
    
    private UUID assignedOfficerId; // optional, can be assigned later
} 