package com.crimeprevention.crime_backend.core.model.chat;

import com.crimeprevention.crime_backend.core.base.AbstractAuditEntity;
import com.crimeprevention.crime_backend.core.model.enums.WatchGroupStatus;
import com.crimeprevention.crime_backend.core.model.location.Location;
import com.crimeprevention.crime_backend.core.model.user.Officer;
import com.crimeprevention.crime_backend.core.model.user.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.Type;

import java.time.Instant;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@Entity
@Table(name = "watch_groups")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class WatchGroup extends AbstractAuditEntity {
    @Id @GeneratedValue @Column(columnDefinition = "uuid")
    private UUID id;
    
    @Column(length = 100, nullable = false)
    private String name;
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "location_id", nullable = false)
    private Location location;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assigned_officer_id")
    private Officer assignedOfficer;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private WatchGroupStatus status = WatchGroupStatus.PENDING;
    
    @Column(name = "created_by", updatable = false)
    private UUID createdBy;
    
    @Column(name = "approved_at")
    private Instant approvedAt;
    
    @Column(name = "approved_by")
    private UUID approvedBy;
    
    @Column(name = "rejection_reason", columnDefinition = "TEXT")
    private String rejectionReason;
    
    @OneToMany(mappedBy = "group", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<WatchGroupMember> members = new HashSet<>();
    
    @OneToMany(mappedBy = "group", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<WatchGroupMessage> messages = new HashSet<>();
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by", insertable = false, updatable = false)
    private User creatorUser;
}
