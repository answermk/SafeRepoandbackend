package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.dto.user.RegisterUserRequest;
import com.crimeprevention.crime_backend.core.dto.user.UserDTO;
import com.crimeprevention.crime_backend.core.dto.user.UpdateUserRequest;
import com.crimeprevention.crime_backend.core.dto.user.UserStatsDTO;
import com.crimeprevention.crime_backend.core.service.interfaces.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController  // Marks this class as a REST controller where methods return JSON
@RequestMapping("/api/users")  // Base path for all user endpoints
@RequiredArgsConstructor  // Lombok annotation to autowire required dependencies via constructor
public class UserController {

	private final UserService userService;  // Service layer to handle user logic

	// Admin creates user (CIVILIAN, OFFICER, ADMIN)
	@PostMapping
	@PreAuthorize("hasRole('ADMIN')")
	public ResponseEntity<?> createUserByAdmin(@Valid @RequestBody RegisterUserRequest request) {
		try {
			System.out.println("🔵 Creating user with role: " + request.getRole());
			System.out.println("🔵 User details - Name: " + request.getFullName() + ", Email: " + request.getEmail());
			UserDTO created = userService.createUserByAdmin(request);
			System.out.println("✅ User created successfully with ID: " + created.getId());
			return ResponseEntity.ok(created);
		} catch (IllegalArgumentException e) {
			System.err.println("❌ Validation error: " + e.getMessage());
			Map<String, String> error = new HashMap<>();
			error.put("error", e.getMessage());
			return ResponseEntity.badRequest().body(error);
		} catch (Exception e) {
			System.err.println("❌ Error creating user: " + e.getMessage());
			e.printStackTrace();
			Map<String, String> error = new HashMap<>();
			error.put("error", "Failed to create user: " + e.getMessage());
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
		}
	}

	// Stats: counts of users and officers
	@GetMapping("/stats")
	public ResponseEntity<UserStatsDTO> getUserStats() {
		return ResponseEntity.ok(userService.getUserStats());
	}

	// Get user details by user ID
	@GetMapping("/{id}")
	public ResponseEntity<UserDTO> getUserById(@PathVariable("id") UUID userId) {
		// Calls service to get user and returns it with HTTP 200 OK
		UserDTO userDTO = userService.getUserById(userId);
		return ResponseEntity.ok(userDTO);
	}

	// Update user details by user ID
	@PutMapping("/{id}")
	public ResponseEntity<UserDTO> updateUser(
			@PathVariable("id") UUID userId,
			@RequestBody UpdateUserRequest updateRequest) {

		// Calls service to update user data and returns updated user DTO
		UserDTO updatedUser = userService.updateUser(userId, updateRequest);
		return ResponseEntity.ok(updatedUser);
	}

	// Update user details by email
	@PutMapping("/by-email/{email}")
	public ResponseEntity<UserDTO> updateUserByEmail(
			@PathVariable("email") String email,
			@RequestBody UpdateUserRequest updateRequest) {
		UserDTO updatedUser = userService.updateUserByEmail(email, updateRequest);
		return ResponseEntity.ok(updatedUser);
	}

	// Delete user by user ID
	@DeleteMapping("/{id}")
	public ResponseEntity<Void> deleteUser(@PathVariable("id") UUID userId) {
		// Calls service to delete user by id
		userService.deactivateUser(userId);
		// Returns HTTP 204 No Content to signify successful deletion with no body
		return ResponseEntity.noContent().build();
	}

	// Delete user by email (convenience)
	@DeleteMapping("/by-email/{email}")
	public ResponseEntity<Void> deleteUserByEmail(@PathVariable("email") String email) {
		userService.deactivateUserByEmail(email);
		return ResponseEntity.noContent().build();
	}

	// Optional: List all users (for admin or internal use)
	@GetMapping("/all")
	public ResponseEntity<List<UserDTO>> getAllUsers() {
		// Calls service to get all users and returns list
		List<UserDTO> users = userService.getAllUsers();
		return ResponseEntity.ok(users);
	}
	
	// Change password endpoint
	@PutMapping("/{id}/change-password")
	public ResponseEntity<?> changePassword(
			@PathVariable("id") UUID userId,
			@Valid @RequestBody com.crimeprevention.crime_backend.core.dto.user.UpdatePasswordRequest request) {
		try {
			userService.changePassword(userId, request);
			Map<String, String> response = new HashMap<>();
			response.put("message", "Password changed successfully");
			return ResponseEntity.ok(response);
		} catch (IllegalArgumentException e) {
			Map<String, String> error = new HashMap<>();
			error.put("error", e.getMessage());
			return ResponseEntity.badRequest().body(error);
		} catch (Exception e) {
			System.err.println("❌ Error changing password: " + e.getMessage());
			e.printStackTrace();
			Map<String, String> error = new HashMap<>();
			error.put("error", "Failed to change password: " + e.getMessage());
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
		}
	}
}
