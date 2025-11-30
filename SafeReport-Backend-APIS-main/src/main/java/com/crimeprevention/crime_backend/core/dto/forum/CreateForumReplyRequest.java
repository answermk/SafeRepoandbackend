package com.crimeprevention.crime_backend.core.dto.forum;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateForumReplyRequest {
    @NotBlank(message = "Content is required")
    private String content;
    
    private Boolean isOfficial;
    
    private java.util.UUID parentReplyId; // Optional: for nested replies
}

