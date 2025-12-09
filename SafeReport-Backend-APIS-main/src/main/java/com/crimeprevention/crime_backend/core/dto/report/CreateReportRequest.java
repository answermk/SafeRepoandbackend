package com.crimeprevention.crime_backend.core.dto.report;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateReportRequest {
    @NotBlank(message = "Title is required")
    private String title;

    @NotBlank(message = "Description is required")
    private String description;

    // Location can be provided either as ID or as coordinates
    private UUID locationId;
    
    // Direct location coordinates (alternative to locationId)
    private Double latitude;
    private Double longitude;
    private String address;
    private String city;
    private String state;
    private String zipCode;
    private String area;
    private String district;

    // Crime type can be provided either as ID or as enum
    private UUID crimeTypeId;
    private String crimeType; // Alternative to crimeTypeId

    private UUID weatherConditionId;
    private String crimeRelationship;
    private String witnessInfo;
    
    @JsonProperty("isAnonymous")
    private boolean isAnonymous;
}