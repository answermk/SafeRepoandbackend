package com.crimeprevention.crime_backend.core.dto.message;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class UpdateCaseMessageRequest {
    @NotBlank(message = "Message content cannot be empty")
    private String content;
} 