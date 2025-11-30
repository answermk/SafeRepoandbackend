package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.dto.user.*;
import com.crimeprevention.crime_backend.core.mapper.UserMapper;
import com.crimeprevention.crime_backend.core.model.user.User;
import com.crimeprevention.crime_backend.core.model.enums.UserRole;
import com.crimeprevention.crime_backend.core.repo.user.UserRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.UserService;
import com.crimeprevention.crime_backend.core.service.interfaces.EmailService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;
    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;

    @Override
    @Transactional
    public UserDTO createUserByAdmin(RegisterUserRequest request) {
        User user = User.builder()
            .fullName(request.getFullName())
            .email(request.getEmail())
            .phoneNumber(request.getPhoneNumber())
            .username(request.getUsername())
            .passwordHash(passwordEncoder.encode(request.getPassword()))
            .role(request.getRole())
            .enabled(true)  // Explicitly set to active
            .isActive(true)  // Explicitly set to active
            .build();
        user = userRepository.save(user);
        
        // Try to send welcome email, but don't fail if email service is down
        try {
            emailService.sendWelcomeEmail(user.getEmail(), user.getFullName());
        } catch (Exception e) {
            System.err.println("⚠️ Warning: Failed to send welcome email to " + user.getEmail() + ": " + e.getMessage());
            // Continue anyway - user was created successfully
        }
        
        return userMapper.toDto(user);
    }

    @Override
    @Transactional(readOnly = true)
    public UserDTO getUserById(UUID id) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("User not found"));
        return userMapper.toDto(user);
    }

    @Override
    @Transactional
    public UserDTO updateUser(UUID id, UpdateUserRequest request) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        System.out.println("🔄 Update User Request - User ID: " + id + ", Current isActive: " + user.isActive());
        System.out.println("🔄 Request isActive: " + request.getIsActive());
        
        // Update fields if provided
        if (request.getFullName() != null) {
            user.setFullName(request.getFullName());
        }
        if (request.getPhoneNumber() != null) {
            user.setPhoneNumber(request.getPhoneNumber());
        }
        if (request.getIsActive() != null) {
            System.out.println("🔄 Updating isActive from " + user.isActive() + " to " + request.getIsActive());
            user.setActive(request.getIsActive());
            user.setEnabled(request.getIsActive()); // Also update enabled field
        }
        if (request.getRole() != null) {
            user.setRole(request.getRole());
        }
        if (request.getEmail() != null) {
            user.setEmail(request.getEmail());
        }
        if (request.getUsername() != null) {
            user.setUsername(request.getUsername());
        }
        if (request.getPassword() != null && !request.getPassword().isEmpty()) {
            user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        }
        
        user = userRepository.save(user);
        System.out.println("✅ User saved - New isActive: " + user.isActive());
        
        // Try to send update email, but don't fail if email service is down
        try {
            emailService.sendAccountUpdateEmail(user.getEmail(), user.getFullName(), "profile");
        } catch (Exception e) {
            System.err.println("⚠️ Warning: Failed to send update email: " + e.getMessage());
        }
        
        return userMapper.toDto(user);
    }

    @Override
    @Transactional
    public UserDTO updateUserByEmail(String email, UpdateUserRequest request) {
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        // Update fields if provided
        if (request.getFullName() != null) {
            user.setFullName(request.getFullName());
        }
        if (request.getPhoneNumber() != null) {
            user.setPhoneNumber(request.getPhoneNumber());
        }
        if (request.getIsActive() != null) {
            user.setActive(request.getIsActive());
            user.setEnabled(request.getIsActive()); // Also update enabled field
        }
        if (request.getRole() != null) {
            user.setRole(request.getRole());
        }
        if (request.getUsername() != null) {
            user.setUsername(request.getUsername());
        }
        if (request.getPassword() != null && !request.getPassword().isEmpty()) {
            user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        }
        
        user = userRepository.save(user);
        
        // Try to send update email, but don't fail if email service is down
        try {
            emailService.sendAccountUpdateEmail(user.getEmail(), user.getFullName(), "profile");
        } catch (Exception e) {
            System.err.println("⚠️ Warning: Failed to send update email: " + e.getMessage());
        }
        
        return userMapper.toDto(user);
    }

    @Override
    @Transactional
    public void deactivateUser(UUID id) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("User not found"));
        user.setActive(false);
        userRepository.save(user);
        emailService.sendAccountUpdateEmail(user.getEmail(), user.getFullName(), "deactivation");
    }

    @Override
    @Transactional
    public void deactivateUserByEmail(String email) {
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("User not found"));
        user.setActive(false);
        userRepository.save(user);
        emailService.sendAccountUpdateEmail(user.getEmail(), user.getFullName(), "deactivation");
    }

    @Override
    @Transactional(readOnly = true)
    public List<UserDTO> getAllUsers() {
        List<User> users = userRepository.findAll();
        return userMapper.toDtoList(users);
    }

    @Override
    @Transactional
    public UserDTO registerCivilian(SignupRequest request) {
        User user = User.builder()
            .fullName(request.getFullName())
            .email(request.getEmail())
            .phoneNumber(request.getPhoneNumber())
            .username(request.getUsername())
            .passwordHash(passwordEncoder.encode(request.getPassword()))
            .role(UserRole.CIVILIAN)
            .build();
        user = userRepository.save(user);
        emailService.sendWelcomeEmail(user.getEmail(), user.getFullName());
        return userMapper.toDto(user);
    }

    @Override
    @Transactional(readOnly = true)
    public UserStatsDTO getUserStats() {
        long totalUsers = userRepository.count();
        long activeUsers = userRepository.countByIsActiveTrue();
        long inactiveUsers = totalUsers - activeUsers;
        long civilianUsers = userRepository.countByRole(UserRole.CIVILIAN);
        long officerUsers = userRepository.countByRole(UserRole.OFFICER);
        long adminUsers = userRepository.countByRole(UserRole.ADMIN);

        return UserStatsDTO.builder()
            .totalUsers(totalUsers)
            .activeUsers(activeUsers)
            .inactiveUsers(inactiveUsers)
            .civilianUsers(civilianUsers)
            .officerUsers(officerUsers)
            .adminUsers(adminUsers)
            .build();
    }
    
    @Override
    @Transactional
    public void changePassword(UUID userId, ChangePasswordRequest request) {
        log.info("Changing password for user {}", userId);
        
        // Validate new password and confirmation match
        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            throw new IllegalArgumentException("New password and confirmation do not match");
        }
        
        // Validate new password is different from current password
        if (request.getCurrentPassword().equals(request.getNewPassword())) {
            throw new IllegalArgumentException("New password must be different from current password");
        }
        
        // Get user
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found with ID: " + userId));
        
        // Verify current password
        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPasswordHash())) {
            throw new IllegalArgumentException("Current password is incorrect");
        }
        
        // Validate password strength (minimum 8 characters)
        if (request.getNewPassword().length() < 8) {
            throw new IllegalArgumentException("New password must be at least 8 characters long");
        }
        
        // Update password
        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
        
        log.info("Password changed successfully for user {}", userId);
        
        // Try to send password change notification email
        try {
            emailService.sendPasswordChangeEmail(user.getEmail(), user.getFullName());
        } catch (Exception e) {
            log.warn("Failed to send password change email: {}", e.getMessage());
            // Continue anyway - password was changed successfully
        }
    }
}