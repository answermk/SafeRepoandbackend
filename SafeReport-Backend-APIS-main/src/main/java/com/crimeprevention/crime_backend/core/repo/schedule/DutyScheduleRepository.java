package com.crimeprevention.crime_backend.core.repo.schedule;

import com.crimeprevention.crime_backend.core.model.schedule.DutySchedule;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface DutyScheduleRepository extends JpaRepository<DutySchedule, UUID> {

    List<DutySchedule> findByOfficerId(UUID officerId);

}
