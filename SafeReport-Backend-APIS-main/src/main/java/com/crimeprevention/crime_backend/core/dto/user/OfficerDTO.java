package com.crimeprevention.crime_backend.core.dto.user;

import com.crimeprevention.crime_backend.core.model.enums.DutyStatus;
import com.crimeprevention.crime_backend.core.model.enums.OfficerRoleType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OfficerDTO {
    private UUID id;
    private String officerId;
    private String fullName;
    private String email;
    private String phoneNumber;
    private OfficerRoleType officerRoleType;
    private DutyStatus dutyStatus;
    private boolean backupRequested;
}