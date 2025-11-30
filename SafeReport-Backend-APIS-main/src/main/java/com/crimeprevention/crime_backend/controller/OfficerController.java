package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.dto.officer.OfficerDTO;
import com.crimeprevention.crime_backend.core.dto.officer.UpdateOfficerRequest;
import com.crimeprevention.crime_backend.core.dto.user.RegisterOfficerRequest;
import com.crimeprevention.crime_backend.core.service.interfaces.OfficerService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * REST controller to manage Police Officer CRUD operations.
 */
@RestController
@RequestMapping("/api/officers")
@RequiredArgsConstructor
public class OfficerController {

    private final OfficerService officerService;

    /**
     * Create a new officer.
     * Accessible only by authorized roles (implement security separately).
     *
     * @param request DTO with new officer details
     * @return created officer info
     */
    @PostMapping
    public ResponseEntity<OfficerDTO> createOfficer(@Valid @RequestBody RegisterOfficerRequest request) {
        System.out.println("🔍 STEP 3: OfficerController.createOfficer called");
        System.out.println("📋 STEP 3: Request data received:");
        System.out.println("  - fullName: " + request.getFullName());
        System.out.println("  - email: " + request.getEmail());
        System.out.println("  - phoneNumber: " + request.getPhoneNumber());
        System.out.println("  - username: " + request.getUsername());
        System.out.println("  - password: " + (request.getPassword() != null ? "***HIDDEN***" : "NULL"));
        System.out.println("  - role: " + request.getRole());
        System.out.println("  - role type: " + (request.getRole() != null ? request.getRole().getClass().getSimpleName() : "NULL"));
        
        try {
            System.out.println("📞 STEP 3: Calling officerService.registerOfficer...");
            OfficerDTO createdOfficer = officerService.registerOfficer(request);
            System.out.println("✅ STEP 3: Officer created successfully with ID: " + createdOfficer.getId());
            return ResponseEntity.ok(createdOfficer);
        } catch (Exception e) {
            System.out.println("❌ STEP 3: Error in officerService.registerOfficer: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }

    /**
     * Get an officer by ID.
     *
     * @param officerId UUID of the officer
     * @return officer details
     */
    @GetMapping("/{officerId}")
    public ResponseEntity<OfficerDTO> getOfficerById(@PathVariable UUID officerId) {
        OfficerDTO officer = officerService.getOfficerById(officerId);
        return ResponseEntity.ok(officer);
    }

    /**
     * Get a list of all officers.
     *
     * @return list of officers
     */
    @GetMapping
    public ResponseEntity<?> getAllOfficers() {
        try {
            System.out.println("🔍 STEP CONTROLLER: Get all officers request received");
            List<OfficerDTO> officers = officerService.getAllOfficers();
            System.out.println("✅ STEP CONTROLLER: Retrieved " + officers.size() + " officers");
            return ResponseEntity.ok(officers);
        } catch (Exception e) {
            System.out.println("❌ STEP CONTROLLER: Error fetching officers: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("error", "Failed to fetch officers: " + e.getMessage()));
        }
    }

    /**
     * Update an existing officer.
     * Fields in the request are optional; only non-null values will be updated.
     *
     * @param officerId UUID of the officer to update
     * @param request   DTO with update fields
     * @return updated officer details
     */
    @PutMapping("/{officerId}")
    public ResponseEntity<?> updateOfficer(
            @PathVariable UUID officerId,
            @Valid @RequestBody UpdateOfficerRequest request) {
        try {
            System.out.println("🔍 STEP CONTROLLER: Update officer request received for ID: " + officerId);
            OfficerDTO updatedOfficer = officerService.updateOfficer(officerId, request);
            System.out.println("✅ STEP CONTROLLER: Officer updated successfully");
            return ResponseEntity.ok(updatedOfficer);
        } catch (IllegalArgumentException e) {
            System.out.println("❌ STEP CONTROLLER: Validation error: " + e.getMessage());
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (IllegalStateException e) {
            System.out.println("❌ STEP CONTROLLER: State error: " + e.getMessage());
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            System.out.println("❌ STEP CONTROLLER: Unexpected error: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("error", "Internal server error occurred while updating officer"));
        }
    }

    /**
     * Deactivate (soft-delete) an officer.
     *
     * @param officerId UUID of the officer to deactivate
     * @return 204 No Content on success
     */
    @DeleteMapping("/{officerId}")
    public ResponseEntity<Void> deactivateOfficer(@PathVariable UUID officerId) {
        officerService.deactivateOfficer(officerId);
        return ResponseEntity.noContent().build();
    }
}
