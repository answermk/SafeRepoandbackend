package com.crimeprevention.crime_backend.core.service.interfaces;

import com.crimeprevention.crime_backend.core.dto.officer.BackupRequestDTO;
import com.crimeprevention.crime_backend.core.dto.officer.BackupResponseDTO;
import java.util.List;
import java.util.UUID;

public interface BackupService {
    BackupResponseDTO requestBackup(UUID officerId, BackupRequestDTO request);
    void cancelBackupRequest(UUID officerId);
    List<BackupResponseDTO> getActiveBackupRequests();
    List<BackupResponseDTO> getBackupsByReport(UUID reportId);
}