package com.crimeprevention.crime_backend.core.model.report;

import com.crimeprevention.crime_backend.core.base.AbstractAuditEntity;
import com.crimeprevention.crime_backend.core.model.enums.AssignmentStatus;
import com.crimeprevention.crime_backend.core.model.user.Officer;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.Type;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "assignments",
        indexes = {
                @Index(name = "idx_assignments_officer", columnList = "officer_id"),
                @Index(name = "idx_assignments_report", columnList = "report_id")
        },
        uniqueConstraints = {
                @UniqueConstraint(name = "ux_assignments_report_officer", columnNames = {"report_id", "officer_id"})
        })
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Assignment extends AbstractAuditEntity {

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

    @Column(name = "assigned_by", nullable = false)
    private UUID assignedBy;

    @Column(name = "assignment_notes", columnDefinition = "TEXT")
    private String assignmentNotes;

    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    private AssignmentStatus status = AssignmentStatus.ASSIGNED;

    @Column(name = "assigned_at", nullable = false)
    private Instant assignedAt;
}
