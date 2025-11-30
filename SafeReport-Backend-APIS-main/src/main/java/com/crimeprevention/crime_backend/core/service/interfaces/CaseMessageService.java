package com.crimeprevention.crime_backend.core.service.interfaces;

import com.crimeprevention.crime_backend.core.dto.message.CaseMessageResponse;
import com.crimeprevention.crime_backend.core.dto.message.CreateCaseMessageRequest;
import com.crimeprevention.crime_backend.core.dto.message.UpdateCaseMessageRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

/**
 * Handles case-specific messaging between users and officers.
 */
public interface CaseMessageService {

    /**
     * Send a case message.
     *
     * @param senderId the UUID of the sending user
     * @param request the case message request
     * @return the sent case message response
     */
    CaseMessageResponse sendCaseMessage(UUID senderId, CreateCaseMessageRequest request);

    /**
     * Get all case messages for a specific report with pagination.
     *
     * @param reportId UUID of the report
     * @param pageable pagination and sorting
     * @return page of case messages
     */
    Page<CaseMessageResponse> getConversation(UUID reportId, Pageable pageable);

    /**
     * Get all case messages for a specific report without pagination.
     *
     * @param reportId UUID of the report
     * @return list of case messages
     */
    List<CaseMessageResponse> getConversationAll(UUID reportId);

    /**
     * Update a case message (only by the sender).
     *
     * @param messageId UUID of the message to update
     * @param userId    UUID of the user requesting the update
     * @param request   the update request
     * @return the updated case message response
     */
    CaseMessageResponse updateCaseMessage(UUID messageId, UUID userId, UpdateCaseMessageRequest request);

    /**
     * Delete a case message (only by the sender or admin).
     *
     * @param messageId UUID of the message to delete
     * @param userId    UUID of the user requesting the deletion
     */
    void deleteCaseMessage(UUID messageId, UUID userId);
}
