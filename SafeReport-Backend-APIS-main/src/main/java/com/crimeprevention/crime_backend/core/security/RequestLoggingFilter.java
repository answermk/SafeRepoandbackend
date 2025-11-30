package com.crimeprevention.crime_backend.core.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
@Slf4j
public class RequestLoggingFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        
        String method = request.getMethod();
        String uri = request.getRequestURI();
        String authHeader = request.getHeader("Authorization");
        
        log.info("🔍 Request Logging - {} {} | Auth Header: {} | Origin: {}", 
            method, uri, 
            authHeader != null ? "Present" : "Missing",
            request.getHeader("Origin"));
        
        // Log authentication status
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.isAuthenticated() && !"anonymousUser".equals(auth.getName())) {
            log.info("✅ Authentication Status - User: {}, Authorities: {}", 
                auth.getName(), auth.getAuthorities());
        } else {
            log.info("❌ Authentication Status - Not authenticated or anonymous");
        }
        
        // Continue with the filter chain
        filterChain.doFilter(request, response);
        
        // Log response status
        log.info("📤 Response Logging - {} {} | Status: {}", method, uri, response.getStatus());
    }
}
