package com.crimeprevention.crime_backend.core.dto.user;

import com.crimeprevention.crime_backend.core.model.enums.DutyStatus;
import com.crimeprevention.crime_backend.core.model.enums.OfficerRoleType;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * DTO for updating an officer’s information.
 */
@Data
public class UpdateOfficerRequest {

    @Size(min = 3, max = 100, message = "Full name must be between 3 and 100 characters")
    private String fullName;

    @Size(min = 10, max = 15, message = "Phone number must be between 10 and 15 characters")
    private String phoneNumber;

    private String email;

    private OfficerRoleType officerRoleType;

    private DutyStatus dutyStatus;

    private Boolean backupRequested;
}
