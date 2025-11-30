package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.dto.user.AuthResponse;
import com.crimeprevention.crime_backend.core.dto.user.ForgotPasswordRequest;
import com.crimeprevention.crime_backend.core.dto.user.LoginRequest;
import com.crimeprevention.crime_backend.core.dto.user.ResetPasswordRequest;
import com.crimeprevention.crime_backend.core.dto.user.SignupRequest;
import com.crimeprevention.crime_backend.core.model.user.User;
import com.crimeprevention.crime_backend.core.repo.user.UserRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.PasswordResetService;
import com.crimeprevention.crime_backend.core.service.interfaces.UserService;
import com.crimeprevention.crime_backend.core.util.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "http://localhost:5173")
@RequiredArgsConstructor
public class AuthController {

	private final AuthenticationManager authenticationManager;
	private final JwtTokenProvider jwtTokenProvider;
	private final UserRepository userRepository;
	private final UserService userService;
	private final PasswordResetService passwordResetService;

	// Login endpoint: authenticates and returns JWT + email
	@PostMapping("/login")
	public ResponseEntity<AuthResponse> login(@RequestBody LoginRequest loginRequest) {
		try {
			System.out.println("🔐 Login attempt for email: " + loginRequest.getEmail());
			
			// Check if user exists first
			User user = userRepository.findByEmail(loginRequest.getEmail()).orElse(null);
			if (user == null) {
				System.out.println("❌ User not found with email: " + loginRequest.getEmail());
				return ResponseEntity.status(401).body(null);
			}
			
			System.out.println("✅ User found: " + user.getEmail() + ", Role: " + user.getRole() + ", Enabled: " + user.isEnabled());
			
			if (!user.isEnabled()) {
				System.out.println("❌ User account is disabled");
				return ResponseEntity.status(401).body(null);
			}
			
			Authentication authentication = authenticationManager.authenticate(
					new UsernamePasswordAuthenticationToken(loginRequest.getEmail(), loginRequest.getPassword())
			);
			SecurityContextHolder.getContext().setAuthentication(authentication);

			String token = jwtTokenProvider.generateToken(user.getId(), user.getRole().name());
			System.out.println("✅ Login successful for: " + user.getEmail());

			return ResponseEntity.ok(new AuthResponse(token, user.getEmail(), user.getUsername()));
		} catch (BadCredentialsException ex) {
			System.out.println("❌ Bad credentials for email: " + loginRequest.getEmail() + " - " + ex.getMessage());
			return ResponseEntity.status(401).body(null);
		} catch (Exception ex) {
			System.out.println("❌ Login error: " + ex.getClass().getSimpleName() + " - " + ex.getMessage());
			ex.printStackTrace();
			return ResponseEntity.status(401).body(null);
		}
	}

	// Register civilian user endpoint
	@PostMapping("/register")
	public ResponseEntity<String> register(@RequestBody SignupRequest signupRequest) {
		try {
			userService.registerCivilian(signupRequest);
			return ResponseEntity.ok("User registered successfully");
		} catch (IllegalArgumentException e) {
			return ResponseEntity.badRequest().body(e.getMessage());
		}
	}

	// Forgot password endpoint
	@PostMapping("/forgot-password")
	public ResponseEntity<String> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
		try {
			boolean success = passwordResetService.requestPasswordReset(request.getEmail());
			if (success) {
				return ResponseEntity.ok("Password reset instructions sent to your email");
			} else {
				return ResponseEntity.badRequest().body("Failed to send password reset email");
			}
		} catch (Exception e) {
			return ResponseEntity.badRequest().body("Error processing request: " + e.getMessage());
		}
	}

	// Reset password endpoint
	@PostMapping("/reset-password")
	public ResponseEntity<String> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
		try {
			// Validate passwords match
			if (!request.getNewPassword().equals(request.getConfirmPassword())) {
				return ResponseEntity.badRequest().body("Passwords do not match");
			}

			// Validate token
			if (!passwordResetService.validateResetToken(request.getToken())) {
				return ResponseEntity.badRequest().body("Invalid or expired reset token");
			}

			// Reset password
			boolean success = passwordResetService.resetPassword(request.getToken(), request.getNewPassword());
			if (success) {
				return ResponseEntity.ok("Password reset successfully");
			} else {
				return ResponseEntity.badRequest().body("Failed to reset password");
			}
		} catch (Exception e) {
			return ResponseEntity.badRequest().body("Error processing request: " + e.getMessage());
		}
	}

	// Validate reset token endpoint
	@GetMapping("/validate-reset-token/{token}")
	public ResponseEntity<String> validateResetToken(@PathVariable String token) {
		try {
			boolean isValid = passwordResetService.validateResetToken(token);
			if (isValid) {
				return ResponseEntity.ok("Token is valid");
			} else {
				return ResponseEntity.badRequest().body("Invalid or expired token");
			}
		} catch (Exception e) {
			return ResponseEntity.badRequest().body("Error validating token: " + e.getMessage());
		}
	}
}
