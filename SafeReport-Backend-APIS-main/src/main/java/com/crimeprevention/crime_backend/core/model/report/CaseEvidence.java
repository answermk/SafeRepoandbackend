package com.crimeprevention.crime_backend.core.model.report;

import com.crimeprevention.crime_backend.core.base.AbstractAuditEntity;
import com.crimeprevention.crime_backend.core.model.user.Officer;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.Type;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "case_evidence",
        indexes = {
                @Index(name = "idx_case_evidence_report", columnList = "report_id"),
                @Index(name = "idx_case_evidence_uploader", columnList = "uploaded_by")
        })
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CaseEvidence extends AbstractAuditEntity {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "report_id", nullable = false)
    private Report report;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "uploaded_by", nullable = false)
    private Officer uploadedBy;

    @Enumerated(EnumType.STRING)
    @Column(name = "media_type", length = 20, nullable = false)
    private MediaType mediaType;

    @Column(name = "media_url", columnDefinition = "TEXT", nullable = false)
    private String mediaUrl;

    @Column(name = "uploaded_at", nullable = false)
    private Instant uploadedAt;

    public enum MediaType {
        PHOTO,
        VIDEO,
        AUDIO
    }
}
