package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.dto.education.CreateVideoTutorialRequest;
import com.crimeprevention.crime_backend.core.dto.education.VideoTutorialResponse;
import com.crimeprevention.crime_backend.core.service.interfaces.VideoTutorialService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/video-tutorials")
@RequiredArgsConstructor
@Slf4j
public class VideoTutorialController {
    
    private final VideoTutorialService videoTutorialService;
    
    /**
     * Upload a new video tutorial (Admin only)
     */
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<VideoTutorialResponse> createVideoTutorial(
            @RequestPart("video") MultipartFile videoFile,
            @RequestPart("request") @Valid CreateVideoTutorialRequest request,
            Authentication authentication) {
        
        UUID adminId = UUID.fromString(authentication.getName());
        log.info("Admin {} uploading video tutorial: {}", adminId, request.getTitle());
        
        try {
            VideoTutorialResponse response = videoTutorialService.createVideoTutorial(adminId, request, videoFile);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException e) {
            log.error("Validation error: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            log.error("Error creating video tutorial: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    /**
     * Get all active video tutorials (Public)
     */
    @GetMapping
    public ResponseEntity<List<VideoTutorialResponse>> getAllVideos() {
        List<VideoTutorialResponse> videos = videoTutorialService.getAllActiveVideos();
        return ResponseEntity.ok(videos);
    }
    
    /**
     * Get featured video tutorials (Public)
     */
    @GetMapping("/featured")
    public ResponseEntity<List<VideoTutorialResponse>> getFeaturedVideos() {
        List<VideoTutorialResponse> videos = videoTutorialService.getFeaturedVideos();
        return ResponseEntity.ok(videos);
    }
    
    /**
     * Get videos by category (Public)
     */
    @GetMapping("/category/{category}")
    public ResponseEntity<List<VideoTutorialResponse>> getVideosByCategory(@PathVariable String category) {
        List<VideoTutorialResponse> videos = videoTutorialService.getVideosByCategory(category);
        return ResponseEntity.ok(videos);
    }
    
    /**
     * Get video tutorial by ID (Public)
     */
    @GetMapping("/{id}")
    public ResponseEntity<VideoTutorialResponse> getVideoById(@PathVariable UUID id) {
        try {
            VideoTutorialResponse video = videoTutorialService.getVideoById(id);
            return ResponseEntity.ok(video);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    /**
     * Increment video views (Public)
     */
    @PutMapping("/{id}/views")
    public ResponseEntity<VideoTutorialResponse> incrementViews(@PathVariable UUID id) {
        try {
            VideoTutorialResponse video = videoTutorialService.incrementViews(id);
            return ResponseEntity.ok(video);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    /**
     * Delete video tutorial (Admin only)
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteVideoTutorial(
            @PathVariable UUID id,
            Authentication authentication) {
        
        UUID adminId = UUID.fromString(authentication.getName());
        log.info("Admin {} deleting video tutorial: {}", adminId, id);
        
        try {
            videoTutorialService.deleteVideoTutorial(id, adminId);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            log.error("Error deleting video tutorial: {}", e.getMessage());
            return ResponseEntity.notFound().build();
        }
    }
}

