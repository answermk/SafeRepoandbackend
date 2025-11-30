package com.crimeprevention.crime_backend.core.repo.report;

import com.crimeprevention.crime_backend.core.model.report.Assignment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface AssignmentRepository extends JpaRepository<Assignment, UUID> {

    List<Assignment> findByOfficerId(UUID officerId);

    boolean existsByReportIdAndOfficerId(UUID reportId, UUID officerId);

    boolean existsByReportId(UUID reportId);
    
    Optional<Assignment> findByReportId(UUID reportId);
    
    Page<Assignment> findByOfficerIdOrderByAssignedAtDesc(UUID officerId, Pageable pageable);
    
    Page<Assignment> findByOfficerIdAndStatusOrderByAssignedAtDesc(UUID officerId, String status, Pageable pageable);
    
    @Query("SELECT a FROM Assignment a WHERE a.officer.id = :officerId AND a.report.priority = :priority ORDER BY a.assignedAt DESC")
    Page<Assignment> findByOfficerIdAndReportPriorityOrderByAssignedAtDesc(@Param("officerId") UUID officerId, @Param("priority") String priority, Pageable pageable);
}
