package com.crimeprevention.crime_backend.core.model.enums;

public enum NotificationPriority {
    LOW,        // Non-urgent notifications (profile updates, etc.)
    NORMAL,     // Standard notifications (messages, group updates)
    HIGH,       // Important notifications (case assignments, officer changes)
    URGENT,     // Critical notifications (system alerts, security issues)
    EMERGENCY   // Emergency notifications (immediate attention required)
} 