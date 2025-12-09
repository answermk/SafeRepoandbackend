package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.dto.report.*;
import com.crimeprevention.crime_backend.core.mapper.ReportMapper;
import com.crimeprevention.crime_backend.core.model.enums.MediaType;
import com.crimeprevention.crime_backend.core.model.enums.ReportStatus;
import com.crimeprevention.crime_backend.core.model.report.EvidenceFile;
import com.crimeprevention.crime_backend.core.model.report.Report;
import com.crimeprevention.crime_backend.core.repo.report.EvidenceFileRepository;
import com.crimeprevention.crime_backend.core.repo.report.ReportRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.ReportService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class ReportServiceImpl implements ReportService {
    private static final String UPLOAD_DIR = "uploads";
    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
    
    private final ReportRepository reportRepository;
    private final ReportMapper reportMapper;
    private final EvidenceFileRepository evidenceFileRepository;

    @Override
    @Transactional
    public ReportResponse createReport(UUID reporterId, CreateReportRequest request, List<MultipartFile> evidenceFiles) {
        // Create location embeddable if coordinates are provided
        Report.Location location = null;
        if (request.getLatitude() != null && request.getLongitude() != null) {
            location = Report.Location.builder()
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .address(request.getAddress())
                .city(request.getCity())
                .state(request.getState())
                .zipCode(request.getZipCode())
                .area(request.getArea())
                .district(request.getDistrict())
                .build();
        }
        
        // Map crime type if provided as string
        com.crimeprevention.crime_backend.core.model.enums.CrimeType crimeType = null;
        if (request.getCrimeType() != null) {
            try {
                crimeType = com.crimeprevention.crime_backend.core.model.enums.CrimeType.valueOf(request.getCrimeType().toUpperCase());
            } catch (IllegalArgumentException e) {
                log.warn("Invalid crime type: {}", request.getCrimeType());
            }
        }
        
        Report report = Report.builder()
            .title(request.getTitle())
            .description(request.getDescription())
            .location(location)
            .crimeType(crimeType)
            .crimeRelationship(request.getCrimeRelationship())
            .witnessInfo(request.getWitnessInfo())
            .isAnonymous(request.isAnonymous())
            .reporterId(reporterId)
            .submittedAt(java.time.Instant.now())
            .date(java.time.Instant.now())
            .build();
        report = reportRepository.save(report);
        
        // Process and save evidence files if provided
        if (evidenceFiles != null && !evidenceFiles.isEmpty()) {
            List<EvidenceFile> savedFiles = new ArrayList<>();
            for (MultipartFile file : evidenceFiles) {
                try {
                    EvidenceFile evidenceFile = saveEvidenceFile(file, report);
                    if (evidenceFile != null) {
                        savedFiles.add(evidenceFile);
                    }
                } catch (Exception e) {
                    log.error("Failed to save evidence file: {}", file.getOriginalFilename(), e);
                    // Continue processing other files even if one fails
                }
            }
            log.info("Saved {} evidence file(s) for report {}", savedFiles.size(), report.getId());
        }
        
        return reportMapper.toResponse(report);
    }
    
    /**
     * Save an evidence file to disk and create EvidenceFile entity
     */
    private EvidenceFile saveEvidenceFile(MultipartFile file, Report report) throws IOException {
        // Validate file
        if (file == null || file.isEmpty()) {
            log.warn("Empty file provided, skipping");
            return null;
        }
        
        // Validate file size
        if (file.getSize() > MAX_FILE_SIZE) {
            log.warn("File {} exceeds size limit ({} bytes), skipping", file.getOriginalFilename(), file.getSize());
            return null;
        }
        
        // Create upload directory if it doesn't exist
        Path uploadPath = Paths.get(UPLOAD_DIR).toAbsolutePath().normalize();
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }
        
        // Create subdirectory by date (YYYY/MM) for organization
        LocalDate now = LocalDate.now();
        String subDir = now.getYear() + "/" + String.format("%02d", now.getMonthValue());
        Path subDirPath = uploadPath.resolve(subDir);
        if (!Files.exists(subDirPath)) {
            Files.createDirectories(subDirPath);
        }
        
        // Generate unique filename
        String originalFilename = file.getOriginalFilename();
        String extension = originalFilename != null && originalFilename.contains(".") 
            ? originalFilename.substring(originalFilename.lastIndexOf(".")) 
            : "";
        String filename = UUID.randomUUID().toString() + extension;
        
        // Save file to disk
        Path filePath = subDirPath.resolve(filename);
        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
        
        // Create file URL
        String fileUrl = "/api/files/" + subDir + "/" + filename;
        
        // Determine media type from content type
        MediaType mediaType = determineMediaType(file.getContentType(), originalFilename);
        
        // Create EvidenceFile entity
        EvidenceFile evidenceFile = EvidenceFile.builder()
            .fileName(originalFilename)
            .fileType(file.getContentType())
            .fileUrl(fileUrl)
            .fileSize(file.getSize())
            .mediaType(mediaType)
            .report(report)
            .build();
        
        return evidenceFileRepository.save(evidenceFile);
    }
    
    /**
     * Determine MediaType from content type and filename
     */
    private MediaType determineMediaType(String contentType, String filename) {
        if (contentType != null) {
            if (contentType.startsWith("image/")) {
                return MediaType.IMAGE;
            } else if (contentType.startsWith("video/")) {
                return MediaType.VIDEO;
            } else if (contentType.startsWith("audio/")) {
                return MediaType.AUDIO;
            } else if (contentType.equals("application/pdf") || 
                       contentType.contains("word") || 
                       contentType.contains("document")) {
                return MediaType.DOCUMENT;
            }
        }
        
        // Fallback to filename extension
        if (filename != null) {
            String lower = filename.toLowerCase();
            if (lower.endsWith(".jpg") || lower.endsWith(".jpeg") || 
                lower.endsWith(".png") || lower.endsWith(".gif") || 
                lower.endsWith(".webp")) {
                return MediaType.IMAGE;
            } else if (lower.endsWith(".mp4") || lower.endsWith(".mov") || 
                       lower.endsWith(".avi") || lower.endsWith(".mkv")) {
                return MediaType.VIDEO;
            } else if (lower.endsWith(".mp3") || lower.endsWith(".wav") || 
                       lower.endsWith(".aac") || lower.endsWith(".m4a")) {
                return MediaType.AUDIO;
            } else if (lower.endsWith(".pdf") || lower.endsWith(".doc") || 
                       lower.endsWith(".docx")) {
                return MediaType.DOCUMENT;
            }
        }
        
        return MediaType.OTHER;
    }

    @Override
    @Transactional(readOnly = true)
    public ReportResponse getReportById(UUID reportId, UUID currentUserId) {
        Report report = reportRepository.findById(reportId)
            .orElseThrow(() -> new RuntimeException("Report not found"));
        return reportMapper.toResponse(report);
    }

    @Override
    @Transactional(readOnly = true)
    public Report getReportEntityById(UUID reportId) {
        return reportRepository.findById(reportId)
            .orElseThrow(() -> new RuntimeException("Report not found"));
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ReportResponse> getUserReports(UUID userId, Pageable pageable) {
        return reportRepository.findByReporterId(userId, pageable)
            .map(reportMapper::toResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ReportResponse> getAllReports(Pageable pageable) {
        return reportRepository.findAll(pageable)
            .map(reportMapper::toResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ReportResponse> getReportsByStatus(String status, Pageable pageable) {
        return reportRepository.findByStatus(ReportStatus.valueOf(status), pageable)
            .map(reportMapper::toResponse);
    }

    @Override
    @Transactional
    public ReportResponse updateReportStatus(UUID reportId, UpdateReportStatusRequest request) {
        Report report = getReportEntityById(reportId);
        report.setStatus(request.getStatus());
        
        // Update priority if provided
        if (request.getPriority() != null) {
            report.setPriority(request.getPriority());
        }
        
        report = reportRepository.save(report);
        return reportMapper.toResponse(report);
    }

    @Override
    @Transactional
    public void deleteReport(UUID reportId, UUID currentUserId) {
        Report report = getReportEntityById(reportId);
        if (!report.getReporterId().equals(currentUserId)) {
            throw new RuntimeException("Not authorized to delete this report");
        }
        reportRepository.deleteById(reportId);
    }
}