package com.crimeprevention.crime_backend.core.model.report;

import com.crimeprevention.crime_backend.core.model.base.AbstractAuditEntity;
import com.crimeprevention.crime_backend.core.model.enums.CrimeType;
import com.crimeprevention.crime_backend.core.model.enums.Priority;
import com.crimeprevention.crime_backend.core.model.enums.ReportStatus;
import com.crimeprevention.crime_backend.core.model.user.User;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "reports")
@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = false)
public class Report extends AbstractAuditEntity {
    
    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "description", nullable = false, columnDefinition = "TEXT")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "crime_type")
    private CrimeType crimeType;

    @Embedded
    private Location location;

    @Column(name = "weather_condition")
    private String weatherCondition;

    @Enumerated(EnumType.STRING)
    @Column(name = "priority")
    private Priority priority;

    @Column(name = "date")
    private Instant date;

    @Column(name = "submitted_at")
    private Instant submittedAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    @Builder.Default
    private ReportStatus status = ReportStatus.PENDING;

    @OneToMany(mappedBy = "report", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<EvidenceFile> evidence;

    @Column(name = "reporter_id", updatable = false)
    private UUID reporterId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reporter_id", insertable = false, updatable = false)
    private User reporter;

    @Column(name = "crime_relationship")
    private String crimeRelationship;

    @Column(name = "witness_info")
    private String witnessInfo;

    @Column(name = "is_anonymous")
    private boolean isAnonymous;

    @Embeddable
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Location {
        private double latitude;
        private double longitude;
        private String address;
        private String city;
        private String state;
        private String zipCode;
        private String area;
        private String district;
    }
}
