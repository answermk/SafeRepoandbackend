package com.crimeprevention.crime_backend.core.repo.report;

import com.crimeprevention.crime_backend.core.model.report.CrimeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface CrimeTypeRepository extends JpaRepository<CrimeType, UUID> {

    Optional<CrimeType> findByName(String name);

}
