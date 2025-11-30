package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.dto.officer.*;
import com.crimeprevention.crime_backend.core.service.interfaces.OfficerService;
import com.crimeprevention.crime_backend.core.service.interfaces.BackupService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.security.Principal;
import java.util.UUID;

@Controller
@RequiredArgsConstructor
public class OfficerWebSocketController {

    private final SimpMessagingTemplate messagingTemplate;
    private final OfficerService officerService;
    private final BackupService backupService;

    /**
     * Handle location updates from officers
     */
    @MessageMapping("/officer/location")
    public void handleLocationUpdate(@Payload LocationUpdateDTO location, Principal principal) {
        UUID officerId = UUID.fromString(principal.getName());
        
        // Update officer location
        officerService.updateOfficerLocation(officerId, location);
        
        // Broadcast to relevant subscribers (e.g., dispatch, nearby officers)
        messagingTemplate.convertAndSend("/topic/officer-locations", location);
    }

    /**
     * Handle duty status updates
     */
    @MessageMapping("/officer/status")
    public void handleStatusUpdate(@Payload UpdateOfficerRequest status, Principal principal) {
        UUID officerId = UUID.fromString(principal.getName());
        
        // Update officer status
        OfficerDTO updatedOfficer = officerService.updateOfficer(officerId, status);
        
        // Broadcast to relevant subscribers
        messagingTemplate.convertAndSend("/topic/officer-status", updatedOfficer);
    }

    /**
     * Handle direct messages between officers
     */
    @MessageMapping("/officer/message")
    public void handleDirectMessage(@Payload SendMessageDTO message, Principal principal) {
        UUID senderId = UUID.fromString(principal.getName());
        
        // Save and process the message
        MessageDTO sentMessage = officerService.sendMessage(senderId, message);
        
        // Send to specific recipient
        messagingTemplate.convertAndSendToUser(
            message.getRecipientId().toString(),
            "/queue/messages",
            sentMessage
        );
    }

    /**
     * Handle backup requests
     */
    @MessageMapping("/officer/backup-request")
    public void handleBackupRequest(@Payload BackupRequestDTO request, Principal principal) {
        UUID officerId = UUID.fromString(principal.getName());
        
        // Process backup request
        BackupResponseDTO response = backupService.requestBackup(officerId, request);
        
        // Broadcast to nearby officers and dispatch
        messagingTemplate.convertAndSend("/topic/backup-requests", response);
        
        // Send specific notifications to relevant officers
        // This could be based on location, availability, etc.
        officerService.getAvailableOfficersForBackup(response.getLocation())
            .forEach(officer -> {
                messagingTemplate.convertAndSendToUser(
                    officer.getId().toString(),
                    "/queue/backup-requests",
                    response
                );
            });
    }
}
