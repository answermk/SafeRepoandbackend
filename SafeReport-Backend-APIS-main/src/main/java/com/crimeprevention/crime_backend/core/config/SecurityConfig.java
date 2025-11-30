package com.crimeprevention.crime_backend.core.config;

import com.crimeprevention.crime_backend.core.security.JwtAuthenticationFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfigurationSource;
import jakarta.servlet.http.HttpServletResponse;

@Configuration
@RequiredArgsConstructor
public class SecurityConfig {

	private final JwtAuthenticationFilter jwtAuthFilter;
	private final CorsConfigurationSource corsConfigurationSource;

	@Bean
	public PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder();
	}

	// Configures security filters and rules
	@Bean
	public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
		http
				.csrf(csrf -> csrf.disable())
				.cors(cors -> cors.configurationSource(corsConfigurationSource))
				.authorizeHttpRequests(auth -> auth
					.requestMatchers("/api/auth/**").permitAll()
					.requestMatchers("/api/test/public").permitAll()
					.requestMatchers("/api/test/password/**").permitAll()  // Allow password hash utilities (TEMPORARY - remove in production)
					.requestMatchers("/error").permitAll()  // Allow error endpoint
					.requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()  // Allow all OPTIONS requests
					.requestMatchers("/api/files/**").permitAll()  // File serving - public access (files are UUID-based, hard to guess)
					.requestMatchers("/api/upload").authenticated()  // File upload requires authentication
						.requestMatchers("/api/test/**").authenticated()
						.requestMatchers("/api/users/**").authenticated()
						.requestMatchers("/api/officers/**").authenticated()
						.requestMatchers("/api/reports/**").authenticated()
						.requestMatchers("/api/messages/**").authenticated()
						.requestMatchers("/api/ai/**").authenticated()
						.requestMatchers("/api/ai/summaries/**").authenticated()
						.anyRequest().authenticated()
				)
				.sessionManagement(sess -> sess.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
				.addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class)
				.exceptionHandling(ex -> ex
					.authenticationEntryPoint((request, response, authException) -> {
						System.out.println("🚫 Authentication failed for: " + request.getRequestURI() + " - " + authException.getMessage());
						response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
						response.getWriter().write("{\"error\":\"Authentication failed\"}");
					})
					.accessDeniedHandler((request, response, accessDeniedException) -> {
						System.out.println("🚫 Access denied for: " + request.getRequestURI() + " - " + accessDeniedException.getMessage());
						response.setStatus(HttpServletResponse.SC_FORBIDDEN);
						response.getWriter().write("{\"error\":\"Access denied\"}");
					})
				);

		return http.build();
	}

	@Bean
	public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
		return config.getAuthenticationManager();
	}
}
