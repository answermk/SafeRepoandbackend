package com.crimeprevention.crime_backend.core.model.forum;

import com.crimeprevention.crime_backend.core.model.base.AbstractAuditEntity;
import com.crimeprevention.crime_backend.core.model.user.User;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.util.UUID;

@Entity
@Table(name = "forum_replies")
@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = false)
public class ForumReply extends AbstractAuditEntity {
    
    @Column(name = "post_id", nullable = false, updatable = false)
    private UUID postId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "post_id", insertable = false, updatable = false)
    private ForumPost post;
    
    @Column(name = "content", nullable = false, columnDefinition = "TEXT")
    private String content;
    
    @Column(name = "author_id", updatable = false)
    private UUID authorId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "author_id", insertable = false, updatable = false)
    private User author;
    
    @Column(name = "is_official")
    @Builder.Default
    private Boolean isOfficial = false;
    
    @Column(name = "parent_reply_id")
    private UUID parentReplyId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_reply_id", insertable = false, updatable = false)
    private ForumReply parentReply;
}

