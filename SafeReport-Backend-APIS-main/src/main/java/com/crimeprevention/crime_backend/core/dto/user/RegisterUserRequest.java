package com.crimeprevention.crime_backend.core.dto.user;

import com.crimeprevention.crime_backend.core.model.enums.UserRole;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RegisterUserRequest {

	@NotBlank
	@Size(min = 3, max = 100)
	private String fullName;

	@NotBlank
	@Email
	private String email;

	@Size(min = 3, max = 50)
	private String username;

	@NotBlank
	@Size(min = 6)
	private String password;

	@Size(min = 10, max = 15)
	private String phoneNumber;

	@NotNull
	private UserRole role; // CIVILIAN, OFFICER, ADMIN, ANALYST, SUPERVISOR
} 