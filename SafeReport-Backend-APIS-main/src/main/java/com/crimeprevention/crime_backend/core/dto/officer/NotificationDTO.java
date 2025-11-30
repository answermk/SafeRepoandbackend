package com.crimeprevention.crime_backend.core.dto.officer;

import lombok.Data;
import java.time.Instant;
import java.util.UUID;

@Data
public class NotificationDTO {
    private UUID id;
    private String title;
    private String message;
    private String type;  // e.g., CASE_ASSIGNED, BACKUP_REQUESTED, STATUS_UPDATE
    private boolean read;
    private Instant createdAt;
    private UUID relatedEntityId;  // e.g., case ID, backup request ID
    private String relatedEntityType;  // e.g., CASE, BACKUP_REQUEST
}
