package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.dto.message.CreateWatchGroupRequest;
import com.crimeprevention.crime_backend.core.dto.message.WatchGroupMemberResponse;
import com.crimeprevention.crime_backend.core.dto.message.WatchGroupResponse;
import com.crimeprevention.crime_backend.core.model.chat.WatchGroup;
import com.crimeprevention.crime_backend.core.model.chat.WatchGroupMember;
import com.crimeprevention.crime_backend.core.model.location.Location;
import com.crimeprevention.crime_backend.core.model.user.Officer;
import com.crimeprevention.crime_backend.core.model.user.User;
import com.crimeprevention.crime_backend.core.repo.chat.WatchGroupMemberRepository;
import com.crimeprevention.crime_backend.core.repo.chat.WatchGroupRepository;
import com.crimeprevention.crime_backend.core.repo.location.LocationRepository;
import com.crimeprevention.crime_backend.core.repo.user.OfficerRepository;
import com.crimeprevention.crime_backend.core.repo.user.UserRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.WatchGroupService;
import com.crimeprevention.crime_backend.core.service.interfaces.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.HashSet;
import com.crimeprevention.crime_backend.core.model.enums.WatchGroupStatus;
import java.util.Set;
import com.crimeprevention.crime_backend.core.model.enums.UserRole;

@Service
@RequiredArgsConstructor
@Slf4j
public class WatchGroupServiceImpl implements WatchGroupService {

    private final WatchGroupRepository watchGroupRepository;
    private final WatchGroupMemberRepository watchGroupMemberRepository;
    private final UserRepository userRepository;
    private final LocationRepository locationRepository;
    private final OfficerRepository officerRepository;
    private final NotificationService notificationService;

    @Override
    @Transactional
    public WatchGroupResponse createWatchGroup(UUID creatorId, CreateWatchGroupRequest request) {
        try {
            log.info("Creating watch group: name={}, locationId={}, creatorId={}", 
                    request.getName(), request.getLocationId(), creatorId);
            
            // Fetch creator and location
            User creator = userRepository.findById(creatorId)
                    .orElseThrow(() -> {
                        log.error("Creator not found: {}", creatorId);
                        return new IllegalArgumentException("Creator not found");
                    });
            
            Location location = locationRepository.findById(request.getLocationId())
                    .orElseThrow(() -> {
                        log.error("Location not found: {}", request.getLocationId());
                        return new IllegalArgumentException("Location not found");
                    });

            // Create watch group
            Instant now = Instant.now();
            WatchGroup watchGroup = WatchGroup.builder()
                    .name(request.getName())
                    .description(request.getDescription())
                    .location(location)
                    .createdBy(creatorId)
                    .status(WatchGroupStatus.PENDING) // Explicitly set status
                    .build();
            
            // Set audit fields manually since AbstractAuditEntity doesn't use @SuperBuilder
            watchGroup.setCreatedAt(now);
            watchGroup.setUpdatedAt(now);

            // Set assigned officer if provided
            if (request.getAssignedOfficerId() != null) {
                Officer officer = officerRepository.findById(request.getAssignedOfficerId())
                        .orElseThrow(() -> {
                            log.error("Officer not found: {}", request.getAssignedOfficerId());
                            return new IllegalArgumentException("Officer not found");
                        });
                watchGroup.setAssignedOfficer(officer);
            }

            // Save the group first to get an ID
            log.debug("Saving watch group entity...");
            WatchGroup savedGroup = watchGroupRepository.save(watchGroup);
            log.debug("Watch group saved with ID: {}", savedGroup.getId());

            // Add creator as first member and admin
            WatchGroupMember creatorMember = WatchGroupMember.builder()
                    .user(creator)
                    .group(savedGroup)
                    .joinedAt(now)
                    .isAdmin(true)
                    .isActive(true)
                    .build();
            
            // Set audit fields manually since AbstractAuditEntity doesn't use @SuperBuilder
            creatorMember.setCreatedAt(now);
            creatorMember.setUpdatedAt(now);

            log.debug("Saving watch group member...");
            watchGroupMemberRepository.save(creatorMember);
            log.debug("Watch group member saved");

            // Refresh the group to get the updated members
            savedGroup = watchGroupRepository.findById(savedGroup.getId()).orElse(savedGroup);
            
            // Notify admins about new watch group (if no officer assigned, it needs approval)
            if (request.getAssignedOfficerId() == null) {
                try {
                    // Find admin users and notify them
                    List<User> adminUsers = userRepository.findByRole(UserRole.ADMIN);
                    log.debug("Notifying {} admin users about new watch group", adminUsers.size());
                    for (User admin : adminUsers) {
                        notificationService.notifyGroupCreated(
                            admin.getId(), 
                            savedGroup.getId(), 
                            savedGroup.getName(), 
                            creator.getFullName()
                        );
                    }
                } catch (Exception e) {
                    log.warn("Failed to send admin notifications for new group: {}", e.getMessage(), e);
                }
            }

            log.info("Successfully created watch group with ID: {}", savedGroup.getId());
            return buildWatchGroupResponse(savedGroup, creatorId, creator);
        } catch (IllegalArgumentException e) {
            log.error("Validation error creating watch group: {}", e.getMessage(), e);
            throw e;
        } catch (Exception e) {
            log.error("Unexpected error creating watch group: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to create watch group: " + e.getMessage(), e);
        }
    }

    @Override
    @Transactional(readOnly = true)
    public WatchGroupResponse getWatchGroupById(UUID groupId, UUID userId) {
        WatchGroup watchGroup = watchGroupRepository.findById(groupId)
                .orElseThrow(() -> new IllegalArgumentException("Watch group not found"));

        // Check if user has access to this group
        if (!isUserMemberOfGroup(userId, groupId)) {
            throw new SecurityException("You do not have access to this watch group");
        }

        return buildWatchGroupResponse(watchGroup, userId);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<WatchGroupResponse> getUserWatchGroups(UUID userId, Pageable pageable) {
        Page<WatchGroup> groups = watchGroupRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable);
        return groups.map(group -> buildWatchGroupResponse(group, userId));
    }

    @Override
    @Transactional(readOnly = true)
    public Page<WatchGroupResponse> getWatchGroupsByLocation(UUID locationId, Pageable pageable) {
        Page<WatchGroup> groups = watchGroupRepository.findByLocationIdOrderByCreatedAtDesc(locationId, pageable);
        return groups.map(group -> buildWatchGroupResponse(group, null));
    }

    @Override
    @Transactional(readOnly = true)
    public Page<WatchGroupResponse> getAllWatchGroups(Pageable pageable, Double latitude, Double longitude, Double radius) {
        // Get only approved and active watch groups for browsing
        List<WatchGroupStatus> allowedStatuses = List.of(WatchGroupStatus.APPROVED, WatchGroupStatus.ACTIVE);
        Page<WatchGroup> groups = watchGroupRepository.findByStatusInOrderByCreatedAtDesc(allowedStatuses, pageable);
        
        // If location filtering is requested, filter by distance
        if (latitude != null && longitude != null && radius != null) {
            // Filter groups by location proximity
            List<WatchGroup> filteredGroups = groups.getContent().stream()
                .filter(group -> {
                    if (group.getLocation() != null && group.getLocation().getLatitude() != null && group.getLocation().getLongitude() != null) {
                        double distance = calculateDistance(
                            latitude, longitude,
                            group.getLocation().getLatitude(),
                            group.getLocation().getLongitude()
                        );
                        return distance <= radius;
                    }
                    return false;
                })
                .collect(Collectors.toList());
            
            // Create a new page with filtered results
            // Note: This is a simplified approach - for better performance, consider using native SQL query
            return new org.springframework.data.domain.PageImpl<>(
                filteredGroups.stream()
                    .map(group -> buildWatchGroupResponse(group, null))
                    .collect(Collectors.toList()),
                pageable,
                filteredGroups.size()
            );
        }
        
        return groups.map(group -> buildWatchGroupResponse(group, null));
    }

