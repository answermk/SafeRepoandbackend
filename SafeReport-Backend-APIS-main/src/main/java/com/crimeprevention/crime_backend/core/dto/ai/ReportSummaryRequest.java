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
public class ReportSummaryRequest {
    
    @NotBlank(message = "Report title is required")
    private String title;
    
    @NotBlank(message = "Report description is required")
    private String description;
    
    private String crimeType;
    private String location;
    private String timestamp;
    private String reporterName;
    private List<String> additionalDetails;
    
    @NotNull(message = "Summary length preference is required")
    @Builder.Default
    private SummaryLength summaryLength = SummaryLength.MEDIUM;
    
    public enum SummaryLength {
        SHORT(50),      // ~50 words
        MEDIUM(100),    // ~100 words
        LONG(150);      // ~150 words
        
        private final int maxWords;
        
        SummaryLength(int maxWords) {
            this.maxWords = maxWords;
        }
        
        public int getMaxWords() {
            return maxWords;
        }
    }
}
