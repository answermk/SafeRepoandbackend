package com.crimeprevention.crime_backend.core.model.enums;

public enum WatchGroupStatus {
    PENDING,    // Waiting for officer approval
    APPROVED,   // Officer approved and assigned
    REJECTED,   // Officer rejected
    ACTIVE      // Group is fully operational
} 