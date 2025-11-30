package com.crimeprevention.crime_backend.core.model.schedule;

import com.crimeprevention.crime_backend.core.base.AbstractAuditEntity;
import com.crimeprevention.crime_backend.core.model.user.Officer;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.Type;


import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "duty_schedules",
        indexes = {
                @Index(name = "idx_duty_schedules_officer", columnList = "officer_id"),
                @Index(name = "idx_duty_schedules_shift", columnList = "shift_start, shift_end")
        })
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DutySchedule extends AbstractAuditEntity {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "officer_id", nullable = false)
    private Officer officer;

    @Column(name = "shift_start", nullable = false)
    private Instant shiftStart;

    @Column(name = "shift_end", nullable = false)
    private Instant shiftEnd;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;
}
