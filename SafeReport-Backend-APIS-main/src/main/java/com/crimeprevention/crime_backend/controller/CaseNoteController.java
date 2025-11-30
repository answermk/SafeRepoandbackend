package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.dto.report.CaseNoteResponse;
import com.crimeprevention.crime_backend.core.dto.report.CreateCaseNoteRequest;
import com.crimeprevention.crime_backend.core.dto.report.UpdateCaseNoteRequest;
import com.crimeprevention.crime_backend.core.service.interfaces.CaseNoteService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

/**
 * REST controller for managing case notes.
 */
@RestController
@RequiredArgsConstructor
@Slf4j
@PreAuthorize("hasAnyRole('POLICE_OFFICER', 'OFFICER', 'ADMIN')")
public class CaseNoteController {
    
    private final CaseNoteService caseNoteService;
    
    /**
     * Create a new case note for a report.
     * 
     * POST /api/reports/{reportId}/notes
     */
    @PostMapping("/api/reports/{reportId}/notes")
    public ResponseEntity<CaseNoteResponse> createNote(
            @PathVariable UUID reportId,
            @Valid @RequestBody CreateCaseNoteRequest request,
            Authentication authentication) {
        
        UUID officerId = UUID.fromString(authentication.getName());
        
        // Set reportId from path variable
        request.setReportId(reportId);
        request.setOfficerId(officerId);
        
        CaseNoteResponse response = caseNoteService.createNote(request, officerId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
    
    /**
     * Get all notes for a specific report.
     * 
     * GET /api/reports/{reportId}/notes
     */
    @GetMapping("/api/reports/{reportId}/notes")
    public ResponseEntity<List<CaseNoteResponse>> getNotesByReportId(
            @PathVariable UUID reportId) {
        
        List<CaseNoteResponse> notes = caseNoteService.getNotesByReportId(reportId);
        return ResponseEntity.ok(notes);
    }
    
    /**
     * Get a specific case note by ID.
     * 
     * GET /api/notes/{noteId}
     */
    @GetMapping("/api/notes/{noteId}")
    public ResponseEntity<CaseNoteResponse> getNoteById(
            @PathVariable UUID noteId) {
        
        CaseNoteResponse note = caseNoteService.getNoteById(noteId);
        return ResponseEntity.ok(note);
    }
    
    /**
     * Update an existing case note.
     * 
     * PUT /api/notes/{noteId}
     */
    @PutMapping("/api/notes/{noteId}")
    public ResponseEntity<CaseNoteResponse> updateNote(
            @PathVariable UUID noteId,
            @Valid @RequestBody UpdateCaseNoteRequest request,
            Authentication authentication) {
        
        UUID officerId = UUID.fromString(authentication.getName());
        CaseNoteResponse response = caseNoteService.updateNote(noteId, request, officerId);
        return ResponseEntity.ok(response);
    }
    
    /**
     * Delete a case note.
     * 
     * DELETE /api/notes/{noteId}
     */
    @DeleteMapping("/api/notes/{noteId}")
    public ResponseEntity<Void> deleteNote(
            @PathVariable UUID noteId,
            @RequestBody(required = false) java.util.Map<String, String> body,
            Authentication authentication) {
        
        UUID officerId = UUID.fromString(authentication.getName());
        caseNoteService.deleteNote(noteId, officerId);
        return ResponseEntity.noContent().build();
    }
    
    /**
     * Get all notes created by a specific officer.
     * 
     * GET /api/officers/{officerId}/notes
     */
    @GetMapping("/api/officers/{officerId}/notes")
    public ResponseEntity<List<CaseNoteResponse>> getNotesByOfficerId(
            @PathVariable UUID officerId) {
        
        List<CaseNoteResponse> notes = caseNoteService.getNotesByOfficerId(officerId);
        return ResponseEntity.ok(notes);
    }
}

