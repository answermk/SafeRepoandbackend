package com.crimeprevention.crime_backend.core.model.report;

import com.crimeprevention.crime_backend.core.base.AbstractAuditEntity;
import com.crimeprevention.crime_backend.core.model.enums.BackupStatus;
import com.crimeprevention.crime_backend.core.model.user.Officer;
import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "backup_requests",
        indexes = {
                @Index(name = "idx_backup_req_requesting_officer", columnList = "requesting_officer_id"),
                @Index(name = "idx_backup_req_assigned_officer", columnList = "assigned_officer_id")
        })
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BackupRequest extends AbstractAuditEntity {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "requesting_officer_id", nullable = false)
    private Officer requestingOfficer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assigned_officer_id")
    private Officer assignedOfficer;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "assignment_id", nullable = false)
    private Assignment assignment;

    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    @Builder.Default
    private BackupStatus status = BackupStatus.PENDING;

    @Column(columnDefinition = "TEXT")
    private String details;

    @Column(name = "requested_at", nullable = false)
    private Instant requestedAt;

    @Column(name = "responded_at")
    private Instant respondedAt;
}
