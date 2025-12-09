package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.model.user.PasswordResetToken;
import com.crimeprevention.crime_backend.core.model.user.User;
import com.crimeprevention.crime_backend.core.repo.user.PasswordResetTokenRepository;
import com.crimeprevention.crime_backend.core.repo.user.UserRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.EmailService;
import com.crimeprevention.crime_backend.core.service.interfaces.PasswordResetService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Optional;
import java.util.Random;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class PasswordResetServiceImpl implements PasswordResetService {
    
    private final UserRepository userRepository;
    private final PasswordResetTokenRepository tokenRepository;
    private final EmailService emailService;
    private final PasswordEncoder passwordEncoder;
    private final Random random = new Random();
    
    private static final int CODE_EXPIRY_MINUTES = 15;
    
    /**
     * Generate a 6-digit code
     */
    private String generateCode() {
        return String.format("%06d", random.nextInt(1000000));
    }
    
    @Override
    @Transactional
    public boolean requestPasswordReset(String email) {
        try {
            Optional<User> userOpt = userRepository.findByEmail(email);
            if (userOpt.isEmpty()) {
                log.warn("Password reset requested for non-existent email: {}", email);
                // Don't reveal if email exists or not for security
                return true; // Return true to prevent email enumeration
            }
            
            User user = userOpt.get();
            
            // Delete any existing reset tokens for this user
            tokenRepository.findByUserEmail(email).ifPresent(tokenRepository::delete);
            
            // Generate 6-digit code
            String code = generateCode();
            String token = UUID.randomUUID().toString(); // Keep token for backward compatibility
            
            // Create reset token with code
            Instant expiryDate = Instant.now().plusSeconds(CODE_EXPIRY_MINUTES * 60);
            PasswordResetToken resetToken = PasswordResetToken.builder()
                    .token(token)
                    .code(code)
                    .user(user)
                    .expiryDate(expiryDate)
                    .used(false)
                    .build();
            
            tokenRepository.save(resetToken);
            
            // Send email with code
            try {
                emailService.sendPasswordResetCode(user.getEmail(), code, user.getFullName());
                log.info("Password reset code sent to {}", email);
            } catch (Exception e) {
                log.error("Failed to send password reset code to {}: {}", email, e.getMessage());
                // For development: log the code so developers can test even without email configured
                if (e.getMessage() != null && e.getMessage().contains("Email service is not configured")) {
                    log.info("🔑 DEVELOPMENT MODE: Password reset code for {} is: {} (Email service disabled)", email, code);
                    log.warn("⚠️ Token saved but email not sent. Check logs above for the code to test password reset.");
                    // Keep the token for development testing - don't delete it
                    // In production, you should delete the token if email fails
                    // tokenRepository.delete(resetToken);
                } else {
                    // For other errors, delete the token
                    tokenRepository.delete(resetToken);
                }
                return false;
            }
            
            return true;
        } catch (Exception e) {
            log.error("Error requesting password reset for {}: {}", email, e.getMessage());
            return false;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public boolean verifyCode(String email, String code) {
        try {
            Optional<PasswordResetToken> tokenOpt = tokenRepository.findByUserEmail(email);
            if (tokenOpt.isEmpty()) {
                log.warn("No reset token found for email: {}", email);
                return false;
            }
            
            PasswordResetToken token = tokenOpt.get();
            
            // Check if code matches
            if (!token.getCode().equals(code)) {
                log.warn("Invalid code for email: {}", email);
                return false;
            }
            
            // Check if token is expired
            if (token.getExpiryDate().isBefore(Instant.now())) {
                log.warn("Expired code for email: {}", email);
                return false;
            }
            
            // Check if already used
            if (token.isUsed()) {
                log.warn("Code already used for email: {}", email);
                return false;
            }
            
            return true;
        } catch (Exception e) {
            log.error("Error verifying code for {}: {}", email, e.getMessage());
            return false;
        }
    }
    
    @Override
    @Transactional
    public boolean resetPassword(String email, String code, String newPassword) {
        try {
            Optional<PasswordResetToken> tokenOpt = tokenRepository.findByUserEmail(email);
            if (tokenOpt.isEmpty()) {
                log.warn("No reset token found for email: {}", email);
                return false;
            }
            
            PasswordResetToken token = tokenOpt.get();
            
            // Verify code
            if (!verifyCode(email, code)) {
                return false;
            }
            
            // Get user
            Optional<User> userOpt = userRepository.findByEmail(email);
            if (userOpt.isEmpty()) {
                log.warn("User not found for email: {}", email);
                return false;
            }
            
            User user = userOpt.get();
            
            // Update password and set change timestamp (reset flow bypasses 30-day rule)
            user.setPasswordHash(passwordEncoder.encode(newPassword));
            user.setPasswordChangedAt(Instant.now());
            userRepository.save(user);
            
            // Mark token as used
            token.setUsed(true);
            token.setUsedAt(Instant.now());
            tokenRepository.save(token);
            
            // Send confirmation email
            try {
                emailService.sendPasswordChangeEmail(user.getEmail(), user.getFullName());
            } catch (Exception e) {
                log.warn("Failed to send password change confirmation email: {}", e.getMessage());
                // Don't fail the reset if email fails
            }
            
            log.info("Password reset successful for email: {}", email);
            return true;
        } catch (Exception e) {
            log.error("Error resetting password for {}: {}", email, e.getMessage());
            return false;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public UUID getUserIdFromEmail(String email) {
        Optional<PasswordResetToken> tokenOpt = tokenRepository.findByUserEmail(email);
        if (tokenOpt.isPresent() && !tokenOpt.get().isUsed() && 
            tokenOpt.get().getExpiryDate().isAfter(Instant.now())) {
            return tokenOpt.get().getUser().getId();
        }
        return null;
    }
    
    @Override
    @Scheduled(cron = "0 0 * * * *") // Run every hour
    @Transactional
    public void cleanupExpiredTokens() {
        log.info("Cleaning up expired password reset tokens at {}", Instant.now());
        tokenRepository.deleteExpiredTokens(Instant.now());
    }

    @Override
    @Transactional(readOnly = true)
    public UUID getUserIdFromToken(String token) {
        Optional<PasswordResetToken> tokenOpt = tokenRepository.findByToken(token);
        if (tokenOpt.isPresent() && !tokenOpt.get().isUsed() && 
            tokenOpt.get().getExpiryDate().isAfter(Instant.now())) {
            return tokenOpt.get().getUser().getId();
        }
        return null;
    }

    @Override
    @Transactional(readOnly = true)
    public boolean validateResetToken(String token) {
        Optional<PasswordResetToken> tokenOpt = tokenRepository.findByToken(token);
        if (tokenOpt.isEmpty()) {
            return false;
        }
        PasswordResetToken resetToken = tokenOpt.get();
        return !resetToken.isUsed() && resetToken.getExpiryDate().isAfter(Instant.now());
    }
    
    @Override
    @Transactional
    public boolean resetPasswordWithToken(String token, String newPassword) {
        Optional<PasswordResetToken> tokenOpt = tokenRepository.findByToken(token);
        if (tokenOpt.isEmpty()) {
            return false;
        }
        
        PasswordResetToken resetToken = tokenOpt.get();
        if (resetToken.isUsed() || resetToken.getExpiryDate().isBefore(Instant.now())) {
            return false;
        }
        
        User user = resetToken.getUser();
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        user.setPasswordChangedAt(Instant.now());
        userRepository.save(user);
        
        resetToken.setUsed(true);
        resetToken.setUsedAt(Instant.now());
        tokenRepository.save(resetToken);
        
        try {
            emailService.sendPasswordChangeEmail(user.getEmail(), user.getFullName());
        } catch (Exception e) {
            log.warn("Failed to send password change confirmation email: {}", e.getMessage());
        }
        
        return true;
    }
}