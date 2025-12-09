package com.crimeprevention.crime_backend.core.repo.user;

import com.crimeprevention.crime_backend.core.model.user.PasswordResetToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, UUID> {

    Optional<PasswordResetToken> findByToken(String token);
    
    Optional<PasswordResetToken> findByCode(String code);
    
    Optional<PasswordResetToken> findByUserId(UUID userId);
    
    @Query("SELECT p FROM PasswordResetToken p WHERE p.user.email = :email")
    Optional<PasswordResetToken> findByUserEmail(@Param("email") String email);
    
    @Modifying
    @Query("DELETE FROM PasswordResetToken p WHERE p.expiryDate < :now")
    void deleteExpiredTokens(@Param("now") Instant now);
    
    @Modifying
    @Query("DELETE FROM PasswordResetToken p WHERE p.user.id = :userId")
    void deleteByUserId(@Param("userId") UUID userId);
} 