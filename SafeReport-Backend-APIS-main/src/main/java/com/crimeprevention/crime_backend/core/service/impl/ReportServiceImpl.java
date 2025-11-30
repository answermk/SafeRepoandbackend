package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.dto.report.*;
import com.crimeprevention.crime_backend.core.mapper.ReportMapper;
import com.crimeprevention.crime_backend.core.model.enums.ReportStatus;
import com.crimeprevention.crime_backend.core.model.report.Report;
import com.crimeprevention.crime_backend.core.repo.report.ReportRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.ReportService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class ReportServiceImpl implements ReportService {
    private final ReportRepository reportRepository;
    private final ReportMapper reportMapper;

    @Override
    @Transactional
    public ReportResponse createReport(UUID reporterId, CreateReportRequest request, List<MultipartFile> evidenceFiles) {
        Report report = Report.builder()
            .title(request.getTitle())
            .description(request.getDescription())
            .crimeRelationship(request.getCrimeRelationship())
            .witnessInfo(request.getWitnessInfo())
            .isAnonymous(request.isAnonymous())
            .reporterId(reporterId)
            .build();
        report = reportRepository.save(report);
        return reportMapper.toResponse(report);
    }

    @Override
    @Transactional(readOnly = true)
    public ReportResponse getReportById(UUID reportId, UUID currentUserId) {
        Report report = reportRepository.findById(reportId)
            .orElseThrow(() -> new RuntimeException("Report not found"));
        return reportMapper.toResponse(report);
    }

    @Override
    @Transactional(readOnly = true)
    public Report getReportEntityById(UUID reportId) {
        return reportRepository.findById(reportId)
            .orElseThrow(() -> new RuntimeException("Report not found"));
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ReportResponse> getUserReports(UUID userId, Pageable pageable) {
        return reportRepository.findByReporterId(userId, pageable)
            .map(reportMapper::toResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ReportResponse> getAllReports(Pageable pageable) {
        return reportRepository.findAll(pageable)
            .map(reportMapper::toResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ReportResponse> getReportsByStatus(String status, Pageable pageable) {
        return reportRepository.findByStatus(ReportStatus.valueOf(status), pageable)
            .map(reportMapper::toResponse);
    }

    @Override
    @Transactional
    public ReportResponse updateReportStatus(UUID reportId, UpdateReportStatusRequest request) {
        Report report = getReportEntityById(reportId);
        report.setStatus(request.getStatus());
        
        // Update priority if provided
        if (request.getPriority() != null) {
            report.setPriority(request.getPriority());
        }
        
        report = reportRepository.save(report);
        return reportMapper.toResponse(report);
    }

    @Override
    @Transactional
    public void deleteReport(UUID reportId, UUID currentUserId) {
        Report report = getReportEntityById(reportId);
        if (!report.getReporterId().equals(currentUserId)) {
            throw new RuntimeException("Not authorized to delete this report");
        }
        reportRepository.deleteById(reportId);
    }
}