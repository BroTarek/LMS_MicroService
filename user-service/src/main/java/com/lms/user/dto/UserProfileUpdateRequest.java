package com.lms.user.dto;

import lombok.Data;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

@Data
public class UserProfileUpdateRequest {
    @NotBlank
    private String fullName;
    
    @NotBlank
    @Email
    private String email;
    
    // Optional Teacher fields
    private String department;
    private String title;
    
    // Optional Student fields
    private String gradeLevel;
    private String major;
}
