package com.crimeprevention.crime_backend.core.dto.user;

import com.crimeprevention.crime_backend.core.model.enums.UserRole;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserDTO {
    private UUID id;
    private String fullName;
    private String email;
    private String phoneNumber;
    private String username;
    private UserRole role;
    private boolean enabled;
    private boolean isActive;
    private boolean anonymousMode;
    private boolean locationSharing;
    private Instant passwordChangedAt;
    private Instant createdAt;
    private Instant updatedAt;
}