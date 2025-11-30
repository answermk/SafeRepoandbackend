package com.crimeprevention.crime_backend.core.service.interfaces;

import com.crimeprevention.crime_backend.core.dto.report.AssignReportRequest;
import com.crimeprevention.crime_backend.core.dto.report.AssignmentResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

public interface AssignmentService {
    
    AssignmentResponse assignReportToOfficer(UUID reportId, AssignReportRequest request, UUID assignedBy);
    
    AssignmentResponse getAssignmentByReportId(UUID reportId);
    
    Page<AssignmentResponse> getOfficerAssignments(UUID officerId, Pageable pageable);
    
    Page<AssignmentResponse> getOfficerAssignmentsByStatus(UUID officerId, String status, Pageable pageable);
    
    Page<AssignmentResponse> getOfficerAssignmentsByPriority(UUID officerId, String priority, Pageable pageable);
    
    AssignmentResponse updateAssignmentStatus(UUID assignmentId, String status, UUID officerId);
    
    void unassignReport(UUID reportId, UUID unassignedBy);
}
