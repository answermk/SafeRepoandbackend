package com.crimeprevention.crime_backend.core.dto.education;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ArticleResponse {
    private UUID id;
    private String title;
    private String description;
    private String content;
    private String category;
    private Integer readTimeMinutes;
    private Boolean isFeatured;
    private String imageUrl;
    private String author;
    private Long viewsCount;
    private LocalDateTime publishedAt;
    private String tags;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

