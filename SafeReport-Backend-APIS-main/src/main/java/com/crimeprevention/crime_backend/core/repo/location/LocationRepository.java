package com.crimeprevention.crime_backend.core.repo.location;

import com.crimeprevention.crime_backend.core.model.location.Location;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface LocationRepository extends JpaRepository<Location, UUID> {
    // Custom queries if needed
}
