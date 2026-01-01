package com.crimeprevention.crime_backend.core.repo.report;

import com.crimeprevention.crime_backend.core.model.report.Report;
import com.crimeprevention.crime_backend.core.model.enums.ReportStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Repository
public interface ReportRepository extends JpaRepository<Report, UUID> {
    
    // Find reports by reporter (user can see their own reports)
    Page<Report> findByReporterIdOrderByCreatedAtDesc(UUID reporterId, Pageable pageable);
    
    // Alias methods for service layer compatibility
    Page<Report> findByReporterId(UUID reporterId, Pageable pageable);
    
    // Find all reports for admin/officer (with pagination)
    Page<Report> findAllByOrderByCreatedAtDesc(Pageable pageable);
    
    // Find reports by status for admin/officer
    Page<Report> findByStatusOrderByCreatedAtDesc(String status, Pageable pageable);
    
    // Overload with ReportStatus enum
    Page<Report> findByStatus(ReportStatus status, Pageable pageable);
    
    // Count reports by status
    long countByStatus(String status);
    
    // Find reports by date range for anomaly detection
    @Query("SELECT r FROM Report r WHERE r.date >= :startDate AND r.date <= :endDate ORDER BY r.date DESC")
    List<Report> findByDateRange(@Param("startDate") Instant startDate, @Param("endDate") Instant endDate);
    
    // Count reports by reporter ID
    long countByReporterId(UUID reporterId);
    
    // Count reports by reporter ID and status
    @Query("SELECT COUNT(r) FROM Report r WHERE r.reporterId = :reporterId AND r.status = :status")
    long countByReporterIdAndStatus(@Param("reporterId") UUID reporterId, @Param("status") ReportStatus status);
    
    // Get recent reports by reporter for timeline
    @Query("SELECT r FROM Report r WHERE r.reporterId = :reporterId ORDER BY r.createdAt DESC")
    List<Report> findRecentByReporterId(@Param("reporterId") UUID reporterId, org.springframework.data.domain.Pageable pageable);
}
