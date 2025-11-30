package com.crimeprevention.crime_backend.core.dto.forum;

import com.crimeprevention.crime_backend.core.model.enums.ForumPriority;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateForumPostRequest {
    @NotBlank(message = "Title is required")
    private String title;
    
    @NotBlank(message = "Content is required")
    private String content;
    
    @NotBlank(message = "Category is required")
    private String category;
    
    @NotNull(message = "Priority is required")
    private ForumPriority priority;
    
    private List<String> tags;
    
    private String location;
}

