package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.dto.feedback.FeedbackRequest;
import com.crimeprevention.crime_backend.core.dto.feedback.FeedbackResponse;
import com.crimeprevention.crime_backend.core.model.feedback.Feedback;
import com.crimeprevention.crime_backend.core.model.feedback.FeedbackStatus;
import com.crimeprevention.crime_backend.core.repo.feedback.FeedbackRepository;
import com.crimeprevention.crime_backend.core.repo.user.UserRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.FeedbackService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class FeedbackServiceImpl implements FeedbackService {
    
    private final FeedbackRepository feedbackRepository;
    private final UserRepository userRepository;
    
    @Override
    @Transactional
    public FeedbackResponse submitFeedback(UUID userId, FeedbackRequest request) {
        // Verify user exists
        userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        Feedback feedback = Feedback.builder()
            .message(request.getMessage())
            .userId(userId)
            .status(FeedbackStatus.PENDING)
            .build();
        
        feedback = feedbackRepository.save(feedback);
        
        return mapToResponse(feedback);
    }
    
    @Override
    public Page<FeedbackResponse> getUserFeedbacks(UUID userId, Pageable pageable) {
        return feedbackRepository.findByUserId(userId, pageable)
            .map(this::mapToResponse);
    }
    
    @Override
    public Page<FeedbackResponse> getAllFeedbacks(Pageable pageable) {
        return feedbackRepository.findAll(pageable)
            .map(this::mapToResponse);
    }
    
    @Override
    @Transactional
    public FeedbackResponse updateFeedbackStatus(UUID feedbackId, String adminResponse) {
        Feedback feedback = feedbackRepository.findById(feedbackId)
            .orElseThrow(() -> new RuntimeException("Feedback not found"));
        
        feedback.setStatus(FeedbackStatus.REVIEWED);
        if (adminResponse != null && !adminResponse.trim().isEmpty()) {
            feedback.setAdminResponse(adminResponse);
        }
        
        feedback = feedbackRepository.save(feedback);
        return mapToResponse(feedback);
    }
    
    @Override
    public FeedbackResponse getFeedbackById(UUID feedbackId) {
        Feedback feedback = feedbackRepository.findById(feedbackId)
            .orElseThrow(() -> new RuntimeException("Feedback not found"));
        return mapToResponse(feedback);
    }
    
    private FeedbackResponse mapToResponse(Feedback feedback) {
        String userEmail = null;
        String userName = null;
        
        if (feedback.getUser() != null) {
            userEmail = feedback.getUser().getEmail();
            userName = feedback.getUser().getFullName();
        } else if (feedback.getUserId() != null) {
            // Load user if not already loaded
            var userOpt = userRepository.findById(feedback.getUserId());
            if (userOpt.isPresent()) {
                var user = userOpt.get();
                userEmail = user.getEmail();
                userName = user.getFullName();
            }
        }
        
        return FeedbackResponse.builder()
            .id(feedback.getId())
            .message(feedback.getMessage())
            .userId(feedback.getUserId())
            .userEmail(userEmail)
            .userName(userName)
            .status(feedback.getStatus())
            .adminResponse(feedback.getAdminResponse())
            .createdAt(feedback.getCreatedAt())
            .updatedAt(feedback.getUpdatedAt())
            .build();
    }
}

