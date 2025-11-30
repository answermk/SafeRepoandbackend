package com.crimeprevention.crime_backend.core.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.UUID;

import io.jsonwebtoken.security.Keys;

@Component
public class JwtTokenProvider {

	@Value("${jwt.secret}")
	private String jwtSecret;

	@Value("${jwt.expiration-ms}")
	private long jwtExpirationMs;

	private SecretKey signingKey() {
		return Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));
	}

	// Generate JWT token with subject = userId and role information
	public String generateToken(UUID userId, String role) {
		Date now = new Date();

		return Jwts.builder()
				.setSubject(userId.toString())
				.claim("role", role)
				.claim("authorities", "ROLE_" + role)
				.setIssuedAt(now)
				.setExpiration(new Date(now.getTime() + jwtExpirationMs))
				.signWith(signingKey())
				.compact();
	}
	
	// Generate JWT token with subject = userId (backward compatibility)
	public String generateToken(UUID userId) {
		return generateToken(userId, "USER");
	}

	// Get userId from JWT
	public UUID getUserIdFromJWT(String token) {
		Claims claims = Jwts.parserBuilder()
				.setSigningKey(signingKey())
				.build()
				.parseClaimsJws(token)
				.getBody();

		return UUID.fromString(claims.getSubject());
	}
	
	// Get role from JWT
	public String getRoleFromJWT(String token) {
		Claims claims = Jwts.parserBuilder()
				.setSigningKey(signingKey())
				.build()
				.parseClaimsJws(token)
				.getBody();

		return claims.get("role", String.class);
	}

	// Validate JWT token
	public boolean validateToken(String token) {
		try {
			System.out.println("🔍 JWT Validation - Token: " + token.substring(0, Math.min(token.length(), 30)) + "...");
			System.out.println("🔍 JWT Validation - Secret length: " + jwtSecret.length());
			System.out.println("🔍 JWT Validation - Secret preview: " + jwtSecret.substring(0, 10) + "...");
			
			Jwts.parserBuilder().setSigningKey(signingKey()).build().parseClaimsJws(token);
			System.out.println("✅ JWT Validation - Token is valid");
			return true;
		} catch (Exception ex) {
			System.out.println("❌ JWT Validation - Token is invalid: " + ex.getMessage());
			System.out.println("❌ JWT Validation - Exception type: " + ex.getClass().getSimpleName());
			ex.printStackTrace();
			return false;
		}
	}
}
