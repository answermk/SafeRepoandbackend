package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.dto.education.CreateVideoTutorialRequest;
import com.crimeprevention.crime_backend.core.dto.education.VideoTutorialResponse;
import com.crimeprevention.crime_backend.core.model.education.VideoTutorial;
import com.crimeprevention.crime_backend.core.repo.education.VideoTutorialRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.VideoTutorialService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class VideoTutorialServiceImpl implements VideoTutorialService {
    
    private static final String VIDEO_UPLOAD_DIR = "uploads/videos";
    private static final long MAX_VIDEO_SIZE = 100 * 1024 * 1024; // 100MB
    
    private final VideoTutorialRepository videoTutorialRepository;
    
    static {
        // Create video upload directory if it doesn't exist
        try {
            Path videoPath = Paths.get(VIDEO_UPLOAD_DIR).toAbsolutePath().normalize();
            if (!Files.exists(videoPath)) {
                Files.createDirectories(videoPath);
                log.info("Created video upload directory: {}", videoPath);
            }
        } catch (IOException e) {
            log.error("Failed to create video upload directory", e);
        }
    }
    
    @Override
    @Transactional
    public VideoTutorialResponse createVideoTutorial(UUID adminId, CreateVideoTutorialRequest request, MultipartFile videoFile) {
        try {
            // Validate video file
            if (videoFile == null || videoFile.isEmpty()) {
                throw new IllegalArgumentException("Video file is required");
            }
            
            // Validate file type
            String contentType = videoFile.getContentType();
            if (contentType == null || !contentType.startsWith("video/")) {
                throw new IllegalArgumentException("Invalid file type. Only video files are allowed");
            }
            
            // Validate file size
            if (videoFile.getSize() > MAX_VIDEO_SIZE) {
                throw new IllegalArgumentException("Video file size exceeds 100MB limit");
            }
            
            // Generate unique filename
            String originalFilename = videoFile.getOriginalFilename();
            String extension = originalFilename != null && originalFilename.contains(".") 
                ? originalFilename.substring(originalFilename.lastIndexOf(".")) 
                : "";
            String filename = UUID.randomUUID().toString() + extension;
            
            // Create subdirectory by date (YYYY/MM) for organization
            java.time.LocalDate now = java.time.LocalDate.now();
            String subDir = now.getYear() + "/" + String.format("%02d", now.getMonthValue());
            Path uploadBasePath = Paths.get(VIDEO_UPLOAD_DIR).toAbsolutePath().normalize();
            Path subDirPath = uploadBasePath.resolve(subDir);
            if (!Files.exists(subDirPath)) {
                Files.createDirectories(subDirPath);
            }
            
            // Save video file
            Path filePath = subDirPath.resolve(filename);
            Files.copy(videoFile.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
            
            // Create video URL
            String videoUrl = "/api/files/videos/" + subDir + "/" + filename;
            
            // Create video tutorial entity
            VideoTutorial videoTutorial = VideoTutorial.builder()
                .title(request.getTitle())
                .description(request.getDescription())
                .videoUrl(videoUrl)
                .durationSeconds(request.getDurationSeconds())
                .fileSize(videoFile.getSize())
                .category(request.getCategory())
                .isFeatured(request.getIsFeatured() != null ? request.getIsFeatured() : false)
                .isActive(true)
                .views(0L)
                .uploadedBy(adminId)
                .build();
            
            videoTutorial = videoTutorialRepository.save(videoTutorial);
            
            log.info("Video tutorial created: {} by admin {}", videoTutorial.getId(), adminId);
            return toResponse(videoTutorial);
            
        } catch (IOException e) {
            log.error("Error saving video file", e);
            throw new RuntimeException("Failed to save video file: " + e.getMessage());
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<VideoTutorialResponse> getAllActiveVideos() {
        List<VideoTutorial> videos = videoTutorialRepository.findByIsActiveTrueOrderByCreatedAtDesc();
        return videos.stream()
            .map(this::toResponse)
            .collect(Collectors.toList());
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<VideoTutorialResponse> getFeaturedVideos() {
        List<VideoTutorial> videos = videoTutorialRepository.findByIsFeaturedTrueAndIsActiveTrueOrderByCreatedAtDesc();
        return videos.stream()
            .map(this::toResponse)
            .collect(Collectors.toList());
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<VideoTutorialResponse> getVideosByCategory(String category) {
        List<VideoTutorial> videos = videoTutorialRepository.findByCategoryAndIsActiveTrueOrderByCreatedAtDesc(category);
        return videos.stream()
            .map(this::toResponse)
            .collect(Collectors.toList());
    }
    
    @Override
    @Transactional(readOnly = true)
    public VideoTutorialResponse getVideoById(UUID id) {
        VideoTutorial video = videoTutorialRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Video tutorial not found"));
        return toResponse(video);
    }
    
    @Override
    @Transactional
    public void deleteVideoTutorial(UUID id, UUID adminId) {
        VideoTutorial video = videoTutorialRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Video tutorial not found"));
        
        // Verify admin owns this video or is admin
        if (!video.getUploadedBy().equals(adminId)) {
            throw new RuntimeException("Unauthorized: You can only delete videos you uploaded");
        }
        
        // Delete video file from disk
        try {
            String videoUrl = video.getVideoUrl();
            if (videoUrl != null && videoUrl.startsWith("/api/files/videos/")) {
                String relativePath = videoUrl.substring("/api/files/videos/".length());
                Path uploadBasePath = Paths.get(VIDEO_UPLOAD_DIR).toAbsolutePath().normalize();
                Path filePath = uploadBasePath.resolve(relativePath).normalize();
                
                if (Files.exists(filePath)) {
                    Files.delete(filePath);
                    log.info("Deleted video file: {}", filePath);
                }
            }
        } catch (IOException e) {
            log.warn("Failed to delete video file: {}", e.getMessage());
        }
        
        // Delete from database
        videoTutorialRepository.delete(video);
        log.info("Video tutorial deleted: {} by admin {}", id, adminId);
    }
    
    @Override
    @Transactional
    public VideoTutorialResponse incrementViews(UUID id) {
        VideoTutorial video = videoTutorialRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Video tutorial not found"));
        
        video.setViews(video.getViews() + 1);
        video = videoTutorialRepository.save(video);
        
        return toResponse(video);
    }
    
    private VideoTutorialResponse toResponse(VideoTutorial video) {
        String duration = formatDuration(video.getDurationSeconds());
        
        return VideoTutorialResponse.builder()
            .id(video.getId())
            .title(video.getTitle())
            .description(video.getDescription())
            .videoUrl(video.getVideoUrl())
            .thumbnailUrl(video.getThumbnailUrl())
            .durationSeconds(video.getDurationSeconds())
            .duration(duration)
            .fileSize(video.getFileSize())
            .category(video.getCategory())
            .isFeatured(video.getIsFeatured())
            .isActive(video.getIsActive())
            .views(video.getViews())
            .uploadedBy(video.getUploadedBy())
            .createdAt(video.getCreatedAt())
            .updatedAt(video.getUpdatedAt())
            .build();
    }
    
    private String formatDuration(Integer seconds) {
        if (seconds == null || seconds == 0) {
            return "0:00";
        }
        
        int minutes = seconds / 60;
        int remainingSeconds = seconds % 60;
        return String.format("%d:%02d", minutes, remainingSeconds);
    }
}

