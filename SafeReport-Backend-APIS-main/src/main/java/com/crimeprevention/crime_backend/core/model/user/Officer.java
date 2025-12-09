package com.crimeprevention.crime_backend.core.model.user;

import com.crimeprevention.crime_backend.core.model.enums.DutyStatus;
import com.crimeprevention.crime_backend.core.model.enums.OfficerRoleType;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

@Entity
@DiscriminatorValue("Officer")
@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = false)
public class Officer extends User {

    @Column(name = "officer_id", unique = true, length = 15)
    private String officerId;

    @Column(name = "badge_number", unique = true)
    private String badgeNumber;

    @Enumerated(EnumType.STRING)
    @Column(name = "officer_role_type")
    private OfficerRoleType officerRoleType;

    @Enumerated(EnumType.STRING)
    @Column(name = "duty_status")
    @Builder.Default
    private DutyStatus dutyStatus = DutyStatus.OFF_DUTY;

    @Column(name = "backup_requested")
    @Builder.Default
    private boolean backupRequested = false;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "latitude", column = @Column(name = "latitude", nullable = true)),
        @AttributeOverride(name = "longitude", column = @Column(name = "longitude", nullable = true))
    })
    private Location location;

    @Embeddable
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Location {
        private Double latitude;
        private Double longitude;
    }
}
