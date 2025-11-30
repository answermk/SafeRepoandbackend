package com.crimeprevention.crime_backend.core.model.forum;

import com.crimeprevention.crime_backend.core.model.base.AbstractAuditEntity;
import com.crimeprevention.crime_backend.core.model.enums.ForumPriority;
import com.crimeprevention.crime_backend.core.model.enums.ForumStatus;
import com.crimeprevention.crime_backend.core.model.user.User;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "forum_posts")
@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = false)
public class ForumPost extends AbstractAuditEntity {
    
    @Column(name = "title", nullable = false)
    private String title;
    
    @Column(name = "content", nullable = false, columnDefinition = "TEXT")
    private String content;
    
    @Column(name = "author_id", updatable = false)
    private UUID authorId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "author_id", insertable = false, updatable = false)
    private User author;
    
    @Column(name = "views")
    @Builder.Default
    private Integer views = 0;
    
    @Column(name = "replies_count")
    @Builder.Default
    private Integer repliesCount = 0;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "priority")
    @Builder.Default
    private ForumPriority priority = ForumPriority.MEDIUM;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    @Builder.Default
    private ForumStatus status = ForumStatus.PENDING;
    
    @Column(name = "category")
    private String category;
    
    @ElementCollection
    @CollectionTable(name = "forum_post_tags", joinColumns = @JoinColumn(name = "post_id"))
    @Column(name = "tag")
    @Builder.Default
    private List<String> tags = new ArrayList<>();
    
    @Column(name = "has_official_response")
    @Builder.Default
    private Boolean hasOfficialResponse = false;
    
    @Column(name = "official_response", columnDefinition = "TEXT")
    private String officialResponse;
    
    @Column(name = "flagged")
    @Builder.Default
    private Boolean flagged = false;
    
    @Column(name = "resolved")
    @Builder.Default
    private Boolean resolved = false;
    
    @Column(name = "resolved_at")
    private Instant resolvedAt;
    
    @Column(name = "location")
    private String location;
    
    // Increment views
    public void incrementViews() {
        this.views = (this.views == null ? 0 : this.views) + 1;
    }
    
    // Increment replies count
    public void incrementRepliesCount() {
        this.repliesCount = (this.repliesCount == null ? 0 : this.repliesCount) + 1;
    }
    
    // Decrement replies count
    public void decrementRepliesCount() {
        this.repliesCount = Math.max(0, (this.repliesCount == null ? 0 : this.repliesCount) - 1);
    }
}

