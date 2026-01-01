package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.dto.user.*;
import com.crimeprevention.crime_backend.core.mapper.UserMapper;
import com.crimeprevention.crime_backend.core.model.user.User;
import com.crimeprevention.crime_backend.core.model.enums.UserRole;
import com.crimeprevention.crime_backend.core.model.enums.ReportStatus;
import com.crimeprevention.crime_backend.core.repo.user.UserRepository;
import com.crimeprevention.crime_backend.core.repo.report.ReportRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.UserService;
import com.crimeprevention.crime_backend.core.service.interfaces.EmailService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;
    private final ReportRepository reportRepository;
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
            user.setPasswordChangedAt(java.time.Instant.now());
        }
        if (request.getAnonymousMode() != null) {
            user.setAnonymousMode(request.getAnonymousMode());
        }
        if (request.getLocationSharing() != null) {
            user.setLocationSharing(request.getLocationSharing());
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
            user.setPasswordChangedAt(java.time.Instant.now());
        }
        if (request.getAnonymousMode() != null) {
            user.setAnonymousMode(request.getAnonymousMode());
        }
        if (request.getLocationSharing() != null) {
            user.setLocationSharing(request.getLocationSharing());
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
    @Transactional(readOnly = true)
    public AdminContactInfoDTO getAdminContactInfo() {
        // Get the first active admin user
        List<User> admins = userRepository.findByRole(UserRole.ADMIN);
        
        if (admins.isEmpty()) {
            // Return default contact info if no admin found
            return AdminContactInfoDTO.builder()
                .email("support@saferreport.com")
                .phoneNumber("18007233776")
                .fullName("System Admin")
                .build();
        }
        
        // Get the first active admin, or first admin if none are active
        User admin = admins.stream()
            .filter(User::isActive)
            .findFirst()
            .orElse(admins.get(0));
        
        return AdminContactInfoDTO.builder()
            .email(admin.getEmail())
            .phoneNumber(admin.getPhoneNumber())
            .fullName(admin.getFullName())
            .build();
    }

    @Override
    @Transactional
    public UserDTO registerCivilian(SignupRequest request) {
        // Check if email already exists
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email already registered. Please use a different email or sign in.");
        }
        
        // Check if username already exists (if provided)
        if (request.getUsername() != null && !request.getUsername().trim().isEmpty()) {
            if (userRepository.existsByUsername(request.getUsername())) {
                throw new IllegalArgumentException("Username already taken. Please choose a different username.");
            }
        }
        
        // Auto-generate username from email if not provided
        String finalUsername = request.getUsername();
        if (finalUsername == null || finalUsername.trim().isEmpty()) {
            finalUsername = request.getEmail().split("@")[0]; // Use part before @
            // Ensure username is unique
            String baseUsername = finalUsername;
            int counter = 1;
            while (userRepository.existsByUsername(finalUsername)) {
                finalUsername = baseUsername + counter;
                counter++;
            }
        }
        
        User user = User.builder()
            .fullName(request.getFullName())
            .email(request.getEmail())
            .phoneNumber(request.getPhoneNumber())
            .username(finalUsername)
            .passwordHash(passwordEncoder.encode(request.getPassword()))
            .role(UserRole.CIVILIAN)
            .enabled(true)
            .isActive(true)
            .build();
        user = userRepository.save(user);
        
        // Try to send welcome email, but don't fail if email service is down
        try {
            emailService.sendWelcomeEmail(user.getEmail(), user.getFullName());
        } catch (Exception e) {
            log.warn("⚠️ Warning: Failed to send welcome email to {}: {}. User registration continues.", 
                    user.getEmail(), e.getMessage());
            // Continue anyway - user was created successfully
        }
        
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
    public void changePassword(UUID userId, UpdatePasswordRequest request) {
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
        
        // Check if password was changed within last 30 days (except for password reset flow)
        if (user.getPasswordChangedAt() != null) {
            java.time.Instant thirtyDaysAgo = java.time.Instant.now().minusSeconds(30L * 24 * 60 * 60);
            if (user.getPasswordChangedAt().isAfter(thirtyDaysAgo)) {
                long daysSinceChange = java.time.Duration.between(user.getPasswordChangedAt(), java.time.Instant.now()).toDays();
                throw new IllegalArgumentException(
                    String.format("Password can only be changed once every 30 days. Last changed %d days ago. Please wait %d more days.",
                        daysSinceChange, 30 - daysSinceChange)
                );
            }
        }
        
        // Update password and set change timestamp
        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        user.setPasswordChangedAt(java.time.Instant.now());
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
    
    @Override
    @Transactional(readOnly = true)
    public UserImpactDTO getUserImpact(UUID userId) {
        log.info("Calculating user impact for user {}", userId);
        
        // Verify user exists
        userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found with ID: " + userId));
        
        // Count reports by status
        long totalReports = reportRepository.countByReporterId(userId);
        long resolvedReports = reportRepository.countByReporterIdAndStatus(userId, ReportStatus.RESOLVED);
        long closedReports = reportRepository.countByReporterIdAndStatus(userId, ReportStatus.CLOSED);
        long inProgressReports = reportRepository.countByReporterIdAndStatus(userId, ReportStatus.IN_PROGRESS);
        long underInvestigationReports = reportRepository.countByReporterIdAndStatus(userId, ReportStatus.UNDER_INVESTIGATION);
        long pendingReports = reportRepository.countByReporterIdAndStatus(userId, ReportStatus.PENDING);
        
        // Calculate metrics
        int reportsSubmitted = (int) totalReports;
        int actionsTaken = (int) (resolvedReports + closedReports + inProgressReports + underInvestigationReports);
        int crimesPrevented = (int) (resolvedReports + closedReports);
        
        // Calculate reputation points based on performance
        // Points system: 10 points per report, 20 points per resolved, 15 points per in-progress
        int reputationPoints = (int) (
            totalReports * 10 +
            (resolvedReports + closedReports) * 20 +
            (inProgressReports + underInvestigationReports) * 15
        );
        
        // Determine reputation level
        String reputationLevel = mapPointsToLevel(reputationPoints);
        
        // Calculate progress to next level
        int[] levelThresholds = {0, 400, 700, 1000}; // Bronze, Silver, Gold, Platinum
        int currentLevelIndex = getLevelIndex(reputationPoints);
        int nextLevelThreshold = currentLevelIndex < levelThresholds.length - 1 
            ? levelThresholds[currentLevelIndex + 1] 
            : levelThresholds[levelThresholds.length - 1];
        int pointsToNextLevel = Math.max(0, nextLevelThreshold - reputationPoints);
        double progressToNextLevel = currentLevelIndex < levelThresholds.length - 1
            ? (double)(reputationPoints - levelThresholds[currentLevelIndex]) / 
              (nextLevelThreshold - levelThresholds[currentLevelIndex])
            : 1.0;
        
        // Get recent activity timeline (last 20 reports)
        List<com.crimeprevention.crime_backend.core.model.report.Report> recentReports = 
            reportRepository.findRecentByReporterId(userId, PageRequest.of(0, 20));
        
        List<UserImpactDTO.ActivityItem> recentActivity = recentReports.stream()
            .map(report -> {
                String action = "Report " + report.getStatus().toString().toLowerCase();
                String detail = report.getTitle() != null ? report.getTitle() : "Untitled Report";
                LocalDateTime timestamp = report.getCreatedAt() != null 
                    ? LocalDateTime.ofInstant(report.getCreatedAt(), ZoneId.systemDefault())
                    : LocalDateTime.now();
                String time = formatTimeAgo(timestamp);
                
                return UserImpactDTO.ActivityItem.builder()
                    .action(action)
                    .detail(detail)
                    .time(time)
                    .timestamp(timestamp)
                    .build();
            })
            .collect(Collectors.toList());
        
        // Build badges based on achievements
        List<UserImpactDTO.BadgeInfo> badges = new ArrayList<>();
        badges.add(UserImpactDTO.BadgeInfo.builder()
            .name("First Report")
            .icon("flag")
            .color("#2196F3")
            .earned(totalReports > 0)
            .description("Submit your first report")
            .build());
        badges.add(UserImpactDTO.BadgeInfo.builder()
            .name("Active Reporter")
            .icon("calendar_today")
            .color("#4CAF50")
            .earned(totalReports >= 5)
            .description("Submit 5 or more reports")
            .build());
        badges.add(UserImpactDTO.BadgeInfo.builder()
            .name("Resolution Star")
            .icon("check_circle")
            .color("#009688")
            .earned(crimesPrevented >= 3)
            .description("Have 3 or more reports resolved")
            .build());
        badges.add(UserImpactDTO.BadgeInfo.builder()
            .name("Community Hero")
            .icon("star")
            .color("#FF9800")
            .earned(crimesPrevented >= 5)
            .description("Have 5 or more reports resolved")
            .build());
        
        return UserImpactDTO.builder()
            .reportsSubmitted(reportsSubmitted)
            .actionsTaken(actionsTaken)
            .crimesPrevented(crimesPrevented)
            .reputationPoints(reputationPoints)
            .reputationLevel(reputationLevel)
            .pointsToNextLevel(pointsToNextLevel)
            .progressToNextLevel(progressToNextLevel)
            .totalReports(totalReports)
            .resolvedReports(resolvedReports)
            .inProgressReports(inProgressReports)
            .pendingReports(pendingReports)
            .closedReports(closedReports)
            .recentActivity(recentActivity)
            .badges(badges)
            .build();
    }
    
    private String mapPointsToLevel(int points) {
        if (points >= 1000) return "Platinum";
        if (points >= 700) return "Gold";
        if (points >= 400) return "Silver";
        return "Bronze";
    }
    
    private int getLevelIndex(int points) {
        if (points >= 1000) return 3;
        if (points >= 700) return 2;
        if (points >= 400) return 1;
        return 0;
    }
    
    private String formatTimeAgo(LocalDateTime timestamp) {
        LocalDateTime now = LocalDateTime.now();
        long minutes = ChronoUnit.MINUTES.between(timestamp, now);
        long hours = ChronoUnit.HOURS.between(timestamp, now);
        long days = ChronoUnit.DAYS.between(timestamp, now);
        
        if (minutes < 1) return "Just now";
        if (minutes < 60) return minutes + "m ago";
        if (hours < 24) return hours + "h ago";
        if (days < 7) return days + "d ago";
        long weeks = days / 7;
        if (weeks < 5) return weeks + "w ago";
        long months = days / 30;
        return months + "mo ago";
    }
}