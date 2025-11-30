package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.dto.message.CreateMessageRequest;
import com.crimeprevention.crime_backend.core.dto.message.MessageResponse;
import com.crimeprevention.crime_backend.core.dto.message.UpdateMessageRequest;
import com.crimeprevention.crime_backend.core.service.interfaces.MessageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/messages")
@RequiredArgsConstructor
@Slf4j
public class MessageController {

    private final MessageService messageService;

    @PostMapping("/send/{receiverId}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<MessageResponse> sendMessage(
            @PathVariable UUID receiverId,
            @Valid @RequestBody CreateMessageRequest request,
            Authentication authentication) {
        
        UUID senderId = UUID.fromString(authentication.getName());
        MessageResponse response = messageService.sendMessage(senderId, receiverId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/conversation/{userId}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<List<MessageResponse>> getConversation(
            @PathVariable UUID userId,
            Authentication authentication) {
        
        UUID currentUserId = UUID.fromString(authentication.getName());
        List<MessageResponse> messages = messageService.getMessagesBetween(currentUserId, userId);
        return ResponseEntity.ok(messages);
    }

    @GetMapping("/inbox")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<Page<MessageResponse>> getInbox(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "sentAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir,
            Authentication authentication) {
        
        UUID userId = UUID.fromString(authentication.getName());
        Sort sort = sortDir.equalsIgnoreCase("desc") ? 
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<MessageResponse> messages = messageService.getInbox(userId, pageable);
        return ResponseEntity.ok(messages);
    }

    @GetMapping("/sent")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<Page<MessageResponse>> getSentMessages(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "sentAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir,
            Authentication authentication) {
        
        UUID userId = UUID.fromString(authentication.getName());
        Sort sort = sortDir.equalsIgnoreCase("desc") ? 
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<MessageResponse> messages = messageService.getSentMessages(userId, pageable);
        return ResponseEntity.ok(messages);
    }

    @GetMapping("/report/{reportId}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<List<MessageResponse>> getMessagesByReport(
            @PathVariable UUID reportId) {
        
        List<MessageResponse> messages = messageService.getMessagesByReport(reportId);
        return ResponseEntity.ok(messages);
    }

    @PutMapping("/{messageId}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<MessageResponse> updateMessage(
            @PathVariable UUID messageId,
            @Valid @RequestBody UpdateMessageRequest request,
            Authentication authentication) {
        
        UUID userId = UUID.fromString(authentication.getName());
        MessageResponse response = messageService.updateMessage(messageId, userId, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{messageId}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<Void> deleteMessage(
            @PathVariable UUID messageId,
            Authentication authentication) {
        
        UUID userId = UUID.fromString(authentication.getName());
        messageService.deleteMessage(messageId, userId);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{messageId}/read")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<Void> markAsRead(
            @PathVariable UUID messageId,
            Authentication authentication) {
        
        UUID userId = UUID.fromString(authentication.getName());
        messageService.markMessageAsRead(messageId, userId);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/conversation/{userId}/read")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<Void> markConversationAsRead(
            @PathVariable UUID userId,
            Authentication authentication) {
        
        UUID currentUserId = UUID.fromString(authentication.getName());
        messageService.markConversationAsRead(userId, currentUserId);
        return ResponseEntity.ok().build();
    }
} 