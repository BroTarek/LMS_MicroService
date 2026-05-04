package com.lms.user.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileResponse {
    private String username;
    private String fullName;
    private String email;
    private String role; // STUDENT or TEACHER
    
    // Teacher fields
    private String department;
    private String title;
    
    // Student fields
    private String gradeLevel;
    private String major;
    
    public UserProfileResponse(String username, String fullName, String email, String role) {
        this.username = username;
        this.fullName = fullName;
        this.email = email;
        this.role = role;
    }
}
