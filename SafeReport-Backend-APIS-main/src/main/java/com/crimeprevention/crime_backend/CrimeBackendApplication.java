package com.crimeprevention.crime_backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;

@SpringBootApplication
@EnableMethodSecurity
@EnableConfigurationProperties
public class CrimeBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(CrimeBackendApplication.class, args);
	}

}
