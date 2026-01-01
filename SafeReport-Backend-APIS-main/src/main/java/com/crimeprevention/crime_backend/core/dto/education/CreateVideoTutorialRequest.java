package com.crimeprevention.crime_backend.core.dto.education;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateVideoTutorialRequest {
    @NotBlank(message = "Title is required")
    private String title;
    
    private String description;
    
    private String category;
    
    private Boolean isFeatured;
    
    private Integer durationSeconds;
}

