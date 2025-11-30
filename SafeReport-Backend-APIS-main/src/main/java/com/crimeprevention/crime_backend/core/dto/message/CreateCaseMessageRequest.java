package com.crimeprevention.crime_backend.core.dto.message;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.UUID;

@Data
public class CreateCaseMessageRequest {
    @NotNull(message = "Report ID is required")
    private UUID reportId;
    
    @NotBlank(message = "Message content cannot be empty")
    private String content;
} 