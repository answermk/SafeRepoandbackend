package com.crimeprevention.crime_backend.core.model.ai;

import com.crimeprevention.crime_backend.core.model.report.Report;
import jakarta.persistence.*;
import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.Builder;
import org.hibernate.annotations.Type;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "report_summaries")
@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ReportSummary {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "report_id", nullable = false)
    private Report report;
    
    @Column(name = "summary", columnDefinition = "TEXT", nullable = false)
    private String summary;
    
    @Column(name = "key_points", columnDefinition = "TEXT")
    private String keyPoints;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "urgency_level")
    private UrgencyLevel urgencyLevel;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "priority_level")
    private PriorityLevel priorityLevel;
    
    @ElementCollection
    @CollectionTable(name = "report_summary_tags", joinColumns = @JoinColumn(name = "summary_id"))
    @Column(name = "tag")
    private List<String> tags;
    
    @Column(name = "ai_service_used")
    private String aiServiceUsed;
    
    @Column(name = "model_version")
    private String modelVersion;
    
    @Column(name = "confidence_score")
    private Double confidenceScore;
    
    @Column(name = "word_count")
    private Integer wordCount;
    
    @Column(name = "processing_time_ms")
    private Integer processingTimeMs;
    
    @Column(name = "language")
    private String language;
    
    @Column(name = "prompt_used", columnDefinition = "TEXT")
    private String promptUsed;
    
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;
    
    @Column(name = "deleted_by")
    private UUID deletedBy;
    
    @Column(name = "deletion_reason")
    private String deletionReason;
    
    @Column(name = "is_deleted")
    private Boolean isDeleted = false;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        isDeleted = false;
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    public enum UrgencyLevel {
        LOW, MEDIUM, HIGH, CRITICAL
    }
    
    public enum PriorityLevel {
        LOW, MEDIUM, HIGH, URGENT
    }
}
