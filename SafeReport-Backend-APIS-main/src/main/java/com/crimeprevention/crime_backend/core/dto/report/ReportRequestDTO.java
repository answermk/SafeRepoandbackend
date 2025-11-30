package com.crimeprevention.crime_backend.core.dto.report;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * DTO for creating a new crime report.
 */
@Data
public class ReportRequestDTO {

    @NotBlank(message = "Title is required")
    @Size(min = 5, max = 100, message = "Title must be between 5 and 100 characters")
    private String title;

    @NotBlank(message = "Description is required")
    @Size(min = 10, message = "Description must be at least 10 characters")
    private String description;

//    @NotBlank(message = "Location is required")
//    private String location;

    @NotBlank(message = "District is required")
    private String district;

    @NotBlank(message = "Sector is required")
    private String sector;

    @NotNull(message = "Latitude is required")
    private Double latitude;

    @NotNull(message = "Longitude is required")
    private Double longitude;

    @NotNull(message = "Urgency is required")
    private Boolean urgent;
}
