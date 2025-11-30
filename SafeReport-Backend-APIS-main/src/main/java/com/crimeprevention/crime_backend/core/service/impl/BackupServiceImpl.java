package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.dto.officer.BackupRequestDTO;
import com.crimeprevention.crime_backend.core.dto.officer.BackupResponseDTO;
import com.crimeprevention.crime_backend.core.mapper.OfficerMapper;
import com.crimeprevention.crime_backend.core.repo.user.OfficerRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.BackupService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class BackupServiceImpl implements BackupService {
    private final OfficerRepository officerRepository;
    private final OfficerMapper officerMapper;

    @Override
    @Transactional
    public BackupResponseDTO requestBackup(UUID officerId, BackupRequestDTO request) {
        // Implementation here
        return null;
    }

    @Override
    @Transactional
    public void cancelBackupRequest(UUID officerId) {
        // Implementation here
    }

    @Override
    @Transactional(readOnly = true)
    public List<BackupResponseDTO> getActiveBackupRequests() {
        // Implementation here
        return null;
    }

    @Override
    @Transactional(readOnly = true)
    public List<BackupResponseDTO> getBackupsByReport(UUID reportId) {
        // Implementation here
        return null;
    }
}