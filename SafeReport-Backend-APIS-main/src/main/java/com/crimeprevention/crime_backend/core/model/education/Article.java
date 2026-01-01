package com.crimeprevention.crime_backend.core.model.education;

import com.crimeprevention.crime_backend.core.model.base.AbstractAuditEntity;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "education_articles")
@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = false)
public class Article extends AbstractAuditEntity {
    
    @Column(name = "title", nullable = false, length = 200)
    private String title;
    
    @Column(name = "description", length = 500)
    private String description;
    
    @Column(name = "content", columnDefinition = "TEXT", nullable = false)
    private String content;
    
    @Column(name = "category", length = 50)
    private String category;
    
    @Column(name = "read_time_minutes")
    private Integer readTimeMinutes;
    
    @Column(name = "is_featured")
    @Builder.Default
    private Boolean isFeatured = false;
    
    @Column(name = "is_published")
    @Builder.Default
    private Boolean isPublished = true;
    
    @Column(name = "image_url")
    private String imageUrl;
    
    @Column(name = "author", length = 100)
    private String author;
    
    @Column(name = "views_count")
    @Builder.Default
    private Long viewsCount = 0L;
    
    @Column(name = "published_at")
    private LocalDateTime publishedAt;
    
    @Column(name = "tags", length = 200)
    private String tags; // Comma-separated tags
}

