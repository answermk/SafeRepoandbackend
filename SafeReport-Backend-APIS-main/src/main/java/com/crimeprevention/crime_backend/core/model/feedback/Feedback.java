package com.crimeprevention.crime_backend.core.model.feedback;

import com.crimeprevention.crime_backend.core.model.base.AbstractAuditEntity;
import com.crimeprevention.crime_backend.core.model.user.User;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.util.UUID;

@Entity
@Table(name = "feedbacks")
@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = false)
public class Feedback extends AbstractAuditEntity {
    
    @Column(name = "message", nullable = false, columnDefinition = "TEXT")
    private String message;
    
    @Column(name = "user_id", nullable = false, updatable = false)
    private UUID userId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", insertable = false, updatable = false)
    private User user;
    
    @Column(name = "status")
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private FeedbackStatus status = FeedbackStatus.PENDING;
    
    @Column(name = "admin_response", columnDefinition = "TEXT")
    private String adminResponse;
}

