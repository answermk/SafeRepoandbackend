package com.crimeprevention.crime_backend.core.dto.ai;

import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class RecommendationResponse {
    
    private String recommendationId;
    private UUID reportId;
    private LocalDateTime generatedAt;
    private String aiServiceUsed;
    
    private List<OfficerRecommendation> officerRecommendations;
    private List<ResourceRecommendation> resourceRecommendations;
    private List<String> strategicInsights;
    private double overallConfidence;
    
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Builder
    public static class OfficerRecommendation {
        private UUID officerId;
        private String officerName;
        private double matchScore;
        private List<String> strengths;
        private List<String> considerations;
        private String recommendedRole;
        private int currentWorkload;
        private double proximityScore;
    }
    
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Builder
    public static class ResourceRecommendation {
        private String resourceType;
        private String description;
        private int quantity;
        private String priority;
        private String justification;
        private double urgency;
    }
}
