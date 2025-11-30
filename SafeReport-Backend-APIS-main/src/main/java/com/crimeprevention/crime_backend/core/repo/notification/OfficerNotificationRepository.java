package com.crimeprevention.crime_backend.core.repo.notification;

import com.crimeprevention.crime_backend.core.model.enums.NotificationType;
import com.crimeprevention.crime_backend.core.model.notification.OfficerNotification;
import com.crimeprevention.crime_backend.core.model.user.Officer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface OfficerNotificationRepository extends JpaRepository<OfficerNotification, UUID> {
    List<OfficerNotification> findByOfficerAndReadFalseOrderByCreatedAtDesc(Officer officer);
    List<OfficerNotification> findByOfficerOrderByCreatedAtDesc(Officer officer);
    List<OfficerNotification> findByOfficerAndTypeOrderByCreatedAtDesc(Officer officer, NotificationType type);
}