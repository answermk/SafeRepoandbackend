package com.crimeprevention.crime_backend.core.repo.report;

import com.crimeprevention.crime_backend.core.model.report.ReportMedia;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ReportMediaRepository extends JpaRepository<ReportMedia, UUID> {
    
    // Find all media for a specific report
    List<ReportMedia> findByReportIdOrderByCreatedAtDesc(UUID reportId);
    
    // Delete all media for a specific report
    void deleteByReportId(UUID reportId);
}
