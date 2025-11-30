package com.crimeprevention.crime_backend.core.dto.message;

import lombok.Data;
import java.time.Instant;
import java.util.UUID;

@Data
public class WatchGroupMessageDTO {

    private UUID id;
    private UUID groupId;
    private UUID senderId;
    private String message;
    private Instant sentAt;
}
