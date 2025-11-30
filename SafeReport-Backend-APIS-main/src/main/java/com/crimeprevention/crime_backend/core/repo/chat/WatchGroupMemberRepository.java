package com.crimeprevention.crime_backend.core.repo.chat;

import com.crimeprevention.crime_backend.core.model.chat.WatchGroupMember;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface WatchGroupMemberRepository extends JpaRepository<WatchGroupMember, UUID> {

    Optional<WatchGroupMember> findByUserIdAndGroupId(UUID userId, UUID groupId);

    boolean existsByUserIdAndGroupIdAndIsActiveTrue(UUID userId, UUID groupId);

    long countByGroupIdAndIsAdminTrueAndIsActiveTrue(UUID groupId);

    boolean existsByUserIdAndGroupIdAndIsAdminTrueAndIsActiveTrue(UUID userId, UUID groupId);

    java.util.List<WatchGroupMember> findByGroupId(UUID groupId);

}
