package com.lms.user.controller;

import com.lms.user.dto.UserProfileResponse;
import com.lms.user.dto.UserProfileUpdateRequest;
import com.lms.user.entity.UserProfile;
import com.lms.user.service.UserProfileService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    
    private final UserProfileService userProfileService;
    
    @GetMapping("/me")
    public ResponseEntity<UserProfileResponse> getMyProfile(@RequestHeader("X-Username") String username) {
        UserProfile profile = userProfileService.getProfile(username);
        String role = userProfileService.getUserRole(username);
        UserProfileResponse response = new UserProfileResponse(
            profile.getUsername(), profile.getFullName(), profile.getEmail(), role
        );
        return ResponseEntity.ok(response);
    }
    
    @PutMapping("/me")
    public ResponseEntity<UserProfileResponse> updateMyProfile(
            @Valid @RequestBody UserProfileUpdateRequest request,
            @RequestHeader("X-Username") String username) {
        UserProfile profile = userProfileService.updateProfile(username, request);
        String role = userProfileService.getUserRole(username);
        UserProfileResponse response = new UserProfileResponse(
            profile.getUsername(), profile.getFullName(), profile.getEmail(), role
        );
        return ResponseEntity.ok(response);
    }
}
