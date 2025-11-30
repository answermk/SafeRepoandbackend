package com.crimeprevention.crime_backend.core.repo.report;

import com.crimeprevention.crime_backend.core.model.report.BackupRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface BackupRequestRepository extends JpaRepository<BackupRequest, UUID> {

    @Query("""
        select br from BackupRequest br
        join br.assignment a
        join a.report r
        where r.id = :reportId
        """)
    List<BackupRequest> findByReportId(@Param("reportId") UUID reportId);
}
