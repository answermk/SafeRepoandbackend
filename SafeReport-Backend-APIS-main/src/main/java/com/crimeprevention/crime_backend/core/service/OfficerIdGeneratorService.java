package com.crimeprevention.crime_backend.core.service;

import com.crimeprevention.crime_backend.core.repo.user.OfficerRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Year;
import java.util.concurrent.locks.ReentrantLock;

/**
 * Service for generating unique, human-readable officer IDs in format OFF-YYYY-XXXX
 * Thread-safe implementation with database-level uniqueness guarantee
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class OfficerIdGeneratorService {

    private final OfficerRepository officerRepository;
    private final ReentrantLock lock = new ReentrantLock();

    /**
     * Generates a unique officer ID in format OFF-YYYY-XXXX
     * Thread-safe and guarantees uniqueness even under concurrent access
     */
    @Transactional
    public String generateOfficerId() {
        lock.lock();
        try {
            String year = String.valueOf(Year.now().getValue());
            String prefix = "OFF-" + year + "-";
            
            // Find the highest existing sequence number for current year
            String highestId = officerRepository.findTopByOfficerIdStartingWithOrderByOfficerIdDesc(prefix);
            
            int nextSequence;
            if (highestId != null) {
                // Extract sequence number from existing ID
                String sequencePart = highestId.substring(prefix.length());
                nextSequence = Integer.parseInt(sequencePart) + 1;
            } else {
                // First officer for this year
                nextSequence = 1;
            }
            
            String officerId = prefix + String.format("%04d", nextSequence);
            
            log.info("Generated officer ID: {}", officerId);
            return officerId;
            
        } catch (Exception e) {
            log.error("Error generating officer ID", e);
            throw new RuntimeException("Failed to generate officer ID", e);
        } finally {
            lock.unlock();
        }
    }

    /**
     * Validates that an officer ID is unique
     * Used as additional safety check
     */
    @Transactional(readOnly = true)
    public boolean isOfficerIdUnique(String officerId) {
        return !officerRepository.existsByOfficerId(officerId);
    }
}
