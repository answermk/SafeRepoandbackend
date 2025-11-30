package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.dto.message.CreateWatchGroupMessageRequest;
import com.crimeprevention.crime_backend.core.dto.message.WatchGroupMessageResponse;
import com.crimeprevention.crime_backend.core.model.chat.WatchGroup;
import com.crimeprevention.crime_backend.core.model.chat.WatchGroupMessage;
import com.crimeprevention.crime_backend.core.model.user.User;
import com.crimeprevention.crime_backend.core.repo.chat.WatchGroupMessageRepository;
import com.crimeprevention.crime_backend.core.repo.chat.WatchGroupRepository;
import com.crimeprevention.crime_backend.core.repo.user.UserRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.WatchGroupMessageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class WatchGroupMessageServiceImpl implements WatchGroupMessageService {

    private final WatchGroupMessageRepository watchGroupMessageRepository;
    private final WatchGroupRepository watchGroupRepository;
    private final UserRepository userRepository;
    private final com.crimeprevention.crime_backend.core.repo.chat.WatchGroupMemberRepository watchGroupMemberRepository;

    @Override
    @Transactional
    public WatchGroupMessageResponse sendMessage(UUID groupId, UUID senderId, CreateWatchGroupMessageRequest request) {
        log.info("Attempting to send message to group: {}, from user: {}", groupId, senderId);
        
        // Fetch group and sender
        WatchGroup group = watchGroupRepository.findById(groupId)
                .orElseThrow(() -> new IllegalArgumentException("Watch group not found"));
        User sender = userRepository.findById(senderId)
                .orElseThrow(() -> new IllegalArgumentException("Sender not found"));

        log.info("Found group: {} and sender: {}", group.getName(), sender.getFullName());

        // Check if sender is a member of the group
        boolean isMember = isUserMemberOfGroup(senderId, groupId);
        log.info("User {} is member of group {}: {}", senderId, groupId, isMember);
        
        if (!isMember) {
            throw new SecurityException("You must be a member of this watch group to send messages");
        }

        // Create and save message
        WatchGroupMessage message = WatchGroupMessage.builder()
                .group(group)
                .sender(sender)
                .message(request.getMessage())
                .sentAt(Instant.now())
                .build();

        log.info("Saving message: {}", message.getMessage());
        WatchGroupMessage savedMessage = watchGroupMessageRepository.save(message);
        log.info("Message saved with ID: {}", savedMessage.getId());
        
        return buildWatchGroupMessageResponse(savedMessage);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<WatchGroupMessageResponse> getMessagesByGroup(UUID groupId, Pageable pageable) {
        Page<WatchGroupMessage> messages = watchGroupMessageRepository.findByGroupIdOrderBySentAtDesc(groupId, pageable);
        return messages.map(this::buildWatchGroupMessageResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public List<WatchGroupMessageResponse> getMessagesByGroup(UUID groupId) {
        List<WatchGroupMessage> messages = watchGroupMessageRepository.findByGroupIdOrderBySentAtAsc(groupId);
        return messages.stream()
                .map(this::buildWatchGroupMessageResponse)
                .collect(Collectors.toList());
    }

    /**
     * Check if user is a member of the watch group.
     */
    private boolean isUserMemberOfGroup(UUID userId, UUID groupId) {
        return watchGroupMemberRepository.existsByUserIdAndGroupIdAndIsActiveTrue(userId, groupId);
    }

    private WatchGroupMessageResponse buildWatchGroupMessageResponse(WatchGroupMessage message) {
        return WatchGroupMessageResponse.builder()
                .id(message.getId())
                .groupId(message.getGroup().getId())
                .groupName(message.getGroup().getName())
                .senderId(message.getSender().getId())
                .senderName(message.getSender().getFullName())
                .senderEmail(message.getSender().getEmail())
                .message(message.getMessage())
                .sentAt(message.getSentAt())
                .createdAt(message.getCreatedAt())
                .updatedAt(message.getUpdatedAt())
                .build();
    }
}
