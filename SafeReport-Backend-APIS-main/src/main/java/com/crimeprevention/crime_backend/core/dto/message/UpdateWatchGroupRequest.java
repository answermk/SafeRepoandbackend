package com.crimeprevention.crime_backend.core.dto.message;

import lombok.Data;

@Data
public class UpdateWatchGroupRequest {
    private String name;
    private String description;
} 