package com.crimeprevention.crime_backend.core.dto.user;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserImpactDTO {
    private int reportsSubmitted;
    private int actionsTaken;
    private int crimesPrevented;
    private int reputationPoints;
    private String reputationLevel;
    private int pointsToNextLevel;
    private double progressToNextLevel;
    
    // Detailed breakdown
    private long totalReports;
    private long resolvedReports;
    private long inProgressReports;
    private long pendingReports;
    private long closedReports;
    
    // Recent activity timeline
    private List<ActivityItem> recentActivity;
    
    // Badges/achievements
    private List<BadgeInfo> badges;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ActivityItem {
        private String action;
        private String detail;
        private String time;
        private LocalDateTime timestamp;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class BadgeInfo {
        private String name;
        private String icon;
        private String color;
        private boolean earned;
        private String description;
    }
}

