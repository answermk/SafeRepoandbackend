package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.dto.report.AssignReportRequest;
import com.crimeprevention.crime_backend.core.dto.report.AssignmentResponse;
import com.crimeprevention.crime_backend.core.exception.ResourceNotFoundException;
import com.crimeprevention.crime_backend.core.exception.UnauthorizedException;
import com.crimeprevention.crime_backend.core.model.enums.AssignmentStatus;
import com.crimeprevention.crime_backend.core.model.enums.DutyStatus;
import com.crimeprevention.crime_backend.core.model.enums.OfficerRoleType;
import com.crimeprevention.crime_backend.core.model.enums.ReportStatus;
import com.crimeprevention.crime_backend.core.model.enums.UserRole;
import com.crimeprevention.crime_backend.core.model.report.Assignment;
import com.crimeprevention.crime_backend.core.model.report.Report;
import com.crimeprevention.crime_backend.core.model.user.Officer;
import com.crimeprevention.crime_backend.core.model.user.User;
import com.crimeprevention.crime_backend.core.repo.report.AssignmentRepository;
import com.crimeprevention.crime_backend.core.repo.report.ReportRepository;
import com.crimeprevention.crime_backend.core.repo.user.OfficerRepository;
import com.crimeprevention.crime_backend.core.repo.user.UserRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.AssignmentService;
import com.crimeprevention.crime_backend.core.service.interfaces.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class AssignmentServiceImpl implements AssignmentService {

    private final AssignmentRepository assignmentRepository;
    private final ReportRepository reportRepository;
    private final OfficerRepository officerRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    @Override
    public AssignmentResponse assignReportToOfficer(UUID reportId, AssignReportRequest request, UUID assignedBy) {
        // Verify the person making the assignment has permission (must be IN_CHARGE officer or ADMIN)
        User assigner = userRepository.findById(assignedBy)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        
        // Check if assigner is ADMIN (can always assign)
        boolean canAssign = assigner.getRole() == UserRole.ADMIN;
        
        // If not ADMIN, check if assigner is an officer with IN_CHARGE role
        if (!canAssign) {
            Officer assignerOfficer = officerRepository.findById(assignedBy).orElse(null);
            if (assignerOfficer != null && assignerOfficer.getOfficerRoleType() == OfficerRoleType.IN_CHARGE) {
                canAssign = true;
            }
        }
        
        if (!canAssign) {
            throw new UnauthorizedException("Only officers in charge or administrators can assign cases");
        }
        
        // Verify the report exists
        Report report = reportRepository.findById(reportId)
                .orElseThrow(() -> new ResourceNotFoundException("Report not found"));

        // Verify the officer exists and is available
        Officer officer = officerRepository.findById(request.getOfficerId())
                .orElseThrow(() -> new ResourceNotFoundException("Officer not found"));

        if (officer.getDutyStatus() != DutyStatus.AVAILABLE) {
            throw new UnauthorizedException("Officer is not available for assignment");
        }

        // Check if report is already assigned
        if (assignmentRepository.existsByReportId(reportId)) {
            throw new UnauthorizedException("Report is already assigned to an officer");
        }

        // Create assignment
        Assignment assignment = Assignment.builder()
                .report(report)
                .officer(officer)
                .assignedBy(assignedBy)
                .assignmentNotes(request.getAssignmentNotes())
                .status(AssignmentStatus.ASSIGNED)
                .assignedAt(Instant.now())
                .build();

        Assignment savedAssignment = assignmentRepository.save(assignment);

        // Update report status to UNDER_INVESTIGATION
        report.setStatus(ReportStatus.UNDER_INVESTIGATION);
        reportRepository.save(report);
        
        // Update officer status to ON_CASE
        officer.setDutyStatus(DutyStatus.ON_CASE);
        officerRepository.save(officer);

        // Send notifications
        try {
            // Notify the officer about the assignment
            notificationService.notifyCaseAssigned(
                officer.getId(), 
                reportId, 
                report.getTitle()
            );
            
            // Notify the reporter about the assignment (if not anonymous)
            if (!report.isAnonymous()) {
                notificationService.notifyCaseStatusUpdate(
                    report.getReporter().getId(), 
                    reportId, 
                    report.getTitle(), 
                    "UNDER_INVESTIGATION"
                );
            }
        } catch (Exception e) {
            log.warn("Failed to send assignment notifications: {}", e.getMessage());
        }

        return buildAssignmentResponse(savedAssignment);
    }

    @Override
    public AssignmentResponse getAssignmentByReportId(UUID reportId) {
        Assignment assignment = assignmentRepository.findByReportId(reportId)
                .orElseThrow(() -> new ResourceNotFoundException("Assignment not found for this report"));
        
        return buildAssignmentResponse(assignment);
    }

    @Override
    public Page<AssignmentResponse> getOfficerAssignments(UUID officerId, Pageable pageable) {
        Page<Assignment> assignments = assignmentRepository.findByOfficerIdOrderByAssignedAtDesc(officerId, pageable);
        return assignments.map(this::buildAssignmentResponse);
    }

    @Override
    public Page<AssignmentResponse> getOfficerAssignmentsByStatus(UUID officerId, String status, Pageable pageable) {
        Page<Assignment> assignments = assignmentRepository.findByOfficerIdAndStatusOrderByAssignedAtDesc(officerId, status, pageable);
        return assignments.map(this::buildAssignmentResponse);
    }

    @Override
    public Page<AssignmentResponse> getOfficerAssignmentsByPriority(UUID officerId, String priority, Pageable pageable) {
        Page<Assignment> assignments = assignmentRepository.findByOfficerIdAndReportPriorityOrderByAssignedAtDesc(officerId, priority, pageable);
        return assignments.map(this::buildAssignmentResponse);
    }

    @Override
    public AssignmentResponse updateAssignmentStatus(UUID assignmentId, String status, UUID officerId) {
        Assignment assignment = assignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new ResourceNotFoundException("Assignment not found"));

        // Verify the officer is assigned to this report
        if (!assignment.getOfficer().getId().equals(officerId)) {
            throw new UnauthorizedException("You can only update assignments assigned to you");
        }
        
        // Parse the status string to enum
        AssignmentStatus newStatus;
        try {
            newStatus = AssignmentStatus.valueOf(status.toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid assignment status: " + status);
        }
        
        assignment.setStatus(newStatus);
        assignment.setUpdatedAt(Instant.now());
        
        Assignment updatedAssignment = assignmentRepository.save(assignment);
        
        // Update report status based on assignment status
        Report report = assignment.getReport();
        if (newStatus == AssignmentStatus.RESOLVED) {
            report.setStatus(ReportStatus.RESOLVED);
            // Set officer back to available
            Officer officer = assignment.getOfficer();
            officer.setDutyStatus(DutyStatus.AVAILABLE);
            officerRepository.save(officer);
        } else if (newStatus == AssignmentStatus.IN_PROGRESS) {
            report.setStatus(ReportStatus.IN_PROGRESS);
        }
        reportRepository.save(report);
        
        return buildAssignmentResponse(updatedAssignment);
    }

    @Override
    public void unassignReport(UUID reportId, UUID unassignedBy) {
        Assignment assignment = assignmentRepository.findByReportId(reportId)
                .orElseThrow(() -> new ResourceNotFoundException("Assignment not found for this report"));
        
        // Only the person who assigned it or an admin can unassign
        if (!assignment.getAssignedBy().equals(unassignedBy)) {
            throw new UnauthorizedException("You can only unassign reports that you assigned");
        }
        
        // Update report status back to PENDING
        Report report = assignment.getReport();
        report.setStatus(ReportStatus.PENDING);
        reportRepository.save(report);
        
        // Set officer back to available
        Officer officer = assignment.getOfficer();
        officer.setDutyStatus(DutyStatus.AVAILABLE);
        officerRepository.save(officer);
        
        // Delete the assignment
        assignmentRepository.delete(assignment);
    }

    private AssignmentResponse buildAssignmentResponse(Assignment assignment) {
        return AssignmentResponse.builder()
                .id(assignment.getId())
                .reportId(assignment.getReport().getId())
                .reportTitle(assignment.getReport().getTitle())
                .officerId(assignment.getOfficer().getId())
                .officerName(assignment.getOfficer().getFullName())
                .assignmentNotes(assignment.getAssignmentNotes())
                .status(assignment.getStatus().name())
                .priority(assignment.getReport().getPriority().name())
                .assignedAt(assignment.getAssignedAt())
                .createdAt(assignment.getCreatedAt())
                .updatedAt(assignment.getUpdatedAt())
                .build();
    }
}
