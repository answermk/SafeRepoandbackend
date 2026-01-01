package com.crimeprevention.crime_backend.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/files")
@RequiredArgsConstructor
@Slf4j
public class FileController {

    private static final String UPLOAD_DIR = "uploads";

    @GetMapping("/**")
    public ResponseEntity<?> getFile(HttpServletRequest request) {
        try {
            // Extract path from request URL
            String requestPath = request.getRequestURI();
            String pathPrefix = "/api/files/";
            if (!requestPath.startsWith(pathPrefix)) {
                return ResponseEntity.badRequest().body(createErrorResponse("Invalid file path"));
            }
            
            String relativePath = requestPath.substring(pathPrefix.length());
            if (relativePath == null || relativePath.isEmpty()) {
                return ResponseEntity.badRequest().body(createErrorResponse("File path is required"));
            }
            
            // Use absolute path to avoid working directory issues
            Path uploadBasePath = Paths.get(UPLOAD_DIR).toAbsolutePath().normalize();
            Path filePath = uploadBasePath.resolve(relativePath).normalize();
            
            // Security check: ensure file is within upload directory (prevent directory traversal)
            if (!filePath.startsWith(uploadBasePath)) {
                log.warn("Security violation: Attempted to access file outside upload directory: {}", filePath);
                return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
            }
            
            // Log for debugging
            log.info("Looking for file at: {} (absolute path: {})", filePath, filePath.toAbsolutePath());
            
            if (!Files.exists(filePath)) {
                log.warn("File not found: {} (checked absolute path: {})", relativePath, filePath.toAbsolutePath());
                return ResponseEntity.notFound().build();
            }
            
            if (!Files.isRegularFile(filePath)) {
                log.warn("Path exists but is not a regular file: {}", filePath);
                return ResponseEntity.notFound().build();
            }

            byte[] fileContent = Files.readAllBytes(filePath);
            String contentType = Files.probeContentType(filePath);
            if (contentType == null) {
                // Try to determine from file extension
                String filename = filePath.getFileName().toString().toLowerCase();
                if (filename.endsWith(".jpg") || filename.endsWith(".jpeg")) contentType = "image/jpeg";
                else if (filename.endsWith(".png")) contentType = "image/png";
                else if (filename.endsWith(".gif")) contentType = "image/gif";
                else if (filename.endsWith(".pdf")) contentType = "application/pdf";
                else if (filename.endsWith(".doc")) contentType = "application/msword";
                else if (filename.endsWith(".docx")) contentType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
                else if (filename.endsWith(".mp4")) contentType = "video/mp4";
                else if (filename.endsWith(".webm")) contentType = "video/webm";
                else if (filename.endsWith(".mov")) contentType = "video/quicktime";
                else if (filename.endsWith(".avi")) contentType = "video/x-msvideo";
                else contentType = "application/octet-stream";
            }
            
            log.info("Serving file: {} (size: {} bytes, type: {})", filePath.getFileName(), fileContent.length, contentType);
            
            return ResponseEntity.ok()
                .header("Content-Type", contentType)
                .header("Content-Disposition", "inline; filename=\"" + filePath.getFileName().toString() + "\"")
                .body(fileContent);

        } catch (IOException e) {
            log.error("Error reading file", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    private Map<String, Object> createErrorResponse(String message) {
        Map<String, Object> error = new HashMap<>();
        error.put("error", message);
        return error;
    }
}

