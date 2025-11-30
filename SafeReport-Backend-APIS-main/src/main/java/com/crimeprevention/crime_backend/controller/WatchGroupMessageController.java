package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.dto.message.CreateWatchGroupMessageRequest;
import com.crimeprevention.crime_backend.core.dto.message.WatchGroupMessageResponse;
import com.crimeprevention.crime_backend.core.service.interfaces.WatchGroupMessageService;
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
@RequestMapping("/api/watch-group-messages")
@RequiredArgsConstructor
@Slf4j
public class WatchGroupMessageController {

    private final WatchGroupMessageService watchGroupMessageService;

    @PostMapping("/{groupId}/send")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<WatchGroupMessageResponse> sendWatchGroupMessage(
            @PathVariable UUID groupId,
            @Valid @RequestBody CreateWatchGroupMessageRequest request,
            Authentication authentication) {
        
        UUID senderId = UUID.fromString(authentication.getName());
        WatchGroupMessageResponse response = watchGroupMessageService.sendMessage(groupId, senderId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/{groupId}/messages")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<Page<WatchGroupMessageResponse>> getWatchGroupMessages(
            @PathVariable UUID groupId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "sentAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {
        
        Sort sort = sortDir.equalsIgnoreCase("desc") ? 
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<WatchGroupMessageResponse> messages = watchGroupMessageService.getMessagesByGroup(groupId, pageable);
        return ResponseEntity.ok(messages);
    }

    @GetMapping("/{groupId}/messages/all")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<List<WatchGroupMessageResponse>> getAllWatchGroupMessages(
            @PathVariable UUID groupId) {
        
        List<WatchGroupMessageResponse> messages = watchGroupMessageService.getMessagesByGroup(groupId);
        return ResponseEntity.ok(messages);
    }
} 