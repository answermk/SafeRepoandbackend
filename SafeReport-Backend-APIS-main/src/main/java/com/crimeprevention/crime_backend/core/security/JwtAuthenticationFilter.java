package com.crimeprevention.crime_backend.core.security;


import com.crimeprevention.crime_backend.core.util.JwtTokenProvider;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.UUID;

@Component
@RequiredArgsConstructor
@Slf4j
public class JwtAuthenticationFilter extends OncePerRequestFilter {

	private final JwtTokenProvider tokenProvider;
	private final UserDetailsServiceImpl userDetailsService;

	@Override
	protected void doFilterInternal(HttpServletRequest request,
				HttpServletResponse response,
				FilterChain filterChain)
				throws ServletException, IOException {

		String requestURI = request.getRequestURI();
		String method = request.getMethod();
		String clientTime = request.getHeader("X-Client-Time");
		
		log.info("🔍 JWT Filter - Processing request: {} {} | Origin: {} | User-Agent: {} | Client-Time: {} | Server-Time: {}", 
			method, requestURI, 
			request.getHeader("Origin"),
			request.getHeader("User-Agent") != null ? request.getHeader("User-Agent").substring(0, Math.min(50, request.getHeader("User-Agent").length())) : "N/A",
			clientTime != null ? clientTime : "N/A",
			java.time.Instant.now().toString());

		try {
			// Get JWT from the Authorization header
			String header = request.getHeader("Authorization");
			String token = null;

			log.info("🔑 Authorization header: {}", header != null ? "Present" : "Missing");
			
			if (header != null && header.startsWith("Bearer ")) {
				token = header.substring(7); // remove "Bearer "
				log.info("🎫 JWT token found: {}...", token.substring(0, Math.min(token.length(), 20)));
			} else {
				log.warn("❌ No Bearer token found in Authorization header");
			}

			// Validate token and set authentication
			if (token != null) {
				System.out.println("🔍 JWT Filter - About to validate token...");
				boolean isValid = tokenProvider.validateToken(token);
				System.out.println("🔍 JWT Filter - Token validation result: " + isValid);
				
				if (isValid) {
					UUID userId = tokenProvider.getUserIdFromJWT(token);
					log.info("✅ Valid JWT token for user ID: {}", userId);
					
					// Extract role from token claims
					String role = tokenProvider.getRoleFromJWT(token);
					log.info("🎭 Role from token: {}", role);
					
					UserDetails userDetails = userDetailsService.loadUserById(userId);
					log.info("👤 User details loaded - Username: {}, Authorities: {}", 
						userDetails.getUsername(), userDetails.getAuthorities());

					UsernamePasswordAuthenticationToken authentication =
							new UsernamePasswordAuthenticationToken(
									userId.toString(), null, userDetails.getAuthorities()
							);

					authentication.setDetails(
							new WebAuthenticationDetailsSource().buildDetails(request)
					);

					SecurityContextHolder.getContext().setAuthentication(authentication);
					log.info("🔐 Authentication set for user ID: {} with authorities: {}", 
						userId, userDetails.getAuthorities());
				} else {
					System.out.println("❌ JWT Filter - Token validation failed");
					log.warn("❌ Invalid JWT token for request: {} {}", method, requestURI);
				}
			} else {
				log.warn("❌ No JWT token found for request: {} {}", method, requestURI);
			}
		} catch (Exception e) {
			log.error("💥 Error processing JWT token for request: {} {}", method, requestURI, e);
			System.out.println("🚨 JWT Filter Exception Details:");
			System.out.println("  - Request URI: " + requestURI);
			System.out.println("  - Method: " + method);
			System.out.println("  - Exception: " + e.getClass().getSimpleName());
			System.out.println("  - Message: " + e.getMessage());
			e.printStackTrace();
			
			// Don't set authentication on error, let it proceed to authentication entry point
			SecurityContextHolder.clearContext();
		}

		log.info("➡️ JWT Filter - Proceeding to next filter for: {} {}", method, requestURI);
		filterChain.doFilter(request, response);
	}
}
