package com.crimeprevention.crime_backend.core.dto.message;

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
public class MessageResponse {
    private UUID id;
    private UUID senderId;
    private String senderName;
    private String senderEmail;
    private UUID receiverId;
    private String receiverName;
    private String receiverEmail;
    private UUID reportId;
    private String reportTitle;
    private String message;
    private Instant sentAt;
    private Instant createdAt;
    private Instant updatedAt;
    
    // Attachment fields
    private String attachmentUrl;
    private String attachmentName;
    private String attachmentType;
    
    // Read receipt
    private Boolean isRead;
    private Instant readAt;
    
    // Edit/Delete support
    private Boolean isEdited;
    private Instant editedAt;
    private Boolean isDeleted;
    private Instant deletedAt;
} 