package com.lms.user.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class InternalCreateUserRequest {
    private String username;
    private String role;
    private String fullName;
    private String email;
}
