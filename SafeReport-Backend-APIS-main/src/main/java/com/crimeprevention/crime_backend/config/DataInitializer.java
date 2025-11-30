package com.crimeprevention.crime_backend.config;

import com.crimeprevention.crime_backend.core.model.enums.ForumPriority;
import com.crimeprevention.crime_backend.core.model.enums.ForumStatus;
import com.crimeprevention.crime_backend.core.model.enums.UserRole;
import com.crimeprevention.crime_backend.core.model.forum.ForumPost;
import com.crimeprevention.crime_backend.core.model.forum.ForumReply;
import com.crimeprevention.crime_backend.core.model.user.User;
import com.crimeprevention.crime_backend.core.repo.forum.ForumPostRepository;
import com.crimeprevention.crime_backend.core.repo.forum.ForumReplyRepository;
import com.crimeprevention.crime_backend.core.repo.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.Instant;
import java.util.Arrays;

/**
 * Seeds test data for development:
 * - Admin user
 * - Forum posts and replies
 * Remove or replace with proper migrations in production.
 * Excluded from test profile to avoid data initialization issues.
 */
@Component
@Profile("!test")
@RequiredArgsConstructor
public class DataInitializer implements ApplicationRunner {

	private final UserRepository userRepository;
	private final PasswordEncoder passwordEncoder;
	private final ForumPostRepository forumPostRepository;
	private final ForumReplyRepository forumReplyRepository;

	@Override
	public void run(ApplicationArguments args) {
		// Initialize admin user
		initializeAdminUser();
		
		// Initialize forum test data
		initializeForumData();
	}
	
	private void initializeAdminUser() {
		final String adminEmail = "ced@admin.com";
		if (userRepository.existsByEmail(adminEmail)) {
			// Ensure existing admin user is enabled
			userRepository.findByEmail(adminEmail).ifPresent(user -> {
				if (!user.isEnabled()) {
					user.setEnabled(true);
					userRepository.save(user);
					System.out.println("✅ Enabled existing admin user: " + adminEmail);
				}
			});
			return;
		}

		User admin = User.builder()
				.fullName("System Admin")
				.email(adminEmail)
				.username("admin")
				.phoneNumber("0781556345")
				.passwordHash(passwordEncoder.encode("Admin123"))
				.role(UserRole.ADMIN)
				.enabled(true)  // Explicitly set enabled to true
				.isActive(true)  // Explicitly set isActive to true
				.build();

		userRepository.save(admin);
		System.out.println("✅ Created admin user: " + adminEmail + " with password: Admin123");
	}
	
	private void initializeForumData() {
		// Only initialize if no posts exist
		if (forumPostRepository.count() > 0) {
			return;
		}
		
		// Get or create test users
		User admin = userRepository.findByEmail("ced@admin.com")
			.orElseGet(() -> {
				User newAdmin = User.builder()
					.fullName("System Admin")
					.email("ced@admin.com")
					.username("admin")
					.phoneNumber("0781556345")
					.passwordHash(passwordEncoder.encode("Admin123"))
					.role(UserRole.ADMIN)
					.enabled(true)  // Explicitly set enabled to true
					.isActive(true)  // Explicitly set isActive to true
					.build();
				return userRepository.save(newAdmin);
			});
		
		// Create a civilian user for forum posts
		User civilian = userRepository.findByEmail("civilian@test.com")
			.orElseGet(() -> {
				User newCivilian = User.builder()
					.fullName("Test Civilian")
					.email("civilian@test.com")
					.username("testcivilian")
					.phoneNumber("0781234567")
					.passwordHash(passwordEncoder.encode("password123"))
					.role(UserRole.CIVILIAN)
					.build();
				return userRepository.save(newCivilian);
			});
		
		// Create forum posts
		ForumPost post1 = ForumPost.builder()
			.title("Suspicious Activity Near City Park")
			.content("I noticed some suspicious individuals loitering around the city park late at night. They were acting very suspiciously and I'm concerned about safety in the area.")
			.authorId(civilian.getId())
			.author(civilian)
			.priority(ForumPriority.HIGH)
			.status(ForumStatus.PENDING)
			.category("Safety Alert")
			.location("City Park, Kigali")
			.tags(Arrays.asList("safety", "suspicious-activity", "park"))
			.views(15)
			.repliesCount(2)
			.flagged(false)
			.resolved(false)
			.hasOfficialResponse(true)
			.officialResponse("Thank you for reporting this. We have dispatched officers to investigate the area. Please contact us if you notice any further suspicious activity.")
			.createdAt(Instant.now().minusSeconds(86400)) // 1 day ago
			.build();
		post1 = forumPostRepository.save(post1);
		
		ForumPost post2 = ForumPost.builder()
			.title("Broken Street Lights on Main Street")
			.content("Several street lights on Main Street have been broken for over a week now. This makes the area unsafe at night, especially for pedestrians.")
			.authorId(civilian.getId())
			.author(civilian)
			.priority(ForumPriority.MEDIUM)
			.status(ForumStatus.RESPONDED)
			.category("Infrastructure")
			.location("Main Street, Kigali")
			.tags(Arrays.asList("infrastructure", "street-lights", "safety"))
			.views(8)
			.repliesCount(1)
			.flagged(false)
			.resolved(false)
			.hasOfficialResponse(true)
			.officialResponse("We have reported this to the city maintenance department. They will address this issue within 48 hours.")
			.createdAt(Instant.now().minusSeconds(172800)) // 2 days ago
			.build();
		post2 = forumPostRepository.save(post2);
		
		ForumPost post3 = ForumPost.builder()
			.title("Noise Complaint - Late Night Parties")
			.content("There have been excessive noise complaints from a nearby residence. They're having loud parties late into the night, disturbing the entire neighborhood.")
			.authorId(civilian.getId())
			.author(civilian)
			.priority(ForumPriority.LOW)
			.status(ForumStatus.PENDING)
			.category("Noise")
			.location("Residential Area, Kigali")
			.tags(Arrays.asList("noise", "complaint", "neighborhood"))
			.views(5)
			.repliesCount(0)
			.flagged(false)
			.resolved(false)
			.hasOfficialResponse(false)
			.createdAt(Instant.now().minusSeconds(3600)) // 1 hour ago
			.build();
		post3 = forumPostRepository.save(post3);
		
		ForumPost post4 = ForumPost.builder()
			.title("URGENT: Armed Robbery Attempt")
			.content("I witnessed an attempted armed robbery at the shopping center. The suspects fled before police arrived. This is a critical safety issue that needs immediate attention.")
			.authorId(civilian.getId())
			.author(civilian)
			.priority(ForumPriority.CRITICAL)
			.status(ForumStatus.RESPONDED)
			.category("Safety Alert")
			.location("Shopping Center, Kigali")
			.tags(Arrays.asList("urgent", "robbery", "critical", "safety"))
			.views(42)
			.repliesCount(3)
			.flagged(true)
			.resolved(false)
			.hasOfficialResponse(true)
			.officialResponse("This incident has been reported to our investigation unit. We have increased patrols in the area. If you have any additional information, please contact us immediately.")
			.createdAt(Instant.now().minusSeconds(7200)) // 2 hours ago
			.build();
		post4 = forumPostRepository.save(post4);
		
		ForumPost post5 = ForumPost.builder()
			.title("Potholes on Highway Causing Accidents")
			.content("The highway has several large potholes that are causing traffic issues and potential accidents. This needs urgent repair.")
			.authorId(civilian.getId())
			.author(civilian)
			.priority(ForumPriority.HIGH)
			.status(ForumStatus.RESOLVED)
			.category("Infrastructure")
			.location("Highway, Kigali")
			.tags(Arrays.asList("infrastructure", "potholes", "highway", "traffic"))
			.views(12)
			.repliesCount(1)
			.flagged(false)
			.resolved(true)
			.resolvedAt(Instant.now().minusSeconds(3600))
			.hasOfficialResponse(true)
			.officialResponse("The potholes have been repaired. Thank you for reporting this issue.")
			.createdAt(Instant.now().minusSeconds(259200)) // 3 days ago
			.build();
		post5 = forumPostRepository.save(post5);
		
		// Create replies
		ForumReply reply1 = ForumReply.builder()
			.postId(post1.getId())
			.post(post1)
			.content("I've also noticed this. It's been going on for a few days now.")
			.authorId(civilian.getId())
			.author(civilian)
			.isOfficial(false)
			.createdAt(Instant.now().minusSeconds(82800)) // ~23 hours ago
			.build();
		forumReplyRepository.save(reply1);
		
		ForumReply reply2 = ForumReply.builder()
			.postId(post1.getId())
			.post(post1)
			.content("Thank you for reporting this. We have dispatched officers to investigate the area. Please contact us if you notice any further suspicious activity.")
			.authorId(admin.getId())
			.author(admin)
			.isOfficial(true)
			.createdAt(Instant.now().minusSeconds(79200)) // ~22 hours ago
			.build();
		forumReplyRepository.save(reply2);
		
		ForumReply reply3 = ForumReply.builder()
			.postId(post2.getId())
			.post(post2)
			.content("We have reported this to the city maintenance department. They will address this issue within 48 hours.")
			.authorId(admin.getId())
			.author(admin)
			.isOfficial(true)
			.createdAt(Instant.now().minusSeconds(165600)) // ~46 hours ago
			.build();
		forumReplyRepository.save(reply3);
		
		ForumReply reply4 = ForumReply.builder()
			.postId(post4.getId())
			.post(post4)
			.content("This incident has been reported to our investigation unit. We have increased patrols in the area. If you have any additional information, please contact us immediately.")
			.authorId(admin.getId())
			.author(admin)
			.isOfficial(true)
			.createdAt(Instant.now().minusSeconds(5400)) // ~1.5 hours ago
			.build();
		forumReplyRepository.save(reply4);
		
		ForumReply reply5 = ForumReply.builder()
			.postId(post4.getId())
			.post(post4)
			.content("I saw the same thing! It was very scary.")
			.authorId(civilian.getId())
			.author(civilian)
			.isOfficial(false)
			.createdAt(Instant.now().minusSeconds(3600)) // 1 hour ago
			.build();
		forumReplyRepository.save(reply5);
		
		ForumReply reply6 = ForumReply.builder()
			.postId(post5.getId())
			.post(post5)
			.content("The potholes have been repaired. Thank you for reporting this issue.")
			.authorId(admin.getId())
			.author(admin)
			.isOfficial(true)
			.createdAt(Instant.now().minusSeconds(3600)) // 1 hour ago
			.build();
		forumReplyRepository.save(reply6);
	}
} 