package com.crimeprevention.crime_backend.core.model.report;

import com.crimeprevention.crime_backend.core.base.AbstractAuditEntity;
import com.crimeprevention.crime_backend.core.model.user.Officer;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.Type;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "case_notes",
        indexes = {
                @Index(name = "idx_case_notes_report", columnList = "report_id"),
                @Index(name = "idx_case_notes_officer", columnList = "officer_id")
        })
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CaseNote extends AbstractAuditEntity {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "report_id", nullable = false)
    private Report report;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "officer_id", nullable = false)
    private Officer officer;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String note;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;
}
