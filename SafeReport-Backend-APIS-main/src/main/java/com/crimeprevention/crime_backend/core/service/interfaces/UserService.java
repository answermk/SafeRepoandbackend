package com.crimeprevention.crime_backend.core.service.interfaces;

import com.crimeprevention.crime_backend.core.dto.user.*;
import java.util.List;
import java.util.UUID;

public interface UserService {
    UserDTO createUserByAdmin(RegisterUserRequest request);
    UserDTO getUserById(UUID id);
    UserDTO updateUser(UUID id, UpdateUserRequest request);
    UserDTO updateUserByEmail(String email, UpdateUserRequest request);
    void deactivateUser(UUID id);
    void deactivateUserByEmail(String email);
    List<UserDTO> getAllUsers();
    UserDTO registerCivilian(SignupRequest request);
    UserStatsDTO getUserStats();
    void changePassword(UUID userId, UpdatePasswordRequest request);
    UserImpactDTO getUserImpact(UUID userId);
    AdminContactInfoDTO getAdminContactInfo();
}