package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.dto.forum.*;
import com.crimeprevention.crime_backend.core.exception.ResourceNotFoundException;
import com.crimeprevention.crime_backend.core.model.enums.ForumPriority;
import com.crimeprevention.crime_backend.core.model.enums.ForumStatus;
import com.crimeprevention.crime_backend.core.model.forum.ForumPost;
import com.crimeprevention.crime_backend.core.model.forum.ForumReply;
import com.crimeprevention.crime_backend.core.model.user.User;
import com.crimeprevention.crime_backend.core.repo.forum.ForumPostRepository;
import com.crimeprevention.crime_backend.core.repo.forum.ForumReplyRepository;
import com.crimeprevention.crime_backend.core.repo.user.UserRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.ForumService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ForumServiceImpl implements ForumService {
    
    private final ForumPostRepository forumPostRepository;
    private final ForumReplyRepository forumReplyRepository;
    private final UserRepository userRepository;
    
    @Override
    @Transactional
    public ForumPostResponse createPost(UUID authorId, CreateForumPostRequest request) {
        User author = userRepository.findById(authorId)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        
        ForumPost post = ForumPost.builder()
            .title(request.getTitle())
            .content(request.getContent())
            .authorId(authorId)
            .author(author)
            .priority(request.getPriority())
            .category(request.getCategory())
            .location(request.getLocation())
            .tags(request.getTags() != null ? request.getTags() : List.of())
            .status(ForumStatus.PENDING)
            .views(0)
            .repliesCount(0)
            .flagged(false)
            .resolved(false)
            .hasOfficialResponse(false)
            .build();
        
        post = forumPostRepository.save(post);
        return toPostResponse(post);
    }
    
    @Override
    @Transactional(readOnly = true)
    public ForumPostResponse getPostById(UUID postId) {
        ForumPost post = forumPostRepository.findById(postId)
            .orElseThrow(() -> new ResourceNotFoundException("Post not found"));
        
        // Increment views
        post.incrementViews();
        forumPostRepository.save(post);
        
        return toPostResponse(post);
    }
    
    @Override
    @Transactional(readOnly = true)
    public Page<ForumPostResponse> getAllPosts(Pageable pageable) {
        return forumPostRepository.findAllByOrderByCreatedAtDesc(pageable)
            .map(this::toPostResponse);
    }
    
    @Override
    @Transactional(readOnly = true)
    public Page<ForumPostResponse> getPostsWithFilters(
        String priority,
        String status,
        String category,
        String location,
        String search,
        Pageable pageable
    ) {
        ForumPriority priorityEnum = null;
        if (priority != null && !priority.equals("all")) {
            try {
                priorityEnum = ForumPriority.valueOf(priority.toUpperCase());
            } catch (IllegalArgumentException e) {
                log.warn("Invalid priority value: {}", priority);
            }
        }
        
        ForumStatus statusEnum = null;
        if (status != null && !status.equals("all")) {
            try {
                statusEnum = ForumStatus.valueOf(status.toUpperCase());
            } catch (IllegalArgumentException e) {
                log.warn("Invalid status value: {}", status);
            }
        }
        
        String categoryFilter = (category != null && !category.equals("all")) ? category : null;
        String locationFilter = (location != null && !location.isEmpty()) ? location : null;
        String searchFilter = (search != null && !search.isEmpty()) ? search : null;
        
        return forumPostRepository.findPostsWithFilters(
            priorityEnum,
            statusEnum,
            categoryFilter,
            locationFilter,
            searchFilter,
            pageable
        ).map(this::toPostResponse);
    }
    
    @Override
    @Transactional
    public ForumPostResponse updatePost(UUID postId, UpdateForumPostRequest request, UUID currentUserId) {
        ForumPost post = forumPostRepository.findById(postId)
            .orElseThrow(() -> new ResourceNotFoundException("Post not found"));
        
        // Check if user is the author or admin/officer
        if (!post.getAuthorId().equals(currentUserId)) {
            // Check if user is admin/officer (you may need to add role check here)
            throw new RuntimeException("Not authorized to update this post");
        }
        
        if (request.getTitle() != null) {
            post.setTitle(request.getTitle());
        }
        if (request.getContent() != null) {
            post.setContent(request.getContent());
        }
        if (request.getPriority() != null) {
            post.setPriority(request.getPriority());
        }
        if (request.getStatus() != null) {
            post.setStatus(request.getStatus());
        }
        if (request.getCategory() != null) {
            post.setCategory(request.getCategory());
        }
        if (request.getTags() != null) {
            post.setTags(request.getTags());
        }
        if (request.getFlagged() != null) {
            post.setFlagged(request.getFlagged());
        }
        
        post = forumPostRepository.save(post);
        return toPostResponse(post);
    }
    
    @Override
    @Transactional
    public void deletePost(UUID postId, UUID currentUserId) {
        ForumPost post = forumPostRepository.findById(postId)
            .orElseThrow(() -> new ResourceNotFoundException("Post not found"));
        
        // Check if user is the author or admin/officer
        if (!post.getAuthorId().equals(currentUserId)) {
            // Check if user is admin/officer (you may need to add role check here)
            throw new RuntimeException("Not authorized to delete this post");
        }
        
        // Delete all replies first
        List<ForumReply> replies = forumReplyRepository.findByPostIdOrderByCreatedAtAsc(postId);
        forumReplyRepository.deleteAll(replies);
        
        forumPostRepository.deleteById(postId);
    }
    
    @Override
    @Transactional
    public ForumPostResponse flagPost(UUID postId, FlagForumPostRequest request) {
        ForumPost post = forumPostRepository.findById(postId)
            .orElseThrow(() -> new ResourceNotFoundException("Post not found"));
        
        post.setFlagged(request.getFlagged());
        post = forumPostRepository.save(post);
        return toPostResponse(post);
    }
    
    @Override
    @Transactional
    public ForumPostResponse resolvePost(UUID postId, ResolveForumPostRequest request) {
        ForumPost post = forumPostRepository.findById(postId)
            .orElseThrow(() -> new ResourceNotFoundException("Post not found"));
        
        post.setResolved(true);
        post.setStatus(ForumStatus.RESOLVED);
        post.setResolvedAt(Instant.now());
        if (request.getResolutionNote() != null) {
            post.setOfficialResponse(request.getResolutionNote());
            post.setHasOfficialResponse(true);
        }
        
        post = forumPostRepository.save(post);
        return toPostResponse(post);
    }
    
    @Override
    @Transactional
    public ForumReplyResponse createReply(UUID postId, UUID authorId, CreateForumReplyRequest request) {
        ForumPost post = forumPostRepository.findById(postId)
            .orElseThrow(() -> new ResourceNotFoundException("Post not found"));
        
        User author = userRepository.findById(authorId)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        
        // Validate parent reply if provided
        ForumReply parentReply = null;
        if (request.getParentReplyId() != null) {
            parentReply = forumReplyRepository.findById(request.getParentReplyId())
                .orElseThrow(() -> new ResourceNotFoundException("Parent reply not found"));
            // Ensure parent reply belongs to the same post
            if (!parentReply.getPostId().equals(postId)) {
                throw new IllegalArgumentException("Parent reply must belong to the same post");
            }
        }
        
        ForumReply reply = ForumReply.builder()
            .postId(postId)
            .post(post)
            .content(request.getContent())
            .authorId(authorId)
            .author(author)
            .isOfficial(request.getIsOfficial() != null ? request.getIsOfficial() : false)
            .parentReplyId(request.getParentReplyId())
            .parentReply(parentReply)
            .build();
        
        reply = forumReplyRepository.save(reply);
        
        // Update post reply count
        post.incrementRepliesCount();
        
        // Update post status if it's an official reply
        if (reply.getIsOfficial()) {
            post.setStatus(ForumStatus.RESPONDED);
            post.setHasOfficialResponse(true);
            if (post.getOfficialResponse() == null || post.getOfficialResponse().isEmpty()) {
                post.setOfficialResponse(request.getContent());
            }
        }
        
        forumPostRepository.save(post);
        
        return toReplyResponse(reply);
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<ForumReplyResponse> getPostReplies(UUID postId) {
        List<ForumReply> allReplies = forumReplyRepository.findByPostIdOrderByCreatedAtAsc(postId);
        
        // Build nested structure
        return buildNestedReplies(allReplies, null);
    }
    
    private List<ForumReplyResponse> buildNestedReplies(List<ForumReply> allReplies, UUID parentId) {
        return allReplies.stream()
            .filter(reply -> {
                if (parentId == null) {
                    return reply.getParentReplyId() == null;
                } else {
                    return parentId.equals(reply.getParentReplyId());
                }
            })
            .map(reply -> {
                ForumReplyResponse response = toReplyResponse(reply);
                // Recursively build nested replies
                List<ForumReplyResponse> nested = buildNestedReplies(allReplies, reply.getId());
                response.setNestedReplies(nested.isEmpty() ? null : nested);
                return response;
            })
            .collect(Collectors.toList());
    }
    
    @Override
    @Transactional(readOnly = true)
    public Page<ForumReplyResponse> getPostReplies(UUID postId, Pageable pageable) {
        return forumReplyRepository.findByPostIdOrderByCreatedAtAsc(postId, pageable)
            .map(this::toReplyResponse);
    }
    
    private ForumPostResponse toPostResponse(ForumPost post) {
        ForumPostResponse.AuthorDTO authorDTO = null;
        if (post.getAuthor() != null) {
            authorDTO = ForumPostResponse.AuthorDTO.builder()
                .id(post.getAuthor().getId())
                .username(post.getAuthor().getUsername())
                .fullName(post.getAuthor().getFullName())
                .email(post.getAuthor().getEmail())
                .build();
        }
        
        return ForumPostResponse.builder()
            .id(post.getId())
            .title(post.getTitle())
            .content(post.getContent())
            .author(authorDTO)
            .authorId(post.getAuthorId())
            .views(post.getViews())
            .replies(post.getRepliesCount())
            .priority(post.getPriority())
            .status(post.getStatus())
            .category(post.getCategory())
            .tags(post.getTags())
            .hasOfficialResponse(post.getHasOfficialResponse())
            .officialResponse(post.getOfficialResponse())
            .flagged(post.getFlagged())
            .resolved(post.getResolved())
            .resolvedAt(post.getResolvedAt())
            .location(post.getLocation())
            .createdAt(post.getCreatedAt())
            .updatedAt(post.getUpdatedAt())
            .build();
    }
    
    private ForumReplyResponse toReplyResponse(ForumReply reply) {
        ForumReplyResponse.AuthorDTO authorDTO = null;
        if (reply.getAuthor() != null) {
            authorDTO = ForumReplyResponse.AuthorDTO.builder()
                .id(reply.getAuthor().getId())
                .username(reply.getAuthor().getUsername())
                .fullName(reply.getAuthor().getFullName())
                .email(reply.getAuthor().getEmail())
                .build();
        }
        
        return ForumReplyResponse.builder()
            .id(reply.getId())
            .postId(reply.getPostId())
            .content(reply.getContent())
            .author(authorDTO)
            .authorId(reply.getAuthorId())
            .isOfficial(reply.getIsOfficial())
            .createdAt(reply.getCreatedAt())
            .updatedAt(reply.getUpdatedAt())
            .parentReplyId(reply.getParentReplyId())
            .build();
    }
}

