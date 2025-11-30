package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.dto.report.CaseNoteResponse;
import com.crimeprevention.crime_backend.core.dto.report.CreateCaseNoteRequest;
import com.crimeprevention.crime_backend.core.dto.report.UpdateCaseNoteRequest;
import com.crimeprevention.crime_backend.core.model.report.CaseNote;
import com.crimeprevention.crime_backend.core.model.report.Report;
import com.crimeprevention.crime_backend.core.model.user.Officer;
import com.crimeprevention.crime_backend.core.repo.report.CaseNoteRepository;
import com.crimeprevention.crime_backend.core.repo.report.ReportRepository;
import com.crimeprevention.crime_backend.core.repo.user.OfficerRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.CaseNoteService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class CaseNoteServiceImpl implements CaseNoteService {
    
    private final CaseNoteRepository caseNoteRepository;
    private final ReportRepository reportRepository;
    private final OfficerRepository officerRepository;
    
    @Override
    @Transactional
    public CaseNoteResponse createNote(CreateCaseNoteRequest request, UUID officerId) {
        log.info("Creating case note for report {} by officer {}", request.getReportId(), officerId);
        
        // Validate report exists
        Report report = reportRepository.findById(request.getReportId())
            .orElseThrow(() -> new RuntimeException("Report not found with ID: " + request.getReportId()));
        
        // Validate officer exists
        Officer officer = officerRepository.findById(officerId)
            .orElseThrow(() -> new RuntimeException("Officer not found with ID: " + officerId));
        
        // Ensure the officer ID in request matches the authenticated officer
        if (!officerId.equals(request.getOfficerId())) {
            throw new AccessDeniedException("Officer ID mismatch");
        }
        
        // Create case note
        CaseNote caseNote = CaseNote.builder()
            .report(report)
            .officer(officer)
            .note(request.getNote())
            .createdAt(Instant.now())
            .build();
        
        caseNote = caseNoteRepository.save(caseNote);
        log.info("Case note created successfully with ID: {}", caseNote.getId());
        
        return toResponse(caseNote);
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<CaseNoteResponse> getNotesByReportId(UUID reportId) {
        log.info("Fetching all notes for report {}", reportId);
        
        // Validate report exists
        if (!reportRepository.existsById(reportId)) {
            throw new RuntimeException("Report not found with ID: " + reportId);
        }
        
        List<CaseNote> notes = caseNoteRepository.findByReportId(reportId);
        return notes.stream()
            .map(this::toResponse)
            .collect(Collectors.toList());
    }
    
    @Override
    @Transactional(readOnly = true)
    public CaseNoteResponse getNoteById(UUID noteId) {
        log.info("Fetching case note with ID: {}", noteId);
        
        CaseNote caseNote = caseNoteRepository.findById(noteId)
            .orElseThrow(() -> new RuntimeException("Case note not found with ID: " + noteId));
        
        return toResponse(caseNote);
    }
    
    @Override
    @Transactional
    public CaseNoteResponse updateNote(UUID noteId, UpdateCaseNoteRequest request, UUID officerId) {
        log.info("Updating case note {} by officer {}", noteId, officerId);
        
        CaseNote caseNote = caseNoteRepository.findById(noteId)
            .orElseThrow(() -> new RuntimeException("Case note not found with ID: " + noteId));
        
        // Check if the officer is authorized to update this note (only the creator can update)
        if (!caseNote.getOfficer().getId().equals(officerId)) {
            throw new AccessDeniedException("You can only update your own notes");
        }
        
        // Update note content
        caseNote.setNote(request.getNote());
        caseNote = caseNoteRepository.save(caseNote);
        
        log.info("Case note updated successfully");
        return toResponse(caseNote);
    }
    
    @Override
    @Transactional
    public void deleteNote(UUID noteId, UUID officerId) {
        log.info("Deleting case note {} by officer {}", noteId, officerId);
        
        CaseNote caseNote = caseNoteRepository.findById(noteId)
            .orElseThrow(() -> new RuntimeException("Case note not found with ID: " + noteId));
        
        // Check if the officer is authorized to delete this note (only the creator can delete)
        if (!caseNote.getOfficer().getId().equals(officerId)) {
            throw new AccessDeniedException("You can only delete your own notes");
        }
        
        caseNoteRepository.delete(caseNote);
        log.info("Case note deleted successfully");
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<CaseNoteResponse> getNotesByOfficerId(UUID officerId) {
        log.info("Fetching all notes by officer {}", officerId);
        
        List<CaseNote> notes = caseNoteRepository.findByOfficerId(officerId);
        return notes.stream()
            .map(this::toResponse)
            .collect(Collectors.toList());
    }
    
    /**
     * Convert CaseNote entity to CaseNoteResponse DTO.
     */
    private CaseNoteResponse toResponse(CaseNote caseNote) {
        Officer officer = caseNote.getOfficer();
        
        return CaseNoteResponse.builder()
            .id(caseNote.getId())
            .note(caseNote.getNote())
            .reportId(caseNote.getReport().getId())
            .officer(CaseNoteResponse.OfficerInfo.builder()
                .id(officer.getId())
                .fullName(officer.getFullName())
                .email(officer.getEmail())
                .build())
            .createdAt(caseNote.getCreatedAt())
            .updatedAt(caseNote.getUpdatedAt())
            .build();
    }
}

