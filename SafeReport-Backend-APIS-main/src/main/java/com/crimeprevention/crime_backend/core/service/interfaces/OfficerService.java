package com.crimeprevention.crime_backend.core.service.interfaces;

import com.crimeprevention.crime_backend.core.dto.officer.*;
import com.crimeprevention.crime_backend.core.dto.user.RegisterOfficerRequest;
import com.crimeprevention.crime_backend.core.model.user.Officer;

import java.util.List;
import java.util.UUID;

public interface OfficerService {
    OfficerDTO registerOfficer(RegisterOfficerRequest request);
    OfficerDTO getOfficerById(UUID id);
    List<OfficerDTO> getAllOfficers();
    OfficerDTO updateOfficer(UUID id, UpdateOfficerRequest request);
    void deactivateOfficer(UUID id);
    void updateOfficerLocation(UUID officerId, LocationUpdateDTO location);
    MessageDTO sendMessage(UUID officerId, SendMessageDTO message);
    List<OfficerDTO> getAvailableOfficersForBackup(BackupRequestDTO.LocationDTO location);
    List<MessageDTO> getOfficerMessages(UUID officerId);
    List<NotificationDTO> getOfficerNotifications(UUID officerId);
    void markNotificationRead(UUID officerId, UUID notificationId);
}