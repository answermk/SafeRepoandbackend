package com.crimeprevention.crime_backend.core.dto.officer;

import com.crimeprevention.crime_backend.core.model.enums.DutyStatus;
import com.crimeprevention.crime_backend.core.model.enums.OfficerRoleType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateOfficerRequest {
    private String fullName;
    private String phoneNumber;
    private OfficerRoleType officerRoleType;
    private DutyStatus dutyStatus;
}
