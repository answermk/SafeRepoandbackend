package com.crimeprevention.crime_backend.core.dto.feedback;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class FeedbackRequest {
    @NotBlank(message = "Feedback message is required")
    @Size(min = 10, max = 2000, message = "Feedback message must be between 10 and 2000 characters")
    private String message;
}

