package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.dto.message.CaseMessageResponse;
import com.crimeprevention.crime_backend.core.dto.message.CreateCaseMessageRequest;
import com.crimeprevention.crime_backend.core.dto.message.UpdateCaseMessageRequest;
import com.crimeprevention.crime_backend.core.service.interfaces.CaseMessageService;
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
@RequestMapping("/api/case-messages")
@RequiredArgsConstructor
@Slf4j
public class CaseMessageController {

    private final CaseMessageService caseMessageService;

    @PostMapping("/send")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<CaseMessageResponse> sendCaseMessage(
            @Valid @RequestBody CreateCaseMessageRequest request,
            Authentication authentication) {
        
        UUID senderId = UUID.fromString(authentication.getName());
        CaseMessageResponse response = caseMessageService.sendCaseMessage(senderId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/conversation/{reportId}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<Page<CaseMessageResponse>> getConversation(
            @PathVariable UUID reportId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "timestamp") String sortBy,
            @RequestParam(defaultValue = "asc") String sortDir) {
        
        Sort sort = sortDir.equalsIgnoreCase("desc") ? 
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<CaseMessageResponse> messages = caseMessageService.getConversation(reportId, pageable);
        return ResponseEntity.ok(messages);
    }

    @GetMapping("/conversation/{reportId}/all")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<List<CaseMessageResponse>> getConversationAll(
            @PathVariable UUID reportId) {
        
        List<CaseMessageResponse> messages = caseMessageService.getConversationAll(reportId);
        return ResponseEntity.ok(messages);
    }

    @PutMapping("/{messageId}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<CaseMessageResponse> updateCaseMessage(
            @PathVariable UUID messageId,
            @Valid @RequestBody UpdateCaseMessageRequest request,
            Authentication authentication) {
        
        UUID userId = UUID.fromString(authentication.getName());
        CaseMessageResponse response = caseMessageService.updateCaseMessage(messageId, userId, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{messageId}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'ADMIN')")
    public ResponseEntity<Void> deleteCaseMessage(
            @PathVariable UUID messageId,
            Authentication authentication) {
        
        UUID userId = UUID.fromString(authentication.getName());
        caseMessageService.deleteCaseMessage(messageId, userId);
        return ResponseEntity.noContent().build();
    }
} 