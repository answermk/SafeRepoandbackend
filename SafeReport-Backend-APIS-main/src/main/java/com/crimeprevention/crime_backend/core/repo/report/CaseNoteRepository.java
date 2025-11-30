package com.crimeprevention.crime_backend.core.repo.report;

import com.crimeprevention.crime_backend.core.model.report.CaseNote;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface CaseNoteRepository extends JpaRepository<CaseNote, UUID> {

    List<CaseNote> findByReportId(UUID reportId);

    List<CaseNote> findByOfficerId(UUID officerId);

}
