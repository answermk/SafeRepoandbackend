package com.crimeprevention.crime_backend.core.service.interfaces;

import com.crimeprevention.crime_backend.core.dto.education.CreateVideoTutorialRequest;
import com.crimeprevention.crime_backend.core.dto.education.VideoTutorialResponse;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

public interface VideoTutorialService {
    VideoTutorialResponse createVideoTutorial(UUID adminId, CreateVideoTutorialRequest request, MultipartFile videoFile);
    List<VideoTutorialResponse> getAllActiveVideos();
    List<VideoTutorialResponse> getFeaturedVideos();
    List<VideoTutorialResponse> getVideosByCategory(String category);
    VideoTutorialResponse getVideoById(UUID id);
    void deleteVideoTutorial(UUID id, UUID adminId);
    VideoTutorialResponse incrementViews(UUID id);
}

