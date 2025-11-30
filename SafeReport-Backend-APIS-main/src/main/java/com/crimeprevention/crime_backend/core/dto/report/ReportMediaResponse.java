package com.crimeprevention.crime_backend.core.dto.report;

import com.crimeprevention.crime_backend.core.model.enums.MediaType;
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
public class ReportMediaResponse {
    private UUID id;
    private MediaType mediaType;
    private String mediaUrl;
    private Instant createdAt;
}