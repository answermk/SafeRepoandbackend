package com.crimeprevention.crime_backend.core.dto.education;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VideoTutorialResponse {
    private UUID id;
    private String title;
    private String description;
    private String videoUrl;
    private String thumbnailUrl;
    private Integer durationSeconds;
    private String duration; // Formatted duration (e.g., "3:45")
    private Long fileSize;
    private String category;
    private Boolean isFeatured;
    private Boolean isActive;
    private Long views;
    private UUID uploadedBy;
    private Instant createdAt;
    private Instant updatedAt;
}

