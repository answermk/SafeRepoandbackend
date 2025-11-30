package com.crimeprevention.crime_backend.core.service.interfaces;

import com.crimeprevention.crime_backend.core.dto.message.CreateMessageRequest;
import com.crimeprevention.crime_backend.core.dto.message.MessageResponse;
import com.crimeprevention.crime_backend.core.dto.message.UpdateMessageRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

/**
 * Handles messaging between users during operations or report handling.
 */
public interface MessageService {

    /**
     * Send a message to another user.
     *
     * @param senderId   the UUID of the sending user
     * @param receiverId the UUID of the receiving user
     * @param request    the message request
     * @return the sent message response
     */
    MessageResponse sendMessage(UUID senderId, UUID receiverId, CreateMessageRequest request);

    /**
     * Get all messages between two users.
     *
     * @param user1 the UUID of the first user
     * @param user2 the UUID of the second user
     * @return list of exchanged messages
     */
    List<MessageResponse> getMessagesBetween(UUID user1, UUID user2);

    /**
     * Get all messages sent to a given user (inbox).
     *
     * @param receiverId UUID of the receiver
     * @param pageable   pagination and sorting
     * @return page of messages
     */
    Page<MessageResponse> getInbox(UUID receiverId, Pageable pageable);

    /**
     * Get all messages sent by a given user.
     *
     * @param senderId UUID of the sender
     * @param pageable pagination and sorting
     * @return page of messages
     */
    Page<MessageResponse> getSentMessages(UUID senderId, Pageable pageable);

    /**
     * Get all messages related to a specific report.
     *
     * @param reportId UUID of the report
     * @return list of messages
     */
    List<MessageResponse> getMessagesByReport(UUID reportId);

    /**
     * Update a message (only by the sender).
     *
     * @param messageId UUID of the message to update
     * @param userId    UUID of the user requesting the update
     * @param request   the update request
     * @return the updated message response
     */
    MessageResponse updateMessage(UUID messageId, UUID userId, UpdateMessageRequest request);

    /**
     * Delete a message (only by the sender or admin).
     *
     * @param messageId UUID of the message to delete
     * @param userId    UUID of the user requesting the deletion
     */
    void deleteMessage(UUID messageId, UUID userId);

    /**
     * Mark a message as read.
     *
     * @param messageId UUID of the message to mark as read
     * @param userId    UUID of the user marking the message as read (must be the receiver)
     */
    void markMessageAsRead(UUID messageId, UUID userId);

    /**
     * Mark all messages in a conversation as read.
     *
     * @param conversationUserId UUID of the other user in the conversation
     * @param currentUserId      UUID of the current user
     */
    void markConversationAsRead(UUID conversationUserId, UUID currentUserId);
}
