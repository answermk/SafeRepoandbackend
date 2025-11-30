package com.crimeprevention.crime_backend.core.dto.forum;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ForumReplyResponse {
    private UUID id;
    private UUID postId;
    private String content;
    private AuthorDTO author;
    private UUID authorId;
    private Boolean isOfficial;
    private Instant createdAt;
    private Instant updatedAt;
    private UUID parentReplyId; // For nested replies
    private List<ForumReplyResponse> nestedReplies; // Child replies
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AuthorDTO {
        private UUID id;
        private String username;
        private String fullName;
        private String email;
    }
}

