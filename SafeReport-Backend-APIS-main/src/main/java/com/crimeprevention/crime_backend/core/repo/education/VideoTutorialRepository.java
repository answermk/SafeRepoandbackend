package com.crimeprevention.crime_backend.core.repo.education;

import com.crimeprevention.crime_backend.core.model.education.VideoTutorial;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface VideoTutorialRepository extends JpaRepository<VideoTutorial, UUID> {
    
    List<VideoTutorial> findByIsActiveTrueOrderByCreatedAtDesc();
    
    List<VideoTutorial> findByIsFeaturedTrueAndIsActiveTrueOrderByCreatedAtDesc();
    
    List<VideoTutorial> findByCategoryAndIsActiveTrueOrderByCreatedAtDesc(String category);
}

