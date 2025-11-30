package com.crimeprevention.crime_backend.core.repo.analytics;

import com.crimeprevention.crime_backend.core.model.analytics.CrimePattern;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface CrimePatternRepository extends JpaRepository<CrimePattern, UUID> {
    
    /**
     * Find patterns by type
     */
    List<CrimePattern> findByPatternType(CrimePattern.PatternType patternType);
    
    /**
     * Find patterns by analysis period
     */
    List<CrimePattern> findByAnalysisPeriod(CrimePattern.AnalysisPeriod analysisPeriod);
    
    /**
     * Find patterns by risk level
     */
    List<CrimePattern> findByRiskLevel(CrimePattern.RiskLevel riskLevel);
    
    /**
     * Find patterns within a date range
     */
    @Query("SELECT cp FROM CrimePattern cp WHERE cp.startDate >= :startDate AND cp.endDate <= :endDate")
    List<CrimePattern> findByDateRange(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
    
    /**
     * Find patterns by location
     */
    @Query("SELECT cp FROM CrimePattern cp JOIN cp.affectedLocations al WHERE al = :location")
    List<CrimePattern> findByLocation(@Param("location") String location);
    
    /**
     * Find patterns by crime type
     */
    @Query("SELECT cp FROM CrimePattern cp JOIN cp.affectedCrimeTypes act WHERE act = :crimeType")
    List<CrimePattern> findByCrimeType(@Param("crimeType") String crimeType);
    
    /**
     * Find high-risk patterns
     */
    @Query("SELECT cp FROM CrimePattern cp WHERE cp.riskLevel IN ('HIGH', 'CRITICAL') ORDER BY cp.createdAt DESC")
    List<CrimePattern> findHighRiskPatterns();
    
    /**
     * Find recent patterns
     */
    @Query("SELECT cp FROM CrimePattern cp WHERE cp.createdAt >= :since ORDER BY cp.createdAt DESC")
    List<CrimePattern> findRecentPatterns(@Param("since") LocalDateTime since);
    
    /**
     * Find patterns by AI service used
     */
    List<CrimePattern> findByAiServiceUsed(String aiServiceUsed);
    
    /**
     * Count patterns by risk level
     */
    long countByRiskLevel(CrimePattern.RiskLevel riskLevel);
    
    /**
     * Count patterns by pattern type
     */
    long countByPatternType(CrimePattern.PatternType patternType);
    
    /**
     * Get paginated patterns
     */
    Page<CrimePattern> findAll(Pageable pageable);
}
