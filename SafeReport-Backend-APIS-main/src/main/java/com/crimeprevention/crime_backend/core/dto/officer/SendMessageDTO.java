package com.crimeprevention.crime_backend.core.dto.officer;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class SendMessageDTO {
    private UUID recipientId;
    private String message;
    
    // Attachment fields
    private String attachmentUrl;
    private String attachmentName;
    private String attachmentType;
}