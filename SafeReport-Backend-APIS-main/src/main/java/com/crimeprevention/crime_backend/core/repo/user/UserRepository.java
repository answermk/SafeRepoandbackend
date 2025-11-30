package com.crimeprevention.crime_backend.core.repo.user;

import com.crimeprevention.crime_backend.core.model.enums.UserRole;
import com.crimeprevention.crime_backend.core.model.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID> {

    Optional<User> findByEmail(String email);
    
    Optional<User> findByUsername(String username);
    
    List<User> findByRole(UserRole role);
    
    List<User> findByRoleIn(List<UserRole> roles);
    
    boolean existsByEmail(String email);

    Optional<User> findByPhoneNumber(String phoneNumber);

    boolean existsByPhoneNumber(String phoneNumber);

    // Find active users
    List<User> findByIsActiveTrue();
    
    // Count methods for stats
    long countByIsActiveTrue();
    long countByRole(UserRole role);

}
