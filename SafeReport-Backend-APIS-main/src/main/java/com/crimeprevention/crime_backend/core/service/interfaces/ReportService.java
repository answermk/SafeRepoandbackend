package com.crimeprevention.crime_backend.core.service.interfaces;

import com.crimeprevention.crime_backend.core.dto.report.CreateReportRequest;
import com.crimeprevention.crime_backend.core.model.report.Report;
import com.crimeprevention.crime_backend.core.dto.report.ReportResponse;
import com.crimeprevention.crime_backend.core.dto.report.UpdateReportStatusRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

public interface ReportService {

    ReportResponse createReport(UUID reporterId, CreateReportRequest request, List<MultipartFile> evidenceFiles);

    ReportResponse getReportById(UUID reportId, UUID currentUserId);

    Report getReportEntityById(UUID reportId); // New method to fetch the entity

    Page<ReportResponse> getUserReports(UUID userId, Pageable pageable);

    Page<ReportResponse> getAllReports(Pageable pageable);

    Page<ReportResponse> getReportsByStatus(String status, Pageable pageable);

    ReportResponse updateReportStatus(UUID reportId, UpdateReportStatusRequest request);

    void deleteReport(UUID reportId, UUID currentUserId);
}
