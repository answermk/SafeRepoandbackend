package com.crimeprevention.crime_backend.core.repo.chat;

import com.crimeprevention.crime_backend.core.model.chat.WatchGroup;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface WatchGroupRepository extends JpaRepository<WatchGroup, UUID> {

    @Query("SELECT wg FROM WatchGroup wg JOIN wg.members wgm WHERE wgm.user.id = :userId AND wgm.isActive = true ORDER BY wg.createdAt DESC")
    Page<WatchGroup> findByUserIdOrderByCreatedAtDesc(@Param("userId") UUID userId, Pageable pageable);

    Page<WatchGroup> findByLocationIdOrderByCreatedAtDesc(UUID locationId, Pageable pageable);

    @Query("SELECT wg FROM WatchGroup wg WHERE wg.status IN :statuses ORDER BY wg.createdAt DESC")
    Page<WatchGroup> findByStatusInOrderByCreatedAtDesc(@Param("statuses") java.util.List<com.crimeprevention.crime_backend.core.model.enums.WatchGroupStatus> statuses, Pageable pageable);

    @Query(value = "SELECT location_id FROM watch_groups WHERE id = :groupId", nativeQuery = true)
    UUID findLocationIdByGroupId(@Param("groupId") UUID groupId);

} 