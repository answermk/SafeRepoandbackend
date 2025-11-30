package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.dto.message.CreateMessageRequest;
import com.crimeprevention.crime_backend.core.dto.message.MessageResponse;
import com.crimeprevention.crime_backend.core.dto.message.UpdateMessageRequest;
import com.crimeprevention.crime_backend.core.model.chat.Message;
import com.crimeprevention.crime_backend.core.model.report.Report;
import com.crimeprevention.crime_backend.core.model.user.User;
import com.crimeprevention.crime_backend.core.repo.chat.MessageRepository;
import com.crimeprevention.crime_backend.core.repo.report.ReportRepository;
import com.crimeprevention.crime_backend.core.repo.user.UserRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.MessageService;
import com.crimeprevention.crime_backend.core.service.interfaces.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class MessageServiceImpl implements MessageService {

    private final MessageRepository messageRepository;
    private final UserRepository userRepository;
    private final ReportRepository reportRepository;
    private final NotificationService notificationService;
    private final SimpMessagingTemplate messagingTemplate;

    @Override
    @Transactional
    public MessageResponse sendMessage(UUID senderId, UUID receiverId, CreateMessageRequest request) {
        // Validate inputs
        if (senderId == null) {
            throw new IllegalArgumentException("Sender ID is required");
        }
        if (receiverId == null) {
            throw new IllegalArgumentException("Receiver ID is required");
        }
        // Allow empty message if there's an attachment
        if (request == null) {
            throw new IllegalArgumentException("Message request is required");
        }
        if ((request.getMessage() == null || request.getMessage().trim().isEmpty()) 
            && (request.getAttachmentUrl() == null || request.getAttachmentUrl().trim().isEmpty())) {
            throw new IllegalArgumentException("Message content or attachment is required");
        }
        
        // Fetch users
        User sender = userRepository.findById(senderId)
                .orElseThrow(() -> new IllegalArgumentException("Sender not found with ID: " + senderId));
        User receiver = userRepository.findById(receiverId)
                .orElseThrow(() -> new IllegalArgumentException("Receiver not found with ID: " + receiverId));

        // Permission check
        if (!hasPermissionToMessage(sender, receiver)) {
            throw new SecurityException("You do not have permission to message this user");
        }

        // Build Message entity
        // Note: AbstractAuditEntity requires createdAt to be set manually before save
        Instant now = Instant.now();
        // Handle message content - use empty string if null, otherwise trim
        String messageContent = request.getMessage() != null ? request.getMessage().trim() : "";
        // If message is empty but has attachment, use a default message
        if (messageContent.isEmpty() && request.getAttachmentUrl() != null && !request.getAttachmentUrl().trim().isEmpty()) {
            messageContent = "📎 File attachment";
        }
        
        Message message = Message.builder()
                .sender(sender)
                .receiver(receiver)
                .message(messageContent)
                .sentAt(now)
                .attachmentUrl(request.getAttachmentUrl())
                .attachmentName(request.getAttachmentName())
                .attachmentType(request.getAttachmentType())
                .isRead(false)
                .isEdited(false)
                .isDeleted(false)
                .build();
        
        // Set createdAt for AbstractAuditEntity
        message.setCreatedAt(now);
        message.setUpdatedAt(now);

        // Set report if provided
        if (request.getReportId() != null) {
            try {
                Report report = reportRepository.findById(request.getReportId())
                        .orElseThrow(() -> new IllegalArgumentException("Report not found with ID: " + request.getReportId()));
                message.setReport(report);
            } catch (Exception e) {
                log.warn("Failed to set report for message: {}", e.getMessage());
                // Continue without report if it fails
            }
        }

        try {
            Message savedMessage = messageRepository.save(message);
            MessageResponse messageResponse = buildMessageResponse(savedMessage);
            
            // Send notification to receiver (database notification)
            try {
                String messagePreview = messageContent.length() > 50 ? 
                    messageContent.substring(0, 50) + "..." : messageContent;
                notificationService.notifyNewMessage(receiverId, senderId, messagePreview);
            } catch (Exception e) {
                log.warn("Failed to send notification for message: {}", e.getMessage());
                // Don't fail the message send if notification fails
            }
            
            // Send real-time message via WebSocket to receiver
            try {
                messagingTemplate.convertAndSendToUser(
                    receiverId.toString(),
                    "/queue/messages",
                    messageResponse
                );
                log.info("Sent real-time message via WebSocket to user: {}", receiverId);
            } catch (Exception e) {
                log.warn("Failed to send WebSocket message: {}", e.getMessage());
                // Don't fail the message send if WebSocket fails
            }
            
            // Note: Database notification is already created above
            // WebSocket notification will be handled by NotificationService if needed
            
            return messageResponse;
        } catch (Exception e) {
            log.error("Error saving message: senderId={}, receiverId={}, error={}", 
                    senderId, receiverId, e.getMessage(), e);
            throw new RuntimeException("Failed to save message: " + e.getMessage(), e);
        }
    }

    @Override
    @Transactional(readOnly = true)
    public List<MessageResponse> getMessagesBetween(UUID user1, UUID user2) {
        // Get messages sent from user1 to user2 and vice versa, combine & sort by sentAt
        // Filter out deleted messages
        List<Message> messagesSent = messageRepository.findBySenderId(user1).stream()
                .filter(msg -> msg.getReceiver().getId().equals(user2))
                .filter(msg -> msg.getIsDeleted() == null || !msg.getIsDeleted())
                .collect(Collectors.toList());

        List<Message> messagesReceived = messageRepository.findBySenderId(user2).stream()
                .filter(msg -> msg.getReceiver().getId().equals(user1))
                .filter(msg -> msg.getIsDeleted() == null || !msg.getIsDeleted())
                .collect(Collectors.toList());

        // Combine lists
        List<Message> allMessages = messagesSent;
        allMessages.addAll(messagesReceived);

        // Sort by sentAt ascending
        allMessages.sort((m1, m2) -> m1.getSentAt().compareTo(m2.getSentAt()));

        // Map to responses
        return allMessages.stream()
                .map(this::buildMessageResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<MessageResponse> getInbox(UUID receiverId, Pageable pageable) {
        Page<Message> inboxMessages = messageRepository.findByReceiverIdOrderBySentAtDesc(receiverId, pageable);
        return inboxMessages.map(this::buildMessageResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<MessageResponse> getSentMessages(UUID senderId, Pageable pageable) {
        Page<Message> sentMessages = messageRepository.findBySenderIdOrderBySentAtDesc(senderId, pageable);
        return sentMessages.map(this::buildMessageResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public List<MessageResponse> getMessagesByReport(UUID reportId) {
        List<Message> reportMessages = messageRepository.findByReportIdOrderBySentAtAsc(reportId);
        return reportMessages.stream()
                .map(this::buildMessageResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public MessageResponse updateMessage(UUID messageId, UUID userId, UpdateMessageRequest request) {
        Message message = messageRepository.findById(messageId)
                .orElseThrow(() -> new IllegalArgumentException("Message not found"));

        // Check if user is the sender or an admin
        if (!message.getSender().getId().equals(userId)) {
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new IllegalArgumentException("User not found"));
            if (!user.getRole().name().equals("ADMIN")) {
                throw new SecurityException("Only the message sender or admin can update messages");
            }
        }

        // Check if message is deleted
        if (message.getIsDeleted() != null && message.getIsDeleted()) {
            throw new IllegalArgumentException("Cannot update a deleted message");
        }

        // Update message content
        message.setMessage(request.getMessage());
        message.setIsEdited(true);
        message.setEditedAt(Instant.now());
        message.setUpdatedAt(Instant.now());

        Message updatedMessage = messageRepository.save(message);
        return buildMessageResponse(updatedMessage);
    }

    @Override
    @Transactional
    public void deleteMessage(UUID messageId, UUID userId) {
        Message message = messageRepository.findById(messageId)
                .orElseThrow(() -> new IllegalArgumentException("Message not found"));

        // Check if user is the sender or an admin
        if (!message.getSender().getId().equals(userId)) {
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new IllegalArgumentException("User not found"));
            if (!user.getRole().name().equals("ADMIN")) {
                throw new SecurityException("Only the message sender or admin can delete messages");
            }
        }

        // Soft delete - mark as deleted instead of hard delete
        message.setIsDeleted(true);
        message.setDeletedAt(Instant.now());
        message.setUpdatedAt(Instant.now());
        messageRepository.save(message);
    }

    @Override
    @Transactional
    public void markMessageAsRead(UUID messageId, UUID userId) {
        Message message = messageRepository.findById(messageId)
                .orElseThrow(() -> new IllegalArgumentException("Message not found"));

        // Check if user is the receiver
        if (!message.getReceiver().getId().equals(userId)) {
            throw new SecurityException("Only the message receiver can mark it as read");
        }

        // Mark as read
        message.setIsRead(true);
        message.setReadAt(Instant.now());
        message.setUpdatedAt(Instant.now());
        messageRepository.save(message);
    }

    @Override
    @Transactional
    public void markConversationAsRead(UUID conversationUserId, UUID currentUserId) {
        // Get all unread messages from conversationUserId to currentUserId
        List<Message> unreadMessages = messageRepository.findBySenderId(conversationUserId).stream()
                .filter(msg -> msg.getReceiver().getId().equals(currentUserId))
                .filter(msg -> msg.getIsDeleted() == null || !msg.getIsDeleted())
                .filter(msg -> msg.getIsRead() == null || !msg.getIsRead())
                .collect(Collectors.toList());

        Instant now = Instant.now();
        for (Message message : unreadMessages) {
            message.setIsRead(true);
            message.setReadAt(now);
            message.setUpdatedAt(now);
        }

        if (!unreadMessages.isEmpty()) {
            messageRepository.saveAll(unreadMessages);
        }
    }

    /**
     * Check if sender can message receiver.
     * Rules: Users can message officers, officers can message users, 
     * users can message users in same watch groups
     */
    private boolean hasPermissionToMessage(User sender, User receiver) {
        // Allow all for now - implement specific rules later
        return true;
    }

    private MessageResponse buildMessageResponse(Message message) {
        return MessageResponse.builder()
                .id(message.getId())
                .senderId(message.getSender() != null ? message.getSender().getId() : null)
                .senderName(message.getSender() != null && message.getSender().getFullName() != null 
                        ? message.getSender().getFullName() : "Unknown")
                .senderEmail(message.getSender() != null ? message.getSender().getEmail() : null)
                .receiverId(message.getReceiver() != null ? message.getReceiver().getId() : null)
                .receiverName(message.getReceiver() != null && message.getReceiver().getFullName() != null 
                        ? message.getReceiver().getFullName() : "Unknown")
                .receiverEmail(message.getReceiver() != null ? message.getReceiver().getEmail() : null)
                .reportId(message.getReport() != null ? message.getReport().getId() : null)
                .reportTitle(message.getReport() != null ? message.getReport().getTitle() : null)
                .message(message.getMessage())
                .sentAt(message.getSentAt())
                .createdAt(message.getCreatedAt() != null ? message.getCreatedAt() : Instant.now())
                .updatedAt(message.getUpdatedAt() != null ? message.getUpdatedAt() : Instant.now())
                .attachmentUrl(message.getAttachmentUrl())
                .attachmentName(message.getAttachmentName())
                .attachmentType(message.getAttachmentType())
                .isRead(message.getIsRead() != null ? message.getIsRead() : false)
                .readAt(message.getReadAt())
                .isEdited(message.getIsEdited() != null ? message.getIsEdited() : false)
                .editedAt(message.getEditedAt())
                .isDeleted(message.getIsDeleted() != null ? message.getIsDeleted() : false)
                .deletedAt(message.getDeletedAt())
                .build();
    }
}
