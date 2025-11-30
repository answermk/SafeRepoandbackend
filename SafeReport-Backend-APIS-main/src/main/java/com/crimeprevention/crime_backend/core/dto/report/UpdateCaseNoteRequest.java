package com.crimeprevention.crime_backend.core.dto.report;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * DTO for updating an existing case note.
 */
@Data
public class UpdateCaseNoteRequest {
    
    @NotBlank(message = "Note content is required")
    private String note;
}

