package com.crimeprevention.crime_backend.core.dto.user;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class ChangePasswordRequest {
    
    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;
    
    @NotBlank(message = "Code is required")
    @Pattern(regexp = "\\d{6}", message = "Code must be 6 digits")
    private String code;
    
    @NotBlank(message = "New password is required")
    @Size(min = 6, message = "Password must be at least 6 characters long")
    private String newPassword;
    
    @NotBlank(message = "Confirm password is required")
    private String confirmPassword;
}
