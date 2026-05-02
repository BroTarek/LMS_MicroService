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
        return ResponseEntity.ok(userProfileService.getFullProfileResponse(username));
    }
    
    @PutMapping("/me")
    public ResponseEntity<UserProfileResponse> updateMyProfile(
            @Valid @RequestBody UserProfileUpdateRequest request,
            @RequestHeader("X-Username") String username) {
        userProfileService.updateProfile(username, request);
        return ResponseEntity.ok(userProfileService.getFullProfileResponse(username));
    }
}
