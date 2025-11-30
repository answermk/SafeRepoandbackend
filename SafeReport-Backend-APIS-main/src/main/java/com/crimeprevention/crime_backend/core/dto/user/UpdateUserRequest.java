package com.crimeprevention.crime_backend.core.dto.user;

import com.crimeprevention.crime_backend.core.model.enums.UserRole;
import lombok.Data;

/**
 * DTO for updating user profile information.
 */
@Data
public class UpdateUserRequest {
    private String fullName;
    private String email;
    private String username;
    private String phoneNumber;
    private String password;
    private UserRole role;
    private Boolean isActive;  // Added to support block/unblock functionality
}
