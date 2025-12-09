package com.crimeprevention.crime_backend.core.mapper;

import com.crimeprevention.crime_backend.core.dto.user.UserDTO;
import com.crimeprevention.crime_backend.core.model.user.User;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.ReportingPolicy;

import java.util.List;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface UserMapper {
    default UserDTO toDto(User user) {
        if (user == null) {
            return null;
        }
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setFullName(user.getFullName());
        dto.setEmail(user.getEmail());
        dto.setPhoneNumber(user.getPhoneNumber());
        dto.setUsername(user.getUsername());
        dto.setRole(user.getRole());
        dto.setEnabled(user.isEnabled());
        dto.setActive(user.isActive());
        dto.setAnonymousMode(user.getAnonymousMode() != null ? user.getAnonymousMode() : false);
        dto.setLocationSharing(user.getLocationSharing() != null ? user.getLocationSharing() : true);
        dto.setPasswordChangedAt(user.getPasswordChangedAt());
        dto.setCreatedAt(user.getCreatedAt());
        dto.setUpdatedAt(user.getUpdatedAt());
        return dto;
    }

    List<UserDTO> toDtoList(List<User> users);

    @Mapping(target = "passwordHash", ignore = true)
    User toEntity(UserDTO dto);
}
