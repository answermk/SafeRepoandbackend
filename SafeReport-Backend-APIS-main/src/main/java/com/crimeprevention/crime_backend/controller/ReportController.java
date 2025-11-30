package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.dto.report.AssignReportRequest;
import com.crimeprevention.crime_backend.core.dto.report.CreateReportRequest;
import com.crimeprevention.crime_backend.core.dto.report.ReportResponse;
import com.crimeprevention.crime_backend.core.dto.report.UpdateReportStatusRequest;
import com.crimeprevention.crime_backend.core.model.enums.ReportStatus;
import com.crimeprevention.crime_backend.core.model.enums.RoleType;
import com.crimeprevention.crime_backend.core.service.interfaces.AssignmentService;
import com.crimeprevention.crime_backend.core.service.interfaces.ReportService;
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
import org.springframework.web.multipart.MultipartFile;

import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/reports")
@RequiredArgsConstructor
public class ReportController {

    private final ReportService reportService;
    private final AssignmentService assignmentService;

    @PostMapping
    @PreAuthorize("hasRole('CIVILIAN') or hasRole('POLICE_OFFICER') or hasRole('OFFICER') or hasRole('ADMIN')")
    public ResponseEntity<ReportResponse> createReport(
            @RequestPart(value = "request", required = false) CreateReportRequest request,
            @RequestBody(required = false) CreateReportRequest jsonRequest,
            @RequestPart(value = "files", required = false) List<MultipartFile> files,
            Authentication authentication
    ) {
        // Handle both multipart and JSON requests
        CreateReportRequest finalRequest = request != null ? request : jsonRequest;
        if (finalRequest == null) {
            return ResponseEntity.badRequest().build();
        }
        
        UUID userId = UUID.fromString(authentication.getName());
        ReportResponse report = reportService.createReport(userId, finalRequest, files);
        return ResponseEntity.status(HttpStatus.CREATED).body(report);
    }

    @GetMapping("/{reportId}")
    public ResponseEntity<ReportResponse> getReport(@PathVariable UUID reportId) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UUID currentUserId = UUID.fromString(authentication.getName());
        
        ReportResponse response = reportService.getReportById(reportId, currentUserId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/my-reports")
    public ResponseEntity<Page<ReportResponse>> getMyReports(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {
        
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UUID currentUserId = UUID.fromString(authentication.getName());
        
        Sort sort = sortDir.equalsIgnoreCase("desc") ? 
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<ReportResponse> reports = reportService.getUserReports(currentUserId, pageable);
        return ResponseEntity.ok(reports);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'POLICE_OFFICER', 'OFFICER')")
    public ResponseEntity<Page<ReportResponse>> getAllReports(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {
        
        Sort sort = sortDir.equalsIgnoreCase("desc") ? 
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<ReportResponse> reports = reportService.getAllReports(pageable);
        return ResponseEntity.ok(reports);
    }

    @GetMapping("/status/{status}")
    @PreAuthorize("hasAnyRole('ADMIN', 'POLICE_OFFICER', 'OFFICER')")
    public ResponseEntity<Page<ReportResponse>> getReportsByStatus(
            @PathVariable String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {
        
        try {
            ReportStatus reportStatus = ReportStatus.valueOf(status.toUpperCase());
            
            Sort sort = sortDir.equalsIgnoreCase("desc") ? 
                Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
            Pageable pageable = PageRequest.of(page, size, sort);
            
            Page<ReportResponse> reports = reportService.getReportsByStatus(reportStatus.name(), pageable);
            return ResponseEntity.ok(reports);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PutMapping("/{reportId}/status")
    @PreAuthorize("hasAnyRole('ADMIN', 'POLICE_OFFICER', 'OFFICER')")
    public ResponseEntity<ReportResponse> updateReportStatus(
            @PathVariable UUID reportId,
            @Valid @RequestBody UpdateReportStatusRequest request) {
        
        ReportResponse response = reportService.updateReportStatus(reportId, request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{reportId}/assign")
    @PreAuthorize("hasAnyRole('ADMIN', 'POLICE_OFFICER', 'OFFICER')")
    public ResponseEntity<ReportResponse> assignReport(
            @PathVariable UUID reportId,
            @Valid @RequestBody AssignReportRequest request) {
        
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UUID assignedBy = UUID.fromString(authentication.getName());
        
        // Delegate to assignment service
        assignmentService.assignReportToOfficer(reportId, request, assignedBy);
        
        // Return updated report
        UUID currentUserId = UUID.fromString(authentication.getName());
        ReportResponse response = reportService.getReportById(reportId, currentUserId);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{reportId}")
    public ResponseEntity<Void> deleteReport(@PathVariable UUID reportId) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UUID currentUserId = UUID.fromString(authentication.getName());
        
        reportService.deleteReport(reportId, currentUserId);
        return ResponseEntity.noContent().build();
    }
} 