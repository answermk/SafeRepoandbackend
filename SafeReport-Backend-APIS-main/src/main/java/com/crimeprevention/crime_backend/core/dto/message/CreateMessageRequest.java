package com.crimeprevention.crime_backend.core.dto.message;

import lombok.Data;

import java.util.UUID;

@Data
public class CreateMessageRequest {
    // Message is optional if there's an attachment
    private String message;
    
    private UUID reportId; // optional, if message is tied to a report
    
    // Attachment fields
    private String attachmentUrl;
    private String attachmentName;
    private String attachmentType;
} 