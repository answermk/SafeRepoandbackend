package com.crimeprevention.crime_backend.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/upload")
@RequiredArgsConstructor
@Slf4j
public class FileUploadController {

    private static final String UPLOAD_DIR = "uploads";
    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB

    static {
        // Create upload directory if it doesn't exist
        try {
            Path uploadPath = Paths.get(UPLOAD_DIR);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }
        } catch (IOException e) {
            log.error("Failed to create upload directory", e);
        }
    }

    @PostMapping
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<?> uploadFile(@RequestParam("file") MultipartFile file) {
        try {
            // Validate authentication
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication == null || !authentication.isAuthenticated()) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
            }

            // Validate file
            if (file == null || file.isEmpty()) {
                return ResponseEntity.badRequest().body(createErrorResponse("File is required"));
            }

            // Validate file size
            if (file.getSize() > MAX_FILE_SIZE) {
                return ResponseEntity.badRequest().body(createErrorResponse("File size exceeds 10MB limit"));
            }

            // Validate file type
            String contentType = file.getContentType();
            if (contentType == null || (!contentType.startsWith("image/") && 
                !contentType.equals("application/pdf") && 
                !contentType.equals("application/msword") &&
                !contentType.equals("application/vnd.openxmlformats-officedocument.wordprocessingml.document"))) {
                return ResponseEntity.badRequest().body(createErrorResponse(
                    "Invalid file type. Only images, PDF, and Word documents are allowed"));
            }

            // Generate unique filename
            String originalFilename = file.getOriginalFilename();
            String extension = originalFilename != null && originalFilename.contains(".") 
                ? originalFilename.substring(originalFilename.lastIndexOf(".")) 
                : "";
            String filename = UUID.randomUUID().toString() + extension;

            // Create subdirectory by date (YYYY/MM) for organization
            java.time.LocalDate now = java.time.LocalDate.now();
            String subDir = now.getYear() + "/" + String.format("%02d", now.getMonthValue());
            // Use absolute path to ensure consistency
            Path uploadBasePath = Paths.get(UPLOAD_DIR).toAbsolutePath().normalize();
            Path subDirPath = uploadBasePath.resolve(subDir);
            if (!Files.exists(subDirPath)) {
                Files.createDirectories(subDirPath);
                log.info("Created upload subdirectory: {}", subDirPath.toAbsolutePath());
            }

            // Save file
            Path filePath = subDirPath.resolve(filename);
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
            
            // Log file save location for debugging
            log.info("File saved successfully to: {} (absolute: {})", filePath, filePath.toAbsolutePath());

            // Create file URL (relative path that can be served)
            String fileUrl = "/api/files/" + subDir + "/" + filename;

            // Return response
            Map<String, Object> response = new HashMap<>();
            response.put("url", fileUrl);
            response.put("path", fileUrl);
            response.put("fileName", originalFilename);
            response.put("fileSize", file.getSize());
            response.put("contentType", contentType);
            response.put("message", "File uploaded successfully");

            log.info("File uploaded successfully: {} by user {}", filename, authentication.getName());
            return ResponseEntity.ok(response);

        } catch (IOException e) {
            log.error("Error uploading file", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(createErrorResponse("Failed to upload file: " + e.getMessage()));
        } catch (Exception e) {
            log.error("Unexpected error uploading file", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(createErrorResponse("Unexpected error: " + e.getMessage()));
        }
    }

    private Map<String, Object> createErrorResponse(String message) {
        Map<String, Object> error = new HashMap<>();
        error.put("error", message);
        return error;
    }
}

