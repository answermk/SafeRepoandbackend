package com.crimeprevention.crime_backend.core.dto.forum;

import com.crimeprevention.crime_backend.core.model.enums.ForumPriority;
import com.crimeprevention.crime_backend.core.model.enums.ForumStatus;
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
public class ForumPostResponse {
    private UUID id;
    private String title;
    private String content;
    private AuthorDTO author;
    private UUID authorId;
    private Integer views;
    private Integer replies;
    private ForumPriority priority;
    private ForumStatus status;
    private String category;
    private List<String> tags;
    private Boolean hasOfficialResponse;
    private String officialResponse;
    private Boolean flagged;
    private Boolean resolved;
    private Instant resolvedAt;
    private String location;
    private Instant createdAt;
    private Instant updatedAt;
    
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

