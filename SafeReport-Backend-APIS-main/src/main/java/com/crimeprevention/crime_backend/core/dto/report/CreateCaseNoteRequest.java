package com.crimeprevention.crime_backend.core.dto.report;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * DTO for creating a new case note.
 * Note: reportId and officerId are set by the controller from path variable and authentication.
 */
@Data
public class CreateCaseNoteRequest {
    
    @NotBlank(message = "Note content is required")
    private String note;
    
    // These fields are set by the controller, not required in request body
    private java.util.UUID reportId;
    private java.util.UUID officerId;
}

