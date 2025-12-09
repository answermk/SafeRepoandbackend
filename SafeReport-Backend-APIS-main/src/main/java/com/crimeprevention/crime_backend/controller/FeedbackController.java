package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.dto.feedback.FeedbackRequest;
import com.crimeprevention.crime_backend.core.dto.feedback.FeedbackResponse;
import com.crimeprevention.crime_backend.core.service.interfaces.FeedbackService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/feedback")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class FeedbackController {
    
    private final FeedbackService feedbackService;
    
    // Submit feedback (authenticated users)
    @PostMapping
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<FeedbackResponse> submitFeedback(
            @Valid @RequestBody FeedbackRequest request,
            Authentication authentication
    ) {
        try {
            UUID userId = UUID.fromString(authentication.getName());
            FeedbackResponse response = feedbackService.submitFeedback(userId, request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    // Get user's own feedbacks
    @GetMapping("/my-feedbacks")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Page<FeedbackResponse>> getMyFeedbacks(
            Authentication authentication,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        try {
            UUID userId = UUID.fromString(authentication.getName());
            Pageable pageable = PageRequest.of(page, size);
            Page<FeedbackResponse> feedbacks = feedbackService.getUserFeedbacks(userId, pageable);
            return ResponseEntity.ok(feedbacks);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    // Get all feedbacks (admin only)
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Page<FeedbackResponse>> getAllFeedbacks(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        try {
            Pageable pageable = PageRequest.of(page, size);
            Page<FeedbackResponse> feedbacks = feedbackService.getAllFeedbacks(pageable);
            return ResponseEntity.ok(feedbacks);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    // Get feedback by ID
    @GetMapping("/{feedbackId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<FeedbackResponse> getFeedbackById(@PathVariable UUID feedbackId) {
        try {
            FeedbackResponse response = feedbackService.getFeedbackById(feedbackId);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    // Update feedback status (admin only)
    @PutMapping("/{feedbackId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<FeedbackResponse> updateFeedbackStatus(
            @PathVariable UUID feedbackId,
            @RequestBody(required = false) String adminResponse
    ) {
        try {
            FeedbackResponse response = feedbackService.updateFeedbackStatus(feedbackId, adminResponse);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
}

