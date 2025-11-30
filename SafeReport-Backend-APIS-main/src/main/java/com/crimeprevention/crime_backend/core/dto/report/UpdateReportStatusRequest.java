package com.crimeprevention.crime_backend.core.dto.report;

import com.crimeprevention.crime_backend.core.model.enums.Priority;
import com.crimeprevention.crime_backend.core.model.enums.ReportStatus;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateReportStatusRequest {
    @NotNull(message = "Status is required")
    private ReportStatus status;
    
    // Optional priority field - if provided, will update the report priority
    private Priority priority;
}