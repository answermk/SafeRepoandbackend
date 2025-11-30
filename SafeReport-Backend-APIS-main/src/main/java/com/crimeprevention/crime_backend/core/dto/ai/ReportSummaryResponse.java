package com.crimeprevention.crime_backend.core.dto.ai;

import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ReportSummaryResponse {
    
    private String summaryId;
    private String originalReportId;
    private String summary;
    private String keyPoints;
    private String urgency;
    private String priority;
    private List<String> tags;
    private String aiServiceUsed;
    private LocalDateTime generatedAt;
    private double confidence;
    private String language;
    
    // Metadata about the summary generation
    private int wordCount;
    private int processingTimeMs;
    private String modelVersion;
    private String promptUsed;
}
