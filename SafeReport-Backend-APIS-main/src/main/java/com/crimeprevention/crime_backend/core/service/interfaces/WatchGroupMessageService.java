package com.crimeprevention.crime_backend.core.service.interfaces;

import com.crimeprevention.crime_backend.core.dto.message.CreateWatchGroupMessageRequest;
import com.crimeprevention.crime_backend.core.dto.message.WatchGroupMessageResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface WatchGroupMessageService {

    /**
     * Send a message to a watch group.
     *
     * @param groupId      ID of the watch group
     * @param senderId     ID of the sender (user)
     * @param request      DTO containing the message content
     * @return the sent message response
     */
    WatchGroupMessageResponse sendMessage(UUID groupId, UUID senderId, CreateWatchGroupMessageRequest request);

    /**
     * Get all messages from a watch group with pagination.
     *
     * @param groupId  ID of the watch group
     * @param pageable pagination and sorting
     * @return Page of messages in the group
     */
    Page<WatchGroupMessageResponse> getMessagesByGroup(UUID groupId, Pageable pageable);

    /**
     * Get all messages from a watch group without pagination.
     *
     * @param groupId ID of the watch group
     * @return List of messages in the group
     */
    List<WatchGroupMessageResponse> getMessagesByGroup(UUID groupId);
}
