package com.crimeprevention.crime_backend.core.dto.forum;

import com.crimeprevention.crime_backend.core.model.enums.ForumPriority;
import com.crimeprevention.crime_backend.core.model.enums.ForumStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateForumPostRequest {
    private String title;
    private String content;
    private ForumPriority priority;
    private ForumStatus status;
    private String category;
    private List<String> tags;
    private Boolean flagged;
}

