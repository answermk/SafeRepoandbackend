package com.crimeprevention.crime_backend.core.dto.report;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateReportRequest {
    private String title;
    private String description;
    private String crimeRelationship;
    private String witnessInfo;
    private boolean isAnonymous;
}
