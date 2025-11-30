package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.dto.report.AssignReportRequest;
import com.crimeprevention.crime_backend.core.dto.report.AssignmentResponse;
import com.crimeprevention.crime_backend.core.service.interfaces.AssignmentService;
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
import java.util.UUID;

@RestController
@RequestMapping("/api/assignments")
@RequiredArgsConstructor
public class AssignmentController {

    private final AssignmentService assignmentService;

    @PostMapping("/{reportId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'POLICE_OFFICER', 'OFFICER')")
    public ResponseEntity<AssignmentResponse> assignReportToOfficer(
            @PathVariable UUID reportId,
            @Valid @RequestBody AssignReportRequest request) {
        
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UUID assignedBy = UUID.fromString(authentication.getName());
        
        AssignmentResponse response = assignmentService.assignReportToOfficer(reportId, request, assignedBy);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/report/{reportId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'POLICE_OFFICER', 'OFFICER')")
    public ResponseEntity<AssignmentResponse> getAssignmentByReport(@PathVariable UUID reportId) {
        AssignmentResponse response = assignmentService.getAssignmentByReportId(reportId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/officer/{officerId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'POLICE_OFFICER', 'OFFICER')")
    public ResponseEntity<Page<AssignmentResponse>> getOfficerAssignments(
            @PathVariable UUID officerId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "assignedAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {
        
        Sort sort = sortDir.equalsIgnoreCase("desc") ? 
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<AssignmentResponse> assignments = assignmentService.getOfficerAssignments(officerId, pageable);
        return ResponseEntity.ok(assignments);
    }

    @GetMapping("/officer/{officerId}/status/{status}")
    @PreAuthorize("hasAnyRole('ADMIN', 'POLICE_OFFICER', 'OFFICER')")
    public ResponseEntity<Page<AssignmentResponse>> getOfficerAssignmentsByStatus(
            @PathVariable UUID officerId,
            @PathVariable String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "assignedAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {
        
        Sort sort = sortDir.equalsIgnoreCase("desc") ? 
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<AssignmentResponse> assignments = assignmentService.getOfficerAssignmentsByStatus(officerId, status, pageable);
        return ResponseEntity.ok(assignments);
    }

    @GetMapping("/officer/{officerId}/priority/{priority}")
    @PreAuthorize("hasAnyRole('ADMIN', 'POLICE_OFFICER', 'OFFICER')")
    public ResponseEntity<Page<AssignmentResponse>> getOfficerAssignmentsByPriority(
            @PathVariable UUID officerId,
            @PathVariable String priority,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "assignedAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {
        
        Sort sort = sortDir.equalsIgnoreCase("desc") ? 
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<AssignmentResponse> assignments = assignmentService.getOfficerAssignmentsByPriority(officerId, priority, pageable);
        return ResponseEntity.ok(assignments);
    }

    @PutMapping("/{assignmentId}/status")
    @PreAuthorize("hasAnyRole('ADMIN', 'POLICE_OFFICER', 'OFFICER')")
    public ResponseEntity<AssignmentResponse> updateAssignmentStatus(
            @PathVariable UUID assignmentId,
            @RequestParam String status) {
        
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UUID officerId = UUID.fromString(authentication.getName());
        
        AssignmentResponse response = assignmentService.updateAssignmentStatus(assignmentId, status, officerId);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{reportId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'POLICE_OFFICER', 'OFFICER')")
    public ResponseEntity<Void> unassignReport(@PathVariable UUID reportId) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UUID unassignedBy = UUID.fromString(authentication.getName());
        
        assignmentService.unassignReport(reportId, unassignedBy);
        return ResponseEntity.noContent().build();
    }
} 