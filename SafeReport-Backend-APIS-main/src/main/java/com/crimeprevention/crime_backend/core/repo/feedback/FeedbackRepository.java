package com.crimeprevention.crime_backend.core.repo.feedback;

import com.crimeprevention.crime_backend.core.model.feedback.Feedback;
import com.crimeprevention.crime_backend.core.model.feedback.FeedbackStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface FeedbackRepository extends JpaRepository<Feedback, UUID> {
    List<Feedback> findByUserId(UUID userId);
    Page<Feedback> findByUserId(UUID userId, Pageable pageable);
    Page<Feedback> findByStatus(FeedbackStatus status, Pageable pageable);
    Page<Feedback> findAll(Pageable pageable);
}

