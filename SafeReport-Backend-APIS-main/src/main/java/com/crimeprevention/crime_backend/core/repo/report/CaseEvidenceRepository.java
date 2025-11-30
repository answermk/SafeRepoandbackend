package com.crimeprevention.crime_backend.core.repo.report;

import com.crimeprevention.crime_backend.core.model.report.CaseEvidence;
import com.crimeprevention.crime_backend.core.model.user.Officer;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface CaseEvidenceRepository extends JpaRepository<CaseEvidence, UUID> {

    List<CaseEvidence> findByReportId(UUID reportId);

    List<CaseEvidence> findByUploadedBy(Officer uploadedBy);

}
