package com.crimeprevention.crime_backend.core.service.interfaces;

import com.crimeprevention.crime_backend.core.dto.message.CreateWatchGroupRequest;
import com.crimeprevention.crime_backend.core.dto.message.WatchGroupResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

/**
 * Handles watch group management and operations.
 */
public interface WatchGroupService {

    /**
     * Create a new watch group (pending approval).
     *
     * @param creatorId the UUID of the user creating the group
     * @param request  the watch group creation request
     * @return the created watch group response
     */
    WatchGroupResponse createWatchGroup(UUID creatorId, CreateWatchGroupRequest request);

    /**
     * Get a watch group by ID.
     *
     * @param groupId the UUID of the watch group
     * @param userId  the UUID of the requesting user (for permission checks)
     * @return the watch group response
     */
    WatchGroupResponse getWatchGroupById(UUID groupId, UUID userId);

    /**
     * Get all watch groups for a user (where they are a member).
     *
     * @param userId   the UUID of the user
     * @param pageable pagination and sorting
     * @return page of watch groups
     */
    Page<WatchGroupResponse> getUserWatchGroups(UUID userId, Pageable pageable);

    /**
     * Get all watch groups in a location.
     *
     * @param locationId the UUID of the location
     * @param pageable   pagination and sorting
     * @return page of watch groups
     */
    Page<WatchGroupResponse> getWatchGroupsByLocation(UUID locationId, Pageable pageable);

    /**
     * Get all approved/active watch groups (for browsing/joining).
     * Optionally filter by location coordinates and radius.
     *
     * @param pageable pagination and sorting
     * @param latitude optional latitude for location filtering
     * @param longitude optional longitude for location filtering
     * @param radius optional radius in kilometers for location filtering
     * @return page of watch groups
     */
    Page<WatchGroupResponse> getAllWatchGroups(Pageable pageable, Double latitude, Double longitude, Double radius);

    /**
     * Get pending watch groups for officer approval.
     *
     * @param officerId the UUID of the officer
     * @param pageable pagination and sorting
     * @return page of pending watch groups
     */
    Page<WatchGroupResponse> getPendingWatchGroups(UUID officerId, Pageable pageable);

    /**
     * Approve a watch group and assign officer.
     *
     * @param groupId   the UUID of the watch group
     * @param officerId the UUID of the officer approving
     * @return the approved watch group response
     */
    WatchGroupResponse approveWatchGroup(UUID groupId, UUID officerId);

    /**
     * Reject a watch group.
     *
     * @param groupId         the UUID of the watch group
     * @param officerId       the UUID of the officer rejecting
     * @param rejectionReason reason for rejection
     */
    void rejectWatchGroup(UUID groupId, UUID officerId, String rejectionReason);

    /**
     * Join a watch group (only if approved).
     *
     * @param userId  the UUID of the user joining
     * @param groupId the UUID of the watch group
     * @return the updated watch group response
     */
    WatchGroupResponse joinWatchGroup(UUID userId, UUID groupId);

    /**
     * Leave a watch group.
     *
     * @param userId  the UUID of the user leaving
     * @param groupId the UUID of the watch group
     */
    void leaveWatchGroup(UUID userId, UUID groupId);

    /**
     * Assign an officer to a watch group.
     *
     * @param groupId   the UUID of the watch group
     * @param officerId the UUID of the officer
     * @param assignedBy the UUID of the user making the assignment
     * @return the updated watch group response
     */
    WatchGroupResponse assignOfficerToGroup(UUID groupId, UUID officerId, UUID assignedBy);

    /**
     * Remove an officer from a watch group.
     *
     * @param groupId   the UUID of the watch group
     * @param removedBy the UUID of the user removing the officer
     */
    void removeOfficerFromGroup(UUID groupId, UUID removedBy);

    /**
     * Update a watch group (only by creator or admin).
     *
     * @param groupId the UUID of the watch group
     * @param userId  the UUID of the user updating
     * @param name    new name (optional)
     * @param description new description (optional)
     * @return the updated watch group response
     */
    WatchGroupResponse updateWatchGroup(UUID groupId, UUID userId, String name, String description);

    /**
     * Delete a watch group (only by creator or admin).
     *
     * @param groupId the UUID of the watch group
     * @param userId  the UUID of the user deleting
     */
    void deleteWatchGroup(UUID groupId, UUID userId);
} 