package com.crimeprevention.crime_backend.core.dto.user;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserStatsDTO {
    private long totalUsers;
    private long activeUsers;
    private long inactiveUsers;
    private long civilianUsers;
    private long officerUsers;
    private long adminUsers;
    private long totalReports;
    private long resolvedReports;
    private long pendingReports;
    private long totalGroups;
    private long activeGroups;
    private long totalMessages;
    private long unreadMessages;
    private long totalNotifications;
    private long unreadNotifications;
}
