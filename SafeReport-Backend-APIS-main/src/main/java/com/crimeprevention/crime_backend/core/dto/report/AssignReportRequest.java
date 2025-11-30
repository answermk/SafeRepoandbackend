package com.crimeprevention.crime_backend.core.dto.report;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.UUID;

@Data
public class AssignReportRequest {
    
    @NotNull(message = "Officer ID is required")
    private UUID officerId;
    
    private String assignmentNotes;
    
    private String priority;
} 