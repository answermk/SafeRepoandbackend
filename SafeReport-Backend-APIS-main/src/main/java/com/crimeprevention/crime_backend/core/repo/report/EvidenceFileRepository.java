package com.crimeprevention.crime_backend.core.repo.report;

import com.crimeprevention.crime_backend.core.model.report.EvidenceFile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface EvidenceFileRepository extends JpaRepository<EvidenceFile, UUID> {
    List<EvidenceFile> findByReportId(UUID reportId);
}

