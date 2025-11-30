package com.crimeprevention.crime_backend.core.dto.ai;

import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.Builder;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class UpdateSummaryRequest {
    
    @NotBlank(message = "Summary text is required")
    private String summary;
    
    private String keyPoints;
    
    @NotNull(message = "Urgency level is required")
    private UrgencyLevel urgencyLevel;
    
    @NotNull(message = "Priority level is required")
    private PriorityLevel priorityLevel;
    
    private List<String> tags;
    
    private String notes; // Additional notes from officers
    
    private String updateReason; // Reason for the update
    
    public enum UrgencyLevel {
        LOW, MEDIUM, HIGH, CRITICAL
    }
    
    public enum PriorityLevel {
        LOW, MEDIUM, HIGH, URGENT
    }
}
