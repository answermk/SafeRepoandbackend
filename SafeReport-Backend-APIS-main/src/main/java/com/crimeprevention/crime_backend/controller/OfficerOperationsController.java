package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.dto.officer.*;
import com.crimeprevention.crime_backend.core.dto.report.AssignmentResponse;
import com.crimeprevention.crime_backend.core.model.enums.DutyStatus;
import com.crimeprevention.crime_backend.core.service.interfaces.OfficerService;
import com.crimeprevention.crime_backend.core.service.interfaces.BackupService;
import com.crimeprevention.crime_backend.core.service.interfaces.AssignmentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * REST controller for officer-specific operations like status updates, case management, etc.
 */
@RestController
@RequestMapping("/api/officers")
@RequiredArgsConstructor
@Slf4j
@PreAuthorize("hasAnyRole('POLICE_OFFICER', 'OFFICER', 'ADMIN')")
public class OfficerOperationsController {

    private final OfficerService officerService;
    private final BackupService backupService;
    private final AssignmentService assignmentService;

    /**
     * Update officer's duty status
     */
    @PutMapping("/{officerId}/status")
    public ResponseEntity<OfficerDTO> updateDutyStatus(
            @PathVariable UUID officerId,
            @Valid @RequestBody Map<String, String> request) {
        
        UpdateOfficerRequest updateRequest = new UpdateOfficerRequest();
        updateRequest.setDutyStatus(DutyStatus.valueOf(request.get("dutyStatus")));
        
        OfficerDTO updated = officerService.updateOfficer(officerId, updateRequest);
        return ResponseEntity.ok(updated);
    }

    /**
     * Get active cases for an officer
     */
    @GetMapping("/{officerId}/cases/active")
    public ResponseEntity<?> getActiveCases(
            @PathVariable UUID officerId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<AssignmentResponse> activeCases = assignmentService.getOfficerAssignmentsByStatus(
            officerId, "ASSIGNED", pageable);
        return ResponseEntity.ok(activeCases);
    }

    /**
     * Get resolved cases for an officer
     */
    @GetMapping("/{officerId}/cases/resolved")
    public ResponseEntity<?> getResolvedCases(
            @PathVariable UUID officerId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<AssignmentResponse> resolvedCases = assignmentService.getOfficerAssignmentsByStatus(
            officerId, "COMPLETED", pageable);
        return ResponseEntity.ok(resolvedCases);
    }

    /**
     * Get all cases for an officer's area (using all assignments)
     */
    @GetMapping("/{officerId}/cases/resident")
    public ResponseEntity<?> getResidentCases(
            @PathVariable UUID officerId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<AssignmentResponse> residentCases = assignmentService.getOfficerAssignments(
            officerId, pageable);
        return ResponseEntity.ok(residentCases);
    }

    /**
     * Request backup
     */
    @PostMapping("/{officerId}/backup-request")
    public ResponseEntity<BackupResponseDTO> requestBackup(
            @PathVariable UUID officerId,
            @Valid @RequestBody BackupRequestDTO request) {
        BackupResponseDTO response = backupService.requestBackup(officerId, request);
        return ResponseEntity.ok(response);
    }

    /**
     * Cancel backup request
     */
    @DeleteMapping("/{officerId}/backup-request")
    public ResponseEntity<Void> cancelBackupRequest(@PathVariable UUID officerId) {
        backupService.cancelBackupRequest(officerId);
        return ResponseEntity.noContent().build();
    }

    /**
     * Update officer location
     */
    @PutMapping("/{officerId}/location")
    public ResponseEntity<Void> updateLocation(
            @PathVariable UUID officerId,
            @Valid @RequestBody LocationUpdateDTO location) {
        officerService.updateOfficerLocation(officerId, location);
        return ResponseEntity.ok().build();
    }

    /**
     * Get officer messages
     */
    @GetMapping("/{officerId}/messages")
    public ResponseEntity<List<MessageDTO>> getMessages(@PathVariable UUID officerId) {
        // Validate that the officerId matches the authenticated user's ID
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UUID currentUserId = UUID.fromString(authentication.getName());
        
        // Allow access if user is accessing their own messages or is an admin
        if (!officerId.equals(currentUserId) && !authentication.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"))) {
            return ResponseEntity.status(org.springframework.http.HttpStatus.FORBIDDEN).build();
        }
        
        List<MessageDTO> messages = officerService.getOfficerMessages(officerId);
        return ResponseEntity.ok(messages);
    }

    /**
     * Send a message
     */
    @PostMapping("/{officerId}/messages")
    public ResponseEntity<?> sendMessage(
            @PathVariable UUID officerId,
            @Valid @RequestBody SendMessageDTO message) {
        try {
            // Validate that the officerId matches the authenticated user's ID
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication == null) {
                log.error("Authentication is null when sending message");
                return ResponseEntity.status(org.springframework.http.HttpStatus.UNAUTHORIZED).build();
            }
            
            UUID currentUserId = UUID.fromString(authentication.getName());
            
            // Allow access if user is sending from their own account or is an admin
            if (!officerId.equals(currentUserId) && !authentication.getAuthorities().stream()
                    .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"))) {
                log.error("User {} is not authorized to send messages as {}", currentUserId, officerId);
                return ResponseEntity.status(org.springframework.http.HttpStatus.FORBIDDEN).build();
            }
            
            // Validate message DTO
            if (message == null) {
                log.error("Message DTO is null");
                return ResponseEntity.badRequest().build();
            }
            
            MessageDTO sent = officerService.sendMessage(officerId, message);
            log.info("Message sent successfully - senderId={}, recipientId={}, messageId={}", 
                    officerId, message.getRecipientId(), sent.getId());
            return ResponseEntity.ok(sent);
        } catch (IllegalArgumentException e) {
            log.error("Invalid argument when sending message: {}", e.getMessage());
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "Invalid request");
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(errorResponse);
        } catch (SecurityException e) {
            log.error("Security exception when sending message: {}", e.getMessage());
            return ResponseEntity.status(org.springframework.http.HttpStatus.FORBIDDEN).build();
        } catch (Exception e) {
            log.error("Error sending message: officerId={}, recipientId={}, error={}", 
                    officerId, message != null ? message.getRecipientId() : "null", e.getMessage(), e);
            
            // Return error details in response body
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "Failed to send message");
            errorResponse.put("message", e.getMessage());
            errorResponse.put("exceptionType", e.getClass().getSimpleName());
            if (e.getCause() != null) {
                errorResponse.put("cause", e.getCause().getMessage());
            }
            return ResponseEntity.status(org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(errorResponse);
        }
    }

    /**
     * Get officer notifications
     */
    @GetMapping("/{officerId}/notifications")
    public ResponseEntity<List<NotificationDTO>> getNotifications(@PathVariable UUID officerId) {
        List<NotificationDTO> notifications = officerService.getOfficerNotifications(officerId);
        return ResponseEntity.ok(notifications);
    }

    /**
     * Mark notification as read
     */
    @PutMapping("/{officerId}/notifications/{notificationId}")
    public ResponseEntity<Void> markNotificationRead(
            @PathVariable UUID officerId,
            @PathVariable UUID notificationId) {
        officerService.markNotificationRead(officerId, notificationId);
        return ResponseEntity.ok().build();
    }
}
