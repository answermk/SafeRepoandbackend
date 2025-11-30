package com.crimeprevention.crime_backend.core.dto.officer;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LocationUpdateDTO {
    private double lat;
    private double lng;
}