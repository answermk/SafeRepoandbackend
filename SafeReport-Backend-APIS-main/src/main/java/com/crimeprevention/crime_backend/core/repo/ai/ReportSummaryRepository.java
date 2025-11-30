package com.crimeprevention.crime_backend.core.repo.ai;

import com.crimeprevention.crime_backend.core.model.ai.ReportSummary;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ReportSummaryRepository extends JpaRepository<ReportSummary, UUID>, JpaSpecificationExecutor<ReportSummary> {
    
    /**
     * Find summaries by report ID
     */
    List<ReportSummary> findByReportId(UUID reportId);
    
    /**
     * Find summaries by AI service used
     */
    List<ReportSummary> findByAiServiceUsed(String aiService);
    
    /**
     * Find summaries by urgency level
     */
    List<ReportSummary> findByUrgencyLevel(ReportSummary.UrgencyLevel urgencyLevel);
    
    /**
     * Find summaries by priority level
     */
    List<ReportSummary> findByPriorityLevel(ReportSummary.PriorityLevel priorityLevel);
    
    /**
     * Find summaries created within a date range
     */
    List<ReportSummary> findByCreatedAtBetween(LocalDateTime startDate, LocalDateTime endDate);
    
    /**
     * Find summaries with confidence score above threshold
     */
    List<ReportSummary> findByConfidenceScoreGreaterThan(Double threshold);
    
    /**
     * Find summaries by tag
     */
    @Query("SELECT rs FROM ReportSummary rs JOIN rs.tags t WHERE t = :tag")
    List<ReportSummary> findByTag(@Param("tag") String tag);
    
    /**
     * Find summaries by multiple tags
     */
    @Query("SELECT rs FROM ReportSummary rs JOIN rs.tags t WHERE t IN :tags")
    List<ReportSummary> findByTags(@Param("tags") List<String> tags);
    
    /**
     * Count summaries by AI service
     */
    long countByAiServiceUsed(String aiService);
    
    /**
     * Find the most recent summary for a report
     */
    @Query("SELECT rs FROM ReportSummary rs WHERE rs.report.id = :reportId ORDER BY rs.createdAt DESC")
    Optional<ReportSummary> findLatestByReportId(@Param("reportId") UUID reportId);
    
    /**
     * Find summaries with processing time above threshold
     */
    List<ReportSummary> findByProcessingTimeMsGreaterThan(Integer threshold);
    
    /**
     * Count summaries by urgency level
     */
    long countByUrgencyLevel(ReportSummary.UrgencyLevel urgencyLevel);
    
    /**
     * Count summaries by priority level
     */
    long countByPriorityLevel(ReportSummary.PriorityLevel priorityLevel);
    
    /**
     * Find active (non-deleted) summaries
     */
    @Query("SELECT rs FROM ReportSummary rs WHERE rs.isDeleted = false")
    List<ReportSummary> findActiveSummaries();
    
    /**
     * Find deleted summaries
     */
    @Query("SELECT rs FROM ReportSummary rs WHERE rs.isDeleted = true")
    List<ReportSummary> findDeletedSummaries();
    
    /**
     * Soft delete summary by ID
     */
    @Modifying
    @Query("UPDATE ReportSummary rs SET rs.isDeleted = true, rs.deletedAt = :deletedAt, rs.deletedBy = :deletedBy, rs.deletionReason = :deletionReason WHERE rs.id = :id")
    void softDeleteById(@Param("id") UUID id, @Param("deletedAt") LocalDateTime deletedAt, @Param("deletedBy") UUID deletedBy, @Param("deletionReason") String deletionReason);
    
    /**
     * Restore soft deleted summary
     */
    @Modifying
    @Query("UPDATE ReportSummary rs SET rs.isDeleted = false, rs.deletedAt = null, rs.deletedBy = null, rs.deletionReason = null WHERE rs.id = :id")
    void restoreById(@Param("id") UUID id);
}
