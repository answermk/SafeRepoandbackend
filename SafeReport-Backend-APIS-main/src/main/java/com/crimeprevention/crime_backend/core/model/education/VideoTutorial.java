package com.crimeprevention.crime_backend.core.model.education;

import com.crimeprevention.crime_backend.core.model.base.AbstractAuditEntity;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.util.UUID;

/**
 * Video Tutorial Entity
 * Stores educational video tutorials uploaded by admins
 */
@Entity
@Table(name = "video_tutorials")
@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = false)
public class VideoTutorial extends AbstractAuditEntity {

    @Column(name = "title", nullable = false, length = 200)
    private String title;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "video_url", nullable = false, columnDefinition = "TEXT")
    private String videoUrl;

    @Column(name = "thumbnail_url", columnDefinition = "TEXT")
    private String thumbnailUrl;

    @Column(name = "duration_seconds")
    private Integer durationSeconds;

    @Column(name = "file_size")
    private Long fileSize;

    @Column(name = "category", length = 50)
    private String category;

    @Column(name = "is_featured")
    @Builder.Default
    private Boolean isFeatured = false;

    @Column(name = "is_active")
    @Builder.Default
    private Boolean isActive = true;

    @Column(name = "views")
    @Builder.Default
    private Long views = 0L;

    @Column(name = "uploaded_by", nullable = false)
    private UUID uploadedBy; // Admin user ID
}

