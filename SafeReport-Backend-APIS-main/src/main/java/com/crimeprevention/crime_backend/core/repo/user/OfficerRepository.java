package com.crimeprevention.crime_backend.core.repo.user;

import com.crimeprevention.crime_backend.core.model.user.Officer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import com.crimeprevention.crime_backend.core.model.enums.DutyStatus;

public interface OfficerRepository extends JpaRepository<Officer, UUID> {

    List<Officer> findByDutyStatus(DutyStatus dutyStatus);

    // Custom query to find officers available for backup
    List<Officer> findByDutyStatusAndBackupRequestedFalse(DutyStatus dutyStatus);

    // Find officer by human-readable officer ID
    Optional<Officer> findByOfficerId(String officerId);

    // Check if officer ID exists
    boolean existsByOfficerId(String officerId);

    // Find the highest officer ID for a given year prefix
    @Query("SELECT o.officerId FROM Officer o WHERE o.officerId LIKE :prefix% ORDER BY o.officerId DESC LIMIT 1")
    String findTopByOfficerIdStartingWithOrderByOfficerIdDesc(@Param("prefix") String prefix);

}
