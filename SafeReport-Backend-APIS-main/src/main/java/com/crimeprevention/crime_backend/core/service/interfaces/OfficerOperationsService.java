package com.crimeprevention.crime_backend.core.service.interfaces;

import com.crimeprevention.crime_backend.core.dto.officer.*;
import java.util.List;
import java.util.UUID;

public interface OfficerOperationsService {
    void updateOfficerLocation(UUID officerId, LocationUpdateDTO location);
    MessageDTO sendMessage(UUID officerId, SendMessageDTO message);
    BackupResponseDTO requestBackup(BackupRequestDTO request);
    List<OfficerDTO> getAvailableOfficersForBackup(LocationUpdateDTO location);
}