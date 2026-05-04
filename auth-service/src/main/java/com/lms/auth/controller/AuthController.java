package com.lms.auth.controller;

import com.lms.auth.dto.*;
import com.lms.auth.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@Slf4j
public class AuthController {
    
    private final AuthService authService;
    
    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest request) {
        authService.register(request);
        return ResponseEntity.ok().build();
    }
    
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }
    
    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        return ResponseEntity.ok(authService.refreshToken(request.getRefreshToken()));
    }
    
    @PostMapping("/logout")
    public ResponseEntity<?> logout(@RequestHeader("Authorization") String authHeader) {
        String token = authHeader.replace("Bearer ", "");
        authService.logout(token);
        return ResponseEntity.ok().build();
    }
    
    @GetMapping("/validate")
    public ResponseEntity<ValidateResponse> validate(@RequestHeader(value = HttpHeaders.AUTHORIZATION, required = false) String authHeader) {
        log.debug("Received validation request with header: {}", authHeader);
        if (authHeader == null || authHeader.isEmpty()) {
            log.warn("Authorization header is missing or empty");
            return ResponseEntity.badRequest().body(new ValidateResponse(false, null, null, "Authorization header is missing"));
        }
        String token = authHeader.replace("Bearer ", "");
        return ResponseEntity.ok(authService.validateToken(token));
    }
}
