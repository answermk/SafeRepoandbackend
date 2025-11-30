package com.crimeprevention.crime_backend.core.repo.report;

import com.crimeprevention.crime_backend.core.model.report.WeatherCondition;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface WeatherConditionRepository extends JpaRepository<WeatherCondition, UUID> {

    Optional<WeatherCondition> findByCondition(String condition);

}
