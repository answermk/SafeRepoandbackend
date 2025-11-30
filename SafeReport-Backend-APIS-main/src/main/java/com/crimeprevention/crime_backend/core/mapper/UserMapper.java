package com.crimeprevention.crime_backend.core.mapper;

import com.crimeprevention.crime_backend.core.dto.user.UserDTO;
import com.crimeprevention.crime_backend.core.model.user.User;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.ReportingPolicy;

import java.util.List;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface UserMapper {
    UserDTO toDto(User user);

    List<UserDTO> toDtoList(List<User> users);

    @Mapping(target = "passwordHash", ignore = true)
    User toEntity(UserDTO dto);
}
