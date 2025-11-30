package com.crimeprevention.crime_backend.core.model.location;

import com.crimeprevention.crime_backend.core.base.AbstractAuditEntity;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.Type;

import java.util.UUID;

@Entity
@Table(name = "locations",
        indexes = {
                @Index(name = "idx_locations_lat_lng", columnList = "latitude, longitude")
        })
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Location extends AbstractAuditEntity {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    private UUID id;

    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    @Column(columnDefinition = "TEXT")
    private String address;

    @Column(length = 100)
    private String district;

    @Column(length = 100)
    private String sector;

    @Column(length = 100)
    private String zone;
}
