package com.crimeprevention.crime_backend.core.dto.message;

import lombok.Data;
import java.time.Instant;
import java.util.UUID;

@Data
public class CaseMessageDTO {
    private UUID senderId;
    private UUID reportId;
    private String content;
    private Instant timestamp;
}
