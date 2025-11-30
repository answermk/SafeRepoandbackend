package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.dto.message.CaseMessageResponse;
import com.crimeprevention.crime_backend.core.dto.message.CreateCaseMessageRequest;
import com.crimeprevention.crime_backend.core.dto.message.UpdateCaseMessageRequest;
import com.crimeprevention.crime_backend.core.model.chat.CaseMessage;
import com.crimeprevention.crime_backend.core.model.report.Report;
import com.crimeprevention.crime_backend.core.model.user.User;
import com.crimeprevention.crime_backend.core.repo.chat.CaseMessageRepository;
import com.crimeprevention.crime_backend.core.repo.report.ReportRepository;
import com.crimeprevention.crime_backend.core.repo.user.UserRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.CaseMessageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class CaseMessageServiceImpl implements CaseMessageService {

    private final CaseMessageRepository caseMessageRepository;
    private final UserRepository userRepository;
    private final ReportRepository reportRepository;

    @Override
    @Transactional
    public CaseMessageResponse sendCaseMessage(UUID senderId, CreateCaseMessageRequest request) {
        // Fetch sender and report
        User sender = userRepository.findById(senderId)
                .orElseThrow(() -> new IllegalArgumentException("Sender not found"));
        Report report = reportRepository.findById(request.getReportId())
                .orElseThrow(() -> new IllegalArgumentException("Report not found"));

        // Check if user has permission to message about this report
        if (!hasPermissionToMessageReport(sender, report)) {
            throw new SecurityException("You do not have permission to message about this report");
        }

        // Build CaseMessage entity
        CaseMessage caseMessage = CaseMessage.builder()
                .sender(sender)
                .report(report)
                .content(request.getContent())
                .timestamp(Instant.now())
                .build();

        CaseMessage savedMessage = caseMessageRepository.save(caseMessage);
        return buildCaseMessageResponse(savedMessage);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<CaseMessageResponse> getConversation(UUID reportId, Pageable pageable) {
        Page<CaseMessage> messages = caseMessageRepository.findByReportIdOrderByTimestampAsc(reportId, pageable);
        return messages.map(this::buildCaseMessageResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public List<CaseMessageResponse> getConversationAll(UUID reportId) {
        List<CaseMessage> messages = caseMessageRepository.findByReportIdOrderByTimestampAsc(reportId);
        return messages.stream()
                .map(this::buildCaseMessageResponse)
                .toList();
    }

    @Override
    @Transactional
    public CaseMessageResponse updateCaseMessage(UUID messageId, UUID userId, UpdateCaseMessageRequest request) {
        CaseMessage message = caseMessageRepository.findById(messageId)
                .orElseThrow(() -> new IllegalArgumentException("Case message not found"));

        // Check if user is the sender or an admin
        if (!message.getSender().getId().equals(userId)) {
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new IllegalArgumentException("User not found"));
            if (!user.getRole().name().equals("ADMIN")) {
                throw new SecurityException("Only the message sender or admin can update case messages");
            }
        }

        // Update message content
        message.setContent(request.getContent());
        message.setUpdatedAt(Instant.now());

        CaseMessage updatedMessage = caseMessageRepository.save(message);
        return buildCaseMessageResponse(updatedMessage);
    }

    @Override
    @Transactional
    public void deleteCaseMessage(UUID messageId, UUID userId) {
        CaseMessage message = caseMessageRepository.findById(messageId)
                .orElseThrow(() -> new IllegalArgumentException("Case message not found"));

        // Check if user is the sender or an admin
        if (!message.getSender().getId().equals(userId)) {
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new IllegalArgumentException("User not found"));
            if (!user.getRole().name().equals("ADMIN")) {
                throw new SecurityException("Only the message sender or admin can delete case messages");
            }
        }

        caseMessageRepository.delete(message);
    }

    /**
     * Check if user has permission to message about a specific report.
     * Rules: Reporter, assigned officer, or admin can message
     */
    private boolean hasPermissionToMessageReport(User user, Report report) {
        // Reporter can always message
        if (report.getReporter().getId().equals(user.getId())) {
            return true;
        }

        // Admin can always message
        if (user.getRole().name().equals("ADMIN")) {
            return true;
        }

        // Police officer can message if assigned to the report
        if (user.getRole().name().equals("POLICE_OFFICER")) {
            // Check if officer is assigned to this report
            // This would require checking the Assignment entity
            return true; // For now, allow all officers
        }

        return false;
    }

    private CaseMessageResponse buildCaseMessageResponse(CaseMessage message) {
        return CaseMessageResponse.builder()
                .id(message.getId())
                .senderId(message.getSender().getId())
                .senderName(message.getSender().getFullName())
                .senderEmail(message.getSender().getEmail())
                .reportId(message.getReport().getId())
                .reportTitle(message.getReport().getTitle())
                .content(message.getContent())
                .timestamp(message.getTimestamp())
                .createdAt(message.getCreatedAt())
                .updatedAt(message.getUpdatedAt())
                .build();
    }
} 