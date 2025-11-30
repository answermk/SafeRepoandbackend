package com.crimeprevention.crime_backend.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

/**
 * JPA Configuration
 * Enables JPA Auditing for automatic population of @CreatedDate, @LastModifiedDate, etc.
 */
@Configuration
@EnableJpaAuditing
public class JpaConfig {
    // JPA Auditing is now enabled for the application
}

