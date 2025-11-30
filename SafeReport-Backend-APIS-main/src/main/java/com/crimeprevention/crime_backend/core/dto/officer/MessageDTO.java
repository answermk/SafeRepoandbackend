package com.crimeprevention.crime_backend.core.dto.officer;

import lombok.Data;
import java.time.Instant;
import java.util.UUID;

@Data
public class MessageDTO {
    private UUID id;
    private UUID senderId;
    private UUID recipientId;
    private String senderName;
    private String recipientName;
    private String content;
    private Instant sentAt;
    private boolean read;
}
