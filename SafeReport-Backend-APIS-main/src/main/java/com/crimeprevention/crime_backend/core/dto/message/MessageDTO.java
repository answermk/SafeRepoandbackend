package com.crimeprevention.crime_backend.core.dto.message;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.UUID;

/**
 * DTO for sending messages between users.
 */
@Data
public class MessageDTO {

    @NotNull(message = "Sender ID is required")
    private UUID senderId;

    @NotNull(message = "Receiver ID is required")
    private UUID receiverId;

    @NotBlank(message = "Message content cannot be empty")
    private String content;

    private UUID reportId; // optional, if message is tied to a report
}
