package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.dto.message.CreateWatchGroupRequest;
import com.crimeprevention.crime_backend.core.dto.message.UpdateWatchGroupRequest;
import com.crimeprevention.crime_backend.core.dto.message.WatchGroupResponse;
import com.crimeprevention.crime_backend.core.service.interfaces.WatchGroupService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/watch-groups")
@RequiredArgsConstructor
@Slf4j
public class WatchGroupController {

    private final WatchGroupService watchGroupService;

    /**
     * Create a new watch group
     */
    @PostMapping
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<?> createWatchGroup(
            @Valid @RequestBody CreateWatchGroupRequest request,
            Authentication authentication
    ) {
        try {
            UUID userId = UUID.fromString(authentication.getName());
            log.info("Creating watch group for user: {}", userId);
            WatchGroupResponse response = watchGroupService.createWatchGroup(userId, request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException e) {
            log.error("Validation error creating watch group: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            log.error("Unexpected error creating watch group: {}", e.getMessage(), e);
            e.printStackTrace(); // Print full stack trace for debugging
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to create watch group: " + e.getMessage()));
        }
    }

    /**
     * Get all watch groups (for browsing/joining)
     * Supports optional location filtering by latitude, longitude, and radius
     */
    @GetMapping
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<Page<WatchGroupResponse>> getAllWatchGroups(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir,
            @RequestParam(required = false) Double latitude,
            @RequestParam(required = false) Double longitude,
            @RequestParam(required = false) Double radius
    ) {
        Sort sort = sortDir.equalsIgnoreCase("desc") ? 
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<WatchGroupResponse> groups = watchGroupService.getAllWatchGroups(pageable, latitude, longitude, radius);
        return ResponseEntity.ok(groups);
    }

    /**
     * Get user's watch groups (where they are a member)
     */
    @GetMapping("/my-groups")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<Page<WatchGroupResponse>> getMyWatchGroups(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "100") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir,
            Authentication authentication
    ) {
        UUID userId = UUID.fromString(authentication.getName());
        
        Sort sort = sortDir.equalsIgnoreCase("desc") ? 
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<WatchGroupResponse> groups = watchGroupService.getUserWatchGroups(userId, pageable);
        return ResponseEntity.ok(groups);
    }

    /**
     * Get a specific watch group by ID
     */
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<WatchGroupResponse> getWatchGroupById(
            @PathVariable UUID id,
            Authentication authentication
    ) {
        UUID userId = UUID.fromString(authentication.getName());
        WatchGroupResponse response = watchGroupService.getWatchGroupById(id, userId);
        return ResponseEntity.ok(response);
    }

    /**
     * Update a watch group
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<WatchGroupResponse> updateWatchGroup(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateWatchGroupRequest request,
            Authentication authentication
    ) {
        UUID userId = UUID.fromString(authentication.getName());
        WatchGroupResponse response = watchGroupService.updateWatchGroup(
            id, userId, request.getName(), request.getDescription()
        );
        return ResponseEntity.ok(response);
    }

    /**
     * Delete a watch group
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<Void> deleteWatchGroup(
            @PathVariable UUID id,
            Authentication authentication
    ) {
        UUID userId = UUID.fromString(authentication.getName());
        watchGroupService.deleteWatchGroup(id, userId);
        return ResponseEntity.noContent().build();
    }

    /**
     * Approve a watch group (Officer/Admin only)
     */
    @PutMapping("/{id}/approve")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<WatchGroupResponse> approveWatchGroup(
            @PathVariable UUID id,
            Authentication authentication
    ) {
        UUID officerId = UUID.fromString(authentication.getName());
        WatchGroupResponse response = watchGroupService.approveWatchGroup(id, officerId);
        return ResponseEntity.ok(response);
    }

    /**
     * Reject a watch group (Officer/Admin only)
     */
    @PutMapping("/{id}/reject")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<Void> rejectWatchGroup(
            @PathVariable UUID id,
            @RequestParam(required = false) String reason,
            Authentication authentication
    ) {
        UUID officerId = UUID.fromString(authentication.getName());
        watchGroupService.rejectWatchGroup(id, officerId, reason);
        return ResponseEntity.noContent().build();
    }

    /**
     * Join a watch group
     */
    @PostMapping("/{id}/members")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<WatchGroupResponse> joinWatchGroup(
            @PathVariable UUID id,
            Authentication authentication
    ) {
        UUID userId = UUID.fromString(authentication.getName());
        WatchGroupResponse response = watchGroupService.joinWatchGroup(userId, id);
        return ResponseEntity.ok(response);
    }

    /**
     * Leave a watch group
     */
    @DeleteMapping("/{id}/members/{userId}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<Void> leaveWatchGroup(
            @PathVariable UUID id,
            @PathVariable UUID userId,
            Authentication authentication
    ) {
        // Verify that the user is leaving their own membership
        UUID currentUserId = UUID.fromString(authentication.getName());
        if (!currentUserId.equals(userId)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        
        watchGroupService.leaveWatchGroup(userId, id);
        return ResponseEntity.noContent().build();
    }

    /**
     * Assign an officer to a watch group (Admin/Officer only)
     */
    @PutMapping("/{id}/assign-officer")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<WatchGroupResponse> assignOfficer(
            @PathVariable UUID id,
            @RequestParam UUID officerId,
            Authentication authentication
    ) {
        UUID assignedBy = UUID.fromString(authentication.getName());
        WatchGroupResponse response = watchGroupService.assignOfficerToGroup(id, officerId, assignedBy);
        return ResponseEntity.ok(response);
    }

    /**
     * Get watch groups by location
     */
    @GetMapping("/location/{locationId}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<Page<WatchGroupResponse>> getWatchGroupsByLocation(
            @PathVariable UUID locationId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir
    ) {
        Sort sort = sortDir.equalsIgnoreCase("desc") ? 
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<WatchGroupResponse> groups = watchGroupService.getWatchGroupsByLocation(locationId, pageable);
        return ResponseEntity.ok(groups);
    }

    /**
     * Get pending watch groups for approval (Officer/Admin only)
     */
    @GetMapping("/pending")
    @PreAuthorize("hasAnyRole('POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<Page<WatchGroupResponse>> getPendingWatchGroups(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir,
            Authentication authentication
    ) {
        UUID officerId = UUID.fromString(authentication.getName());
        
        Sort sort = sortDir.equalsIgnoreCase("desc") ? 
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<WatchGroupResponse> groups = watchGroupService.getPendingWatchGroups(officerId, pageable);
        return ResponseEntity.ok(groups);
    }
}
