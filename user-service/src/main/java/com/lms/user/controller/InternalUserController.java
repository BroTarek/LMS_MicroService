package com.lms.user.controller;

import com.lms.user.dto.InternalCreateUserRequest;
import com.lms.user.service.UserProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/internal/users")
@RequiredArgsConstructor
public class InternalUserController {
    
    private final UserProfileService userProfileService;
    
    @PostMapping
    public ResponseEntity<Void> createUserFromAuth(@RequestBody InternalCreateUserRequest request) {
        userProfileService.createProfile(request.getUsername(), request.getFullName(), request.getEmail());
        if ("TEACHER".equalsIgnoreCase(request.getRole())) {
            userProfileService.createTeacherProfile(request.getUsername(), "Pending", "Pending");
        } else {
            userProfileService.createStudentProfile(request.getUsername(), "Pending", "Pending");
        }
        return ResponseEntity.ok().build();
    }
}
