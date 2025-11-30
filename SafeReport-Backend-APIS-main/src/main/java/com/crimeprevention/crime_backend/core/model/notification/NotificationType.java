package com.crimeprevention.crime_backend.core.model.notification;

public enum NotificationType {
    CASE_ASSIGNED("Case Assigned"),
    BACKUP_REQUESTED("Backup Requested"),
    STATUS_UPDATE("Status Update"),
    CASE_UPDATE("Case Update"),
    SYSTEM_NOTIFICATION("System Notification");

    private final String displayName;

    NotificationType(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
