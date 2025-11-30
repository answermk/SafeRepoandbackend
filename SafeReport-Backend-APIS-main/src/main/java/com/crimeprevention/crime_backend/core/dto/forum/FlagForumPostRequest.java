package com.crimeprevention.crime_backend.core.dto.forum;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FlagForumPostRequest {
    @NotNull(message = "Flagged status is required")
    private Boolean flagged;
}

