package com.crimeprevention.crime_backend.core.dto.user;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for admin contact information
 * Used for displaying support contact details in the app
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AdminContactInfoDTO {
    private String email;
    private String phoneNumber;
    private String fullName;
}

