package com.crimeprevention.crime_backend.core.service.interfaces;

import java.util.UUID;

public interface PasswordResetService {
    
    /**
     * Request password reset for a user
     * @param email User's email address
     * @return true if reset email was sent, false otherwise
     */
    boolean requestPasswordReset(String email);
    
    /**
     * Reset password using email and code
     * @param email User's email
     * @param code 6-digit verification code
     * @param newPassword New password
     * @return true if password was reset successfully, false otherwise
     */
    boolean resetPassword(String email, String code, String newPassword);
    
    /**
     * Reset password using reset token (legacy)
     * @param token Reset token from email
     * @param newPassword New password
     * @return true if password was reset successfully, false otherwise
     */
    boolean resetPasswordWithToken(String token, String newPassword);
    
    /**
     * Validate reset token
     * @param token Reset token to validate
     * @return true if token is valid, false otherwise
     */
    boolean validateResetToken(String token);
    
    /**
     * Verify 6-digit code
     * @param email User's email
     * @param code 6-digit verification code
     * @return true if code is valid, false otherwise
     */
    boolean verifyCode(String email, String code);
    
    /**
     * Get user ID from reset token
     * @param token Reset token
     * @return User ID if token is valid, null otherwise
     */
    UUID getUserIdFromToken(String token);
    
    /**
     * Get user ID from email (after code verification)
     * @param email User's email
     * @return User ID if code was verified, null otherwise
     */
    UUID getUserIdFromEmail(String email);
    
    /**
     * Clean up expired tokens
     */
    void cleanupExpiredTokens();
} 