package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.dto.officer.*;
import com.crimeprevention.crime_backend.core.dto.user.RegisterOfficerRequest;
import com.crimeprevention.crime_backend.core.dto.message.CreateMessageRequest;
import com.crimeprevention.crime_backend.core.dto.message.MessageResponse;
import com.crimeprevention.crime_backend.core.dto.notification.NotificationResponse;
import com.crimeprevention.crime_backend.core.mapper.OfficerMapper;
import com.crimeprevention.crime_backend.core.model.user.Officer;
import com.crimeprevention.crime_backend.core.repo.user.OfficerRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.OfficerService;
import com.crimeprevention.crime_backend.core.service.interfaces.NotificationService;
import com.crimeprevention.crime_backend.core.service.interfaces.MessageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class OfficerServiceImpl implements OfficerService {
    private final OfficerRepository officerRepository;
    private final OfficerMapper officerMapper;
    private final NotificationService notificationService;
    private final MessageService messageService;
    private final org.springframework.security.crypto.password.PasswordEncoder passwordEncoder;
    private final com.crimeprevention.crime_backend.core.service.interfaces.EmailService emailService;

    @Override
    @Transactional
    public OfficerDTO registerOfficer(RegisterOfficerRequest request) {
        System.out.println("🔵 Creating officer with role: " + request.getRole());
        System.out.println("🔵 Officer details - Name: " + request.getFullName() + ", Email: " + request.getEmail());
        
        Officer officer = Officer.builder()
            .fullName(request.getFullName())
            .email(request.getEmail())
            .phoneNumber(request.getPhoneNumber())
            .username(request.getUsername())
            .passwordHash(passwordEncoder.encode(request.getPassword()))  // Encode password!
            .role(com.crimeprevention.crime_backend.core.model.enums.UserRole.OFFICER)  // Set user role
            .officerRoleType(request.getRole())  // Set officer role type
            .dutyStatus(com.crimeprevention.crime_backend.core.model.enums.DutyStatus.OFF_DUTY)  // Default duty status
            .enabled(true)  // Set as enabled
            .isActive(true)  // Set as active
            .build();
        
        officer = officerRepository.save(officer);
        System.out.println("✅ Officer created successfully with ID: " + officer.getId());
        
        // Try to send welcome email, but don't fail if email service is down
        try {
            emailService.sendWelcomeEmail(officer.getEmail(), officer.getFullName());
        } catch (Exception e) {
            System.err.println("⚠️ Warning: Failed to send welcome email to " + officer.getEmail() + ": " + e.getMessage());
            // Continue anyway - officer was created successfully
        }
        
        return officerMapper.toDto(officer);
    }

    @Override
    @Transactional(readOnly = true)
    public OfficerDTO getOfficerById(UUID id) {
        Officer officer = officerRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Officer not found"));
        return officerMapper.toDto(officer);
    }

    @Override
    @Transactional(readOnly = true)
    public List<OfficerDTO> getAllOfficers() {
        List<Officer> officers = officerRepository.findAll();
        return officerMapper.toDtoList(officers);
    }

    @Override
    @Transactional
    public OfficerDTO updateOfficer(UUID id, UpdateOfficerRequest request) {
        Officer officer = officerRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Officer not found"));
        officer.setFullName(request.getFullName());
        officer.setPhoneNumber(request.getPhoneNumber());
        officer = officerRepository.save(officer);
        return officerMapper.toDto(officer);
    }

    @Override
    @Transactional
    public void deactivateOfficer(UUID id) {
        Officer officer = officerRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Officer not found"));
        officer.setActive(false);
        officerRepository.save(officer);
    }

    @Override
    @Transactional
    public void updateOfficerLocation(UUID officerId, LocationUpdateDTO location) {
        Officer officer = officerRepository.findById(officerId)
            .orElseThrow(() -> new RuntimeException("Officer not found"));
        officer.setLocation(Officer.Location.builder()
            .latitude(location.getLat())
            .longitude(location.getLng())
            .build());
        officerRepository.save(officer);
    }

    @Override
    @Transactional
    public MessageDTO sendMessage(UUID officerId, SendMessageDTO message) {
        // Validate recipientId
        if (message == null) {
            throw new IllegalArgumentException("Message DTO is required");
        }
        if (message.getRecipientId() == null) {
            throw new IllegalArgumentException("Recipient ID is required");
        }
        
        // Validate message content - allow empty if there's an attachment
        if ((message.getMessage() == null || message.getMessage().trim().isEmpty()) 
            && (message.getAttachmentUrl() == null || message.getAttachmentUrl().trim().isEmpty())) {
            throw new IllegalArgumentException("Message content or attachment is required");
        }
        
        // Convert SendMessageDTO to CreateMessageRequest
        CreateMessageRequest request = new CreateMessageRequest();
        // Handle null or empty message - set to empty string if null, otherwise trim
        String messageContent = message.getMessage() != null ? message.getMessage().trim() : "";
        request.setMessage(messageContent);
        request.setAttachmentUrl(message.getAttachmentUrl());
        request.setAttachmentName(message.getAttachmentName());
        request.setAttachmentType(message.getAttachmentType());
        
        // Send message using MessageService
        MessageResponse response = messageService.sendMessage(officerId, message.getRecipientId(), request);
        
        // Convert response to MessageDTO
        MessageDTO dto = new MessageDTO();
        dto.setId(response.getId());
        dto.setSenderId(response.getSenderId());
        dto.setRecipientId(response.getReceiverId());
        dto.setContent(response.getMessage());
        dto.setSentAt(response.getSentAt());
        
        return dto;
    }

    @Override
    @Transactional(readOnly = true)
    public List<OfficerDTO> getAvailableOfficersForBackup(BackupRequestDTO.LocationDTO location) {
        // Find all available officers (simplified - in production, filter by location)
        List<Officer> allOfficers = officerRepository.findAll();
        return officerMapper.toDtoList(allOfficers);
    }

    @Override
    @Transactional(readOnly = true)
    public List<MessageDTO> getOfficerMessages(UUID officerId) {
        // Use getInbox to get messages for the officer
        Page<MessageResponse> inboxPage = messageService.getInbox(officerId, Pageable.unpaged());
        
        // Convert to MessageDTO list
        return inboxPage.getContent().stream()
            .map(msg -> {
                MessageDTO dto = new MessageDTO();
                dto.setId(msg.getId());
                dto.setSenderId(msg.getSenderId());
                dto.setRecipientId(msg.getReceiverId());
                dto.setContent(msg.getMessage());
                dto.setSentAt(msg.getSentAt());
                return dto;
            })
            .collect(java.util.stream.Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<NotificationDTO> getOfficerNotifications(UUID officerId) {
        // Use getUnreadNotifications to get notifications for the officer
        List<NotificationResponse> notifications = notificationService.getUnreadNotifications(officerId);
        
        // Convert to NotificationDTO list
        return notifications.stream()
            .map(notif -> {
                NotificationDTO dto = new NotificationDTO();
                dto.setId(notif.getId());
                dto.setTitle(notif.getTitle());
                dto.setMessage(notif.getMessage());
                dto.setType(notif.getType());
                dto.setRead(notif.isRead());
                dto.setCreatedAt(notif.getCreatedAt());
                return dto;
            })
            .collect(java.util.stream.Collectors.toList());
    }

    @Override
    @Transactional
    public void markNotificationRead(UUID officerId, UUID notificationId) {
        // Use markNotificationAsRead (singular)
        notificationService.markNotificationAsRead(officerId, notificationId);
    }
}