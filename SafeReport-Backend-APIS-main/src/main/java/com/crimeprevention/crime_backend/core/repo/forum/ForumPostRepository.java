package com.crimeprevention.crime_backend.core.repo.forum;

import com.crimeprevention.crime_backend.core.model.forum.ForumPost;
import com.crimeprevention.crime_backend.core.model.enums.ForumPriority;
import com.crimeprevention.crime_backend.core.model.enums.ForumStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface ForumPostRepository extends JpaRepository<ForumPost, UUID> {
    
    // Find all posts with pagination
    Page<ForumPost> findAllByOrderByCreatedAtDesc(Pageable pageable);
    
    // Find posts by priority
    Page<ForumPost> findByPriorityOrderByCreatedAtDesc(ForumPriority priority, Pageable pageable);
    
    // Find posts by status
    Page<ForumPost> findByStatusOrderByCreatedAtDesc(ForumStatus status, Pageable pageable);
    
    // Find posts by category
    Page<ForumPost> findByCategoryOrderByCreatedAtDesc(String category, Pageable pageable);
    
    // Find posts by author
    Page<ForumPost> findByAuthorIdOrderByCreatedAtDesc(UUID authorId, Pageable pageable);
    
    // Find flagged posts
    Page<ForumPost> findByFlaggedTrueOrderByCreatedAtDesc(Pageable pageable);
    
    // Find resolved posts
    Page<ForumPost> findByResolvedTrueOrderByCreatedAtDesc(Pageable pageable);
    
    // Search posts by title or content
    @Query("SELECT p FROM ForumPost p WHERE " +
           "LOWER(p.title) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(p.content) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(p.category) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(p.location) LIKE LOWER(CONCAT('%', :search, '%'))")
    Page<ForumPost> searchPosts(@Param("search") String search, Pageable pageable);
    
    // Find posts with filters
    @Query("SELECT p FROM ForumPost p WHERE " +
           "(:priority IS NULL OR p.priority = :priority) AND " +
           "(:status IS NULL OR p.status = :status) AND " +
           "(:category IS NULL OR p.category = :category) AND " +
           "(:location IS NULL OR LOWER(p.location) LIKE LOWER(CONCAT('%', :location, '%'))) AND " +
           "(:search IS NULL OR LOWER(p.title) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(p.content) LIKE LOWER(CONCAT('%', :search, '%'))) " +
           "ORDER BY p.createdAt DESC")
    Page<ForumPost> findPostsWithFilters(
        @Param("priority") ForumPriority priority,
        @Param("status") ForumStatus status,
        @Param("category") String category,
        @Param("location") String location,
        @Param("search") String search,
        Pageable pageable
    );
}

