package com.crimeprevention.crime_backend.core.model.user;

import com.crimeprevention.crime_backend.core.model.base.AbstractAuditEntity;
import com.crimeprevention.crime_backend.core.model.enums.UserRole;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

@Entity
@Table(name = "users")
@Inheritance(strategy = InheritanceType.SINGLE_TABLE)
@DiscriminatorColumn(name = "dtype", discriminatorType = DiscriminatorType.STRING)
@DiscriminatorValue("User")
@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = false)
public class User extends AbstractAuditEntity {
    @Column(name = "full_name")
    private String fullName;

    @Column(name = "email", unique = true)
    private String email;

    @Column(name = "phone_number")
    private String phoneNumber;

    @Column(name = "username", unique = true)
    private String username;

    @Column(name = "password_hash")
    private String passwordHash;

    @Enumerated(EnumType.STRING)
    @Column(name = "role")
    private UserRole role;

    @Column(name = "enabled")
    @Builder.Default
    private boolean enabled = true;

    @Column(name = "is_active")
    @Builder.Default
    private boolean isActive = true;

    @Column(name = "anonymous_mode")
    @Builder.Default
    private Boolean anonymousMode = false;

    @Column(name = "location_sharing")
    @Builder.Default
    private Boolean locationSharing = true; // Always on by default

    @Column(name = "password_changed_at")
    private java.time.Instant passwordChangedAt;

    // Password encoding should be handled at service layer
    public void encodePassword(String rawPassword) {
        this.passwordHash = new BCryptPasswordEncoder().encode(rawPassword);
    }
}