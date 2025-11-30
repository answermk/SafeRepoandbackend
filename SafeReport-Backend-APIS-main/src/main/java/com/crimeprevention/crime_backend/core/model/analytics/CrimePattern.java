package com.crimeprevention.crime_backend.core.model.analytics;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "crime_patterns")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CrimePattern {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    
    @Column(name = "pattern_type", nullable = false)
    @Enumerated(EnumType.STRING)
    private PatternType patternType;
    
    @Column(name = "analysis_period", nullable = false)
    @Enumerated(EnumType.STRING)
    private AnalysisPeriod analysisPeriod;
    
    @Column(name = "start_date", nullable = false)
    private LocalDateTime startDate;
    
    @Column(name = "end_date", nullable = false)
    private LocalDateTime endDate;
    
    @Column(name = "pattern_summary", columnDefinition = "TEXT", nullable = false)
    private String patternSummary;
    
    @Column(name = "key_insights", columnDefinition = "TEXT", nullable = false)
    private String keyInsights;
    
    @Column(name = "risk_level", nullable = false)
    @Enumerated(EnumType.STRING)
    private RiskLevel riskLevel;
    
    @Column(name = "confidence_score")
    private Double confidenceScore;
    
    @ElementCollection
    @CollectionTable(name = "crime_pattern_locations", joinColumns = @JoinColumn(name = "pattern_id"))
    @Column(name = "location")
    private List<String> affectedLocations;
    
    @ElementCollection
    @CollectionTable(name = "crime_pattern_types", joinColumns = @JoinColumn(name = "pattern_id"))
    @Column(name = "crime_type")
    private List<String> affectedCrimeTypes;
    
    @ElementCollection
    @CollectionTable(name = "crime_pattern_tags", joinColumns = @JoinColumn(name = "pattern_id"))
    @Column(name = "tag")
    private List<String> tags;
    
    @Column(name = "recommendations", columnDefinition = "TEXT")
    private String recommendations;
    
    @Column(name = "ai_service_used", nullable = false)
    private String aiServiceUsed;
    
    @Column(name = "model_version")
    private String modelVersion;
    
    @Column(name = "processing_time_ms")
    private Long processingTimeMs;
    
    @Column(name = "created_at", nullable = false)
    @CreationTimestamp
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    @UpdateTimestamp
    private LocalDateTime updatedAt;
    
    // Enums
    public enum PatternType {
        TEMPORAL,           // Time-based patterns
        SPATIAL,            // Location-based patterns
        CRIME_TYPE,         // Crime category patterns
        CROSS_DIMENSIONAL,  // Multi-factor patterns
        ANOMALY,            // Unusual patterns
        TREND               // Long-term trends
    }
    
    public enum AnalysisPeriod {
        DAILY, WEEKLY, MONTHLY, QUARTERLY, YEARLY, CUSTOM
    }
    
    public enum RiskLevel {
        LOW, MEDIUM, HIGH, CRITICAL
    }
}
