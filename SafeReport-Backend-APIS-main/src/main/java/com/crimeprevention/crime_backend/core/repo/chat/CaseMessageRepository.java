package com.crimeprevention.crime_backend.core.repo.chat;

import com.crimeprevention.crime_backend.core.model.chat.CaseMessage;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface CaseMessageRepository extends JpaRepository<CaseMessage, UUID> {

    Page<CaseMessage> findByReportIdOrderByTimestampAsc(UUID reportId, Pageable pageable);

    List<CaseMessage> findByReportIdOrderByTimestampAsc(UUID reportId);

}
