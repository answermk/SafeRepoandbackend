package com.crimeprevention.crime_backend.core.mapper;

import com.crimeprevention.crime_backend.core.dto.report.ReportResponse;
import com.crimeprevention.crime_backend.core.model.report.Report;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.ReportingPolicy;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.List;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface ReportMapper {
    @Mapping(target = "id", source = "id")
    @Mapping(target = "title", source = "title")
    @Mapping(target = "description", source = "description")
    @Mapping(target = "crimeRelationship", source = "crimeRelationship")
    @Mapping(target = "witnessInfo", source = "witnessInfo")
    @Mapping(target = "isAnonymous", source = "anonymous")
    @Mapping(target = "status", source = "status")
    @Mapping(target = "location", source = "location")
    @Mapping(target = "createdAt", source = "createdAt")
    @Mapping(target = "updatedAt", source = "updatedAt")
    ReportResponse toResponse(Report report);

    List<ReportResponse> toResponseList(List<Report> reports);
}