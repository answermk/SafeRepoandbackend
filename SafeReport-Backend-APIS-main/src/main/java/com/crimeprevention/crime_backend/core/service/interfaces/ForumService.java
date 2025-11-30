package com.crimeprevention.crime_backend.core.service.interfaces;

import com.crimeprevention.crime_backend.core.dto.forum.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface ForumService {
    
    ForumPostResponse createPost(UUID authorId, CreateForumPostRequest request);
    
    ForumPostResponse getPostById(UUID postId);
    
    Page<ForumPostResponse> getAllPosts(Pageable pageable);
    
    Page<ForumPostResponse> getPostsWithFilters(
        String priority,
        String status,
        String category,
        String location,
        String search,
        Pageable pageable
    );
    
    ForumPostResponse updatePost(UUID postId, UpdateForumPostRequest request, UUID currentUserId);
    
    void deletePost(UUID postId, UUID currentUserId);
    
    ForumPostResponse flagPost(UUID postId, FlagForumPostRequest request);
    
    ForumPostResponse resolvePost(UUID postId, ResolveForumPostRequest request);
    
    ForumReplyResponse createReply(UUID postId, UUID authorId, CreateForumReplyRequest request);
    
    List<ForumReplyResponse> getPostReplies(UUID postId);
    
    Page<ForumReplyResponse> getPostReplies(UUID postId, Pageable pageable);
}

