package com.crimeprevention.crime_backend.core.dto.user;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * DTO for changing user password.
 */
@Data
public class ChangePasswordRequest {
    
    @NotBlank(message = "Current password is required")
    private String currentPassword;
    
    @NotBlank(message = "New password is required")
    private String newPassword;
    
    @NotBlank(message = "Password confirmation is required")
    private String confirmPassword;
}

