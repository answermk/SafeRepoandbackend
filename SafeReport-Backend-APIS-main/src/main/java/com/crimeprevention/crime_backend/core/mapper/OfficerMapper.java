package com.crimeprevention.crime_backend.core.mapper;

import com.crimeprevention.crime_backend.core.dto.officer.OfficerDTO;
import com.crimeprevention.crime_backend.core.model.user.Officer;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.ReportingPolicy;

import java.util.List;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface OfficerMapper {
    OfficerDTO toDto(Officer officer);

    List<OfficerDTO> toDtoList(List<Officer> officers);

    @Mapping(target = "passwordHash", ignore = true)
    Officer toEntity(OfficerDTO dto);
}