    // Helper method to calculate distance between two coordinates (Haversine formula)
    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371; // Earth's radius in kilometers
        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }

    @Override
    @Transactional
    public WatchGroupResponse joinWatchGroup(UUID userId, UUID groupId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        WatchGroup group = watchGroupRepository.findById(groupId)
                .orElseThrow(() -> new IllegalArgumentException("Watch group not found"));

        // Check if user is already a member
        if (isUserMemberOfGroup(userId, groupId)) {
            throw new IllegalArgumentException("User is already a member of this group");
        }

        // Add user to group
        Instant now = Instant.now();
        WatchGroupMember member = WatchGroupMember.builder()
                .user(user)
                .group(group)
                .joinedAt(now)
                .isAdmin(false)
                .isActive(true)
                .build();
        
        // Set audit fields manually since AbstractAuditEntity doesn't use @SuperBuilder
        member.setCreatedAt(now);
        member.setUpdatedAt(now);

        watchGroupMemberRepository.save(member);

        return buildWatchGroupResponse(group, userId);
    }

    @Override
    @Transactional
    public void leaveWatchGroup(UUID userId, UUID groupId) {
        WatchGroupMember member = watchGroupMemberRepository.findByUserIdAndGroupId(userId, groupId)
                .orElseThrow(() -> new IllegalArgumentException("User is not a member of this group"));

        // Check if user is the last admin
        if (member.isAdmin() && isLastAdminInGroup(groupId)) {
            throw new IllegalStateException("Cannot leave group as last admin. Please assign another admin first.");
        }

        watchGroupMemberRepository.delete(member);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<WatchGroupResponse> getPendingWatchGroups(UUID officerId, Pageable pageable) {
        // Return only groups with PENDING status
        // TODO: Implement proper filtering by officer jurisdiction
        List<WatchGroupStatus> pendingStatus = List.of(WatchGroupStatus.PENDING);
        Page<WatchGroup> pendingGroups = watchGroupRepository.findByStatusInOrderByCreatedAtDesc(pendingStatus, pageable);
        return pendingGroups.map(group -> buildWatchGroupResponse(group, null));
    }

    @Override
    @Transactional
    public WatchGroupResponse approveWatchGroup(UUID groupId, UUID officerId) {
        WatchGroup group = watchGroupRepository.findById(groupId)
                .orElseThrow(() -> new IllegalArgumentException("Watch group not found"));
        
        Officer officer = officerRepository.findById(officerId)
                .orElseThrow(() -> new IllegalArgumentException("Officer not found"));

        group.setStatus(WatchGroupStatus.APPROVED);
        group.setAssignedOfficer(officer);
        group.setApprovedAt(Instant.now());
        group.setApprovedBy(officerId);

        WatchGroup savedGroup = watchGroupRepository.save(group);
        
        // Send notification to group creator
        try {
            List<WatchGroupMember> members = watchGroupMemberRepository.findByGroupId(groupId);
            if (!members.isEmpty()) {
                WatchGroupMember creator = members.stream()
                    .filter(WatchGroupMember::isAdmin)
                    .findFirst()
                    .orElse(members.get(0));
                
                notificationService.notifyGroupApproved(
                    creator.getId(), 
                    groupId, 
                    group.getName(), 
                    officer.getFullName()
                );
            }
        } catch (Exception e) {
            log.warn("Failed to send group approval notification: {}", e.getMessage());
        }
        
        return buildWatchGroupResponse(savedGroup, officerId);
    }

    @Override
    @Transactional
    public void rejectWatchGroup(UUID groupId, UUID officerId, String rejectionReason) {
        WatchGroup group = watchGroupRepository.findById(groupId)
                .orElseThrow(() -> new IllegalArgumentException("Watch group not found"));

        group.setStatus(WatchGroupStatus.REJECTED);
        group.setRejectionReason(rejectionReason);

        watchGroupRepository.save(group);
        
        // Send notification to group creator
        try {
            List<WatchGroupMember> members = watchGroupMemberRepository.findByGroupId(groupId);
            if (!members.isEmpty()) {
                WatchGroupMember creator = members.stream()
                    .filter(WatchGroupMember::isAdmin)
                    .findFirst()
                    .orElse(members.get(0));
                
                notificationService.notifyGroupRejected(
                    creator.getUser().getId(), 
                    groupId, 
                    group.getName(), 
                    rejectionReason
                );
            }
        } catch (Exception e) {
            log.warn("Failed to send group rejection notification: {}", e.getMessage());
        }
    }

    @Override
    @Transactional
    public WatchGroupResponse assignOfficerToGroup(UUID groupId, UUID officerId, UUID assignedBy) {
        // Check if assignedBy has permission (admin or police officer)
        User assigner = userRepository.findById(assignedBy)
                .orElseThrow(() -> new IllegalArgumentException("Assigner not found"));
        
        if (!assigner.getRole().name().equals("ADMIN") && !assigner.getRole().name().equals("POLICE_OFFICER")) {
            throw new SecurityException("Only admins and police officers can assign officers to groups");
        }

        WatchGroup group = watchGroupRepository.findById(groupId)
                .orElseThrow(() -> new IllegalArgumentException("Watch group not found"));
        Officer officer = officerRepository.findById(officerId)
                .orElseThrow(() -> new IllegalArgumentException("Officer not found"));

        group.setAssignedOfficer(officer);
        group.setStatus(WatchGroupStatus.APPROVED);
        group.setApprovedAt(Instant.now());
        group.setApprovedBy(assignedBy);
        
        WatchGroup savedGroup = watchGroupRepository.save(group);
        
        // Send notification to assigned officer
        try {
            notificationService.notifyGroupOfficerAssigned(
                groupId, 
                group.getName(), 
                officerId, 
                officer.getFullName()
            );
        } catch (Exception e) {
            log.warn("Failed to send officer assignment notification: {}", e.getMessage());
        }

        return buildWatchGroupResponse(savedGroup, assignedBy);
    }

    @Override
    @Transactional
    public void removeOfficerFromGroup(UUID groupId, UUID removedBy) {
        // Check if removedBy has permission (admin or police officer)
        User remover = userRepository.findById(removedBy)
                .orElseThrow(() -> new IllegalArgumentException("Remover not found"));
        
        if (!remover.getRole().name().equals("ADMIN") && !remover.getRole().name().equals("POLICE_OFFICER")) {
            throw new SecurityException("Only admins and police officers can remove officers from groups");
        }

        WatchGroup group = watchGroupRepository.findById(groupId)
                .orElseThrow(() -> new IllegalArgumentException("Watch group not found"));

        group.setAssignedOfficer(null);
        watchGroupRepository.save(group);
    }

    @Override
    @Transactional
    public WatchGroupResponse updateWatchGroup(UUID groupId, UUID userId, String name, String description) {
        WatchGroup group = watchGroupRepository.findById(groupId)
                .orElseThrow(() -> new IllegalArgumentException("Watch group not found"));

        // Check if user is creator or admin
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        
        boolean isCreator = group.getCreatedBy() != null && group.getCreatedBy().equals(userId);
        boolean isAdmin = isUserAdminOfGroup(userId, groupId);
        
        if (!isCreator && !isAdmin && !user.getRole().name().equals("ADMIN")) {
            throw new SecurityException("Only the creator, group admin, or system admin can update this group");
        }

        // Update fields if provided
        if (name != null && !name.trim().isEmpty()) {
            group.setName(name.trim());
        }
        if (description != null) {
            group.setDescription(description);
        }

        group.setUpdatedAt(Instant.now());
        WatchGroup savedGroup = watchGroupRepository.save(group);

        return buildWatchGroupResponse(savedGroup, userId);
    }

    @Override
    @Transactional
    public void deleteWatchGroup(UUID groupId, UUID userId) {
        WatchGroup group = watchGroupRepository.findById(groupId)
                .orElseThrow(() -> new IllegalArgumentException("Watch group not found"));

        // Check if user is creator or admin
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        
        // Check if user is the creator by looking at the first member (who should be the creator)
        boolean isCreator = false;
        List<WatchGroupMember> members = watchGroupMemberRepository.findByGroupId(groupId);
        if (!members.isEmpty()) {
            WatchGroupMember firstMember = members.get(0);
            isCreator = firstMember.getUser().getId().equals(userId) && firstMember.isAdmin();
        }
        
        boolean isAdmin = isUserAdminOfGroup(userId, groupId);
        boolean isSystemAdmin = user.getRole().name().equals("ADMIN");
        boolean isGroupApproved = group.getStatus() != null && 
            (group.getStatus().name().equals("APPROVED") || group.getAssignedOfficer() != null);
        
        log.info("Delete check - User: {}, Group: {}, isCreator: {}, isAdmin: {}, isSystemAdmin: {}, isGroupApproved: {}", 
            userId, groupId, isCreator, isAdmin, isSystemAdmin, isGroupApproved);
        
        if (!isCreator && !isAdmin && !isSystemAdmin) {
            throw new SecurityException("Only the creator, group admin, or system admin can delete this group");
        }

        // If system admin, allow deletion regardless of status
        if (isSystemAdmin) {
            log.info("Group {} deleted by system admin {}", groupId, userId);
            watchGroupRepository.delete(group);
            return;
        }

        // If creator, only allow deletion of UNAPPROVED groups
        if (isCreator) {
            if (isGroupApproved) {
                throw new IllegalStateException("Cannot delete an approved watch group. Once a group is approved and has an assigned officer, it can only be deleted by system administrators.");
            }
            log.info("Group {} deleted by creator {} (unapproved group)", groupId, userId);
            watchGroupRepository.delete(group);
            return;
        }

        // For group admins, check if they're the only admin
        if (isAdmin) {
            long adminCount = watchGroupMemberRepository.countByGroupIdAndIsAdminTrueAndIsActiveTrue(groupId);
            if (adminCount > 1) {
                throw new IllegalStateException("Cannot delete group as you're not the only admin. Please transfer admin rights first.");
            }
            
            // Check if group has active members (other than the deleter)
            long activeMemberCount = members.stream()
                    .filter(member -> member.isActive() && !member.getUser().getId().equals(userId))
                    .count();
            
            if (activeMemberCount > 0) {
                throw new IllegalStateException("Cannot delete group with active members. Please remove all members first.");
            }
        }

        // Delete the group (cascade will handle members and messages)
        log.info("Group {} deleted by admin {}", groupId, userId);
        watchGroupRepository.delete(group);
    }

    private boolean isUserMemberOfGroup(UUID userId, UUID groupId) {
        return watchGroupMemberRepository.existsByUserIdAndGroupIdAndIsActiveTrue(userId, groupId);
    }

    private boolean isLastAdminInGroup(UUID groupId) {
        long adminCount = watchGroupMemberRepository.countByGroupIdAndIsAdminTrueAndIsActiveTrue(groupId);
        return adminCount <= 1;
    }

    private WatchGroupResponse buildWatchGroupResponse(WatchGroup group, UUID currentUserId) {
        return buildWatchGroupResponse(group, currentUserId, null);
    }

    private WatchGroupResponse buildWatchGroupResponse(WatchGroup group, UUID currentUserId, User creator) {
        // Explicitly fetch members from the database to avoid lazy loading issues
        List<WatchGroupMember> groupMembers = watchGroupMemberRepository.findByGroupId(group.getId());
        
        List<WatchGroupMemberResponse> members = groupMembers.stream()
                .filter(member -> member.isActive())
                .map(this::buildMemberResponse)
                .collect(Collectors.toList());

        // Check if current user is a member and admin
        boolean isMember = false;
        boolean isAdmin = false;
        
        if (currentUserId != null) {
            isMember = isUserMemberOfGroup(currentUserId, group.getId());
            isAdmin = isUserAdminOfGroup(currentUserId, group.getId());
        }

        // Fetch creator user if not provided and createdBy is set
        String creatorName = null;
        if (creator != null) {
            creatorName = creator.getFullName();
        } else if (group.getCreatedBy() != null) {
            try {
                User creatorUser = userRepository.findById(group.getCreatedBy()).orElse(null);
                if (creatorUser != null) {
                    creatorName = creatorUser.getFullName();
                }
            } catch (Exception e) {
                log.warn("Failed to fetch creator user for group {}: {}", group.getId(), e.getMessage());
            }
        }

        // Build location info - fetch location explicitly to avoid lazy loading
        WatchGroupResponse.LocationInfo locationInfo = null;
        Location loc = group.getLocation();
        if (loc != null) {
            locationInfo = WatchGroupResponse.LocationInfo.builder()
                    .id(loc.getId())
                    .address(loc.getAddress())
                    .latitude(loc.getLatitude())
                    .longitude(loc.getLongitude())
                    .district(loc.getDistrict())
                    .sector(loc.getSector())
                    .zone(loc.getZone())
                    .build();
        }

        // Fetch assigned officer info if present
        UUID assignedOfficerId = null;
        String assignedOfficerName = null;
        if (group.getAssignedOfficer() != null) {
            try {
                assignedOfficerId = group.getAssignedOfficer().getId();
                assignedOfficerName = group.getAssignedOfficer().getFullName();
            } catch (Exception e) {
                log.warn("Failed to fetch assigned officer for group {}: {}", group.getId(), e.getMessage());
            }
        }

        return WatchGroupResponse.builder()
                .id(group.getId())
                .name(group.getName())
                .description(group.getDescription())
                .createdBy(group.getCreatedBy())
                .creatorName(creatorName)
                .assignedOfficerId(assignedOfficerId)
                .assignedOfficerName(assignedOfficerName)
                .status(group.getStatus() != null ? group.getStatus().name() : "PENDING")
                .createdAt(group.getCreatedAt())
                .updatedAt(group.getUpdatedAt())
                .members(members)
                .memberCount(members.size())
                .location(locationInfo)
                .isMember(isMember)
                .isAdmin(isAdmin)
                .build();
    }

    private WatchGroupMemberResponse buildMemberResponse(WatchGroupMember member) {
        return WatchGroupMemberResponse.builder()
                .id(member.getId())
                .userId(member.getUser().getId())
                .userName(member.getUser().getFullName())
                .userEmail(member.getUser().getEmail())
                .groupId(member.getGroup().getId())
                .groupName(member.getGroup().getName())
                .joinedAt(member.getJoinedAt())
                .isAdmin(member.isAdmin())
                .createdAt(member.getCreatedAt())
                .updatedAt(member.getUpdatedAt())
                .build();
    }

    private boolean isUserAdminOfGroup(UUID userId, UUID groupId) {
        return watchGroupMemberRepository.existsByUserIdAndGroupIdAndIsAdminTrueAndIsActiveTrue(userId, groupId);
    }
} 