package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.dto.forum.*;
import com.crimeprevention.crime_backend.core.service.interfaces.ForumService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/forum")
@RequiredArgsConstructor
public class ForumController {
    
    private final ForumService forumService;
    
    @PostMapping("/posts")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<ForumPostResponse> createPost(
            @Valid @RequestBody CreateForumPostRequest request,
            Authentication authentication
    ) {
        UUID userId = UUID.fromString(authentication.getName());
        ForumPostResponse response = forumService.createPost(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
    
    @GetMapping("/posts/{postId}")
    public ResponseEntity<ForumPostResponse> getPost(@PathVariable UUID postId) {
        ForumPostResponse response = forumService.getPostById(postId);
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/posts")
    public ResponseEntity<Page<ForumPostResponse>> getAllPosts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir,
            @RequestParam(required = false) String priority,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String location,
            @RequestParam(required = false) String search
    ) {
        Sort sort = sortDir.equalsIgnoreCase("desc") ? 
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<ForumPostResponse> posts;
        if (priority != null || status != null || category != null || location != null || search != null) {
            posts = forumService.getPostsWithFilters(priority, status, category, location, search, pageable);
        } else {
            posts = forumService.getAllPosts(pageable);
        }
        
        return ResponseEntity.ok(posts);
    }
    
    @PutMapping("/posts/{postId}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<ForumPostResponse> updatePost(
            @PathVariable UUID postId,
            @Valid @RequestBody UpdateForumPostRequest request,
            Authentication authentication
    ) {
        UUID userId = UUID.fromString(authentication.getName());
        ForumPostResponse response = forumService.updatePost(postId, request, userId);
        return ResponseEntity.ok(response);
    }
    
    @DeleteMapping("/posts/{postId}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<Void> deletePost(
            @PathVariable UUID postId,
            Authentication authentication
    ) {
        UUID userId = UUID.fromString(authentication.getName());
        forumService.deletePost(postId, userId);
        return ResponseEntity.noContent().build();
    }
    
    @PutMapping("/posts/{postId}/flag")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<ForumPostResponse> flagPost(
            @PathVariable UUID postId,
            @Valid @RequestBody FlagForumPostRequest request
    ) {
        ForumPostResponse response = forumService.flagPost(postId, request);
        return ResponseEntity.ok(response);
    }
    
    @PutMapping("/posts/{postId}/resolve")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<ForumPostResponse> resolvePost(
            @PathVariable UUID postId,
            @Valid @RequestBody ResolveForumPostRequest request
    ) {
        ForumPostResponse response = forumService.resolvePost(postId, request);
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/posts/{postId}/replies")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<ForumReplyResponse> createReply(
            @PathVariable UUID postId,
            @Valid @RequestBody CreateForumReplyRequest request,
            Authentication authentication
    ) {
        UUID userId = UUID.fromString(authentication.getName());
        ForumReplyResponse response = forumService.createReply(postId, userId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
    
    @GetMapping("/posts/{postId}/replies")
    public ResponseEntity<List<ForumReplyResponse>> getPostReplies(
            @PathVariable UUID postId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "100") int size
    ) {
        if (size >= 1000) {
            // Return all replies without pagination
            List<ForumReplyResponse> replies = forumService.getPostReplies(postId);
            return ResponseEntity.ok(replies);
        } else {
            // Return paginated replies
            Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").ascending());
            Page<ForumReplyResponse> replies = forumService.getPostReplies(postId, pageable);
            return ResponseEntity.ok(replies.getContent());
        }
    }
}

