package com.crimeprevention.crime_backend.core.repo.forum;

import com.crimeprevention.crime_backend.core.model.forum.ForumReply;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ForumReplyRepository extends JpaRepository<ForumReply, UUID> {
    
    // Find all replies for a post
    List<ForumReply> findByPostIdOrderByCreatedAtAsc(UUID postId);
    
    // Find all replies for a post with pagination
    Page<ForumReply> findByPostIdOrderByCreatedAtAsc(UUID postId, Pageable pageable);
    
    // Count replies for a post
    long countByPostId(UUID postId);
    
    // Find replies by author
    Page<ForumReply> findByAuthorIdOrderByCreatedAtDesc(UUID authorId, Pageable pageable);
    
    // Find official replies for a post
    List<ForumReply> findByPostIdAndIsOfficialTrueOrderByCreatedAtAsc(UUID postId);
}

