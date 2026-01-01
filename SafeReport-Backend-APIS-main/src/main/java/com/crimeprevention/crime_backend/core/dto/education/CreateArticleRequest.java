package com.crimeprevention.crime_backend.core.dto.education;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateArticleRequest {
    @NotBlank(message = "Title is required")
    private String title;
    
    private String description;
    
    @NotBlank(message = "Content is required")
    private String content;
    
    private String category;
    
    private Integer readTimeMinutes;
    
    private Boolean isFeatured;
    
    private String imageUrl;
    
    private String author;
    
    private String tags;
}

