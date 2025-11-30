package com.crimeprevention.crime_backend.core.service.interfaces;

import com.crimeprevention.crime_backend.core.dto.report.CaseNoteResponse;
import com.crimeprevention.crime_backend.core.dto.report.CreateCaseNoteRequest;
import com.crimeprevention.crime_backend.core.dto.report.UpdateCaseNoteRequest;

import java.util.List;
import java.util.UUID;

/**
 * Service interface for managing case notes.
 */
public interface CaseNoteService {
    
    /**
     * Create a new case note.
     * 
     * @param request The request containing note details
     * @param officerId The ID of the officer creating the note
     * @return The created case note response
     */
    CaseNoteResponse createNote(CreateCaseNoteRequest request, UUID officerId);
    
    /**
     * Get all notes for a specific report.
     * 
     * @param reportId The ID of the report
     * @return List of case note responses
     */
    List<CaseNoteResponse> getNotesByReportId(UUID reportId);
    
    /**
     * Get a specific case note by ID.
     * 
     * @param noteId The ID of the note
     * @return The case note response
     */
    CaseNoteResponse getNoteById(UUID noteId);
    
    /**
     * Update an existing case note.
     * 
     * @param noteId The ID of the note to update
     * @param request The update request
     * @param officerId The ID of the officer updating the note (for authorization)
     * @return The updated case note response
     */
    CaseNoteResponse updateNote(UUID noteId, UpdateCaseNoteRequest request, UUID officerId);
    
    /**
     * Delete a case note.
     * 
     * @param noteId The ID of the note to delete
     * @param officerId The ID of the officer deleting the note (for authorization)
     */
    void deleteNote(UUID noteId, UUID officerId);
    
    /**
     * Get all notes created by a specific officer.
     * 
     * @param officerId The ID of the officer
     * @return List of case note responses
     */
    List<CaseNoteResponse> getNotesByOfficerId(UUID officerId);
}

