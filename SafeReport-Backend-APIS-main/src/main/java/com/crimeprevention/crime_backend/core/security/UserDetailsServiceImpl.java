package com.crimeprevention.crime_backend.core.security;


import com.crimeprevention.crime_backend.core.model.user.User;
import com.crimeprevention.crime_backend.core.repo.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.*;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserDetailsServiceImpl implements UserDetailsService {

	private final UserRepository userRepository;

	// Loads user by email (used for authentication)
	@Override
	public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
		User user = userRepository.findByEmail(email)
				.orElseThrow(() -> new UsernameNotFoundException("User not found with email: " + email));

		return org.springframework.security.core.userdetails.User.builder()
				.username(user.getEmail())
				.password(user.getPasswordHash())
				.authorities("ROLE_" + user.getRole().name())
				.disabled(!user.isEnabled())
				.accountExpired(false)
				.accountLocked(false)
				.credentialsExpired(false)
				.build();
	}

	public UserDetails loadUserById(UUID userId) throws UsernameNotFoundException {
		User user = userRepository.findById(userId)
				.orElseThrow(() -> new UsernameNotFoundException("User not found with ID: " + userId));

		return org.springframework.security.core.userdetails.User.builder()
				.username(user.getEmail())
				.password(user.getPasswordHash())
				.authorities("ROLE_" + user.getRole().name())
				.disabled(!user.isEnabled())
				.accountExpired(false)
				.accountLocked(false)
				.credentialsExpired(false)
				.build();
	}
}
