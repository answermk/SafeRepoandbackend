package com.crimeprevention.crime_backend.core.model.report;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "crime_types")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CrimeType {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    private UUID id;

    @Column(length = 50, nullable = false, unique = true)
    private String name;
}
