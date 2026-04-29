package com.lms.auth.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class ValidateResponse {
    private boolean valid;
    private String username;
    private String role;
    private String message;
}
