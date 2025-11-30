package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.dto.officer.*;
import com.crimeprevention.crime_backend.core.mapper.OfficerMapper;
import com.crimeprevention.crime_backend.core.model.user.Officer;
import com.crimeprevention.crime_backend.core.repo.user.OfficerRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.OfficerOperationsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class OfficerOperationsServiceImpl implements OfficerOperationsService {
    private final OfficerRepository officerRepository;
    private final OfficerMapper officerMapper;

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
    public MessageDTO sendMessage(UUID officerId, SendMessageDTO messageDto) {
        // Implementation here
        return null;
    }

    @Override
    @Transactional
    public BackupResponseDTO requestBackup(BackupRequestDTO request) {
        // Implementation here
        return null;
    }

    @Override
    @Transactional(readOnly = true)
    public List<OfficerDTO> getAvailableOfficersForBackup(LocationUpdateDTO location) {
        // Implementation here
        return null;
    }
}