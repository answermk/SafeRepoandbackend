package com.crimeprevention.crime_backend.core.service.interfaces;

import com.crimeprevention.crime_backend.core.dto.feedback.FeedbackRequest;
import com.crimeprevention.crime_backend.core.dto.feedback.FeedbackResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

public interface FeedbackService {
    FeedbackResponse submitFeedback(UUID userId, FeedbackRequest request);
    Page<FeedbackResponse> getUserFeedbacks(UUID userId, Pageable pageable);
    Page<FeedbackResponse> getAllFeedbacks(Pageable pageable);
    FeedbackResponse updateFeedbackStatus(UUID feedbackId, String adminResponse);
    FeedbackResponse getFeedbackById(UUID feedbackId);
}

