package com.crimeprevention.crime_backend.core.dto.report;

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

    @NotNull(message = "Location is required")
    private UUID locationId;

    @NotNull(message = "Crime type is required")
    private UUID crimeTypeId;

    private UUID weatherConditionId;
    private String crimeRelationship;
    private String witnessInfo;
    private boolean isAnonymous;
}