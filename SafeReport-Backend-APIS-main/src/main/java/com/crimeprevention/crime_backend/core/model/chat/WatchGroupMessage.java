package com.crimeprevention.crime_backend.core.model.chat;

import com.crimeprevention.crime_backend.core.base.AbstractAuditEntity;
import com.crimeprevention.crime_backend.core.model.user.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.Type;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "watch_group_messages",
        indexes = {
                @Index(name = "idx_wgm_group", columnList = "group_id"),
                @Index(name = "idx_wgm_sender", columnList = "sender_id")
        })
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WatchGroupMessage extends AbstractAuditEntity {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "group_id", nullable = false)
    private WatchGroup group;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "sender_id", nullable = false)
    private User sender;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String message;

    @Column(name = "sent_at", nullable = false)
    private Instant sentAt;
}
