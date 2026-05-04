package com.lms.auth.service;

import com.lms.auth.dto.*;
import com.lms.auth.entity.Credential;
import com.lms.auth.repository.CredentialRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AuthService {
    
    private final CredentialRepository credentialRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final BlacklistService blacklistService;
    private final RestTemplate restTemplate;
    
    public void register(RegisterRequest request) {
        if (credentialRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Username already exists");
        }
        
        Credential credential = new Credential();
        credential.setUsername(request.getUsername());
        credential.setPassword(passwordEncoder.encode(request.getPassword()));
        credential.setRole(request.getRole());
        credential.setEnabled(true);
        
        credentialRepository.save(credential);
        
        Map<String, String> userRequest = new HashMap<>();
        userRequest.put("username", request.getUsername());
        userRequest.put("role", request.getRole());
        userRequest.put("fullName", request.getFullName());
        userRequest.put("email", request.getEmail());
        
        restTemplate.postForEntity("http://user-service/internal/users", userRequest, Void.class);
        
    }
    
    public AuthResponse login(LoginRequest request) {
        Credential credential = credentialRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new RuntimeException("Invalid credentials"));
        
        if (!passwordEncoder.matches(request.getPassword(), credential.getPassword())) {
            throw new RuntimeException("Invalid credentials");
        }
        
        String token = jwtService.generateToken(credential.getUsername(), credential.getRole());
        String refreshToken = jwtService.generateRefreshToken(credential.getUsername(), credential.getRole());
        
        return new AuthResponse(token, refreshToken, credential.getUsername(), credential.getRole());
    }
    
    public void logout(String token) {
        io.jsonwebtoken.Claims claims = jwtService.extractAllClaims(token);
        long expiration = claims.getExpiration().getTime();
        long ttl = expiration - System.currentTimeMillis();
        blacklistService.blacklistToken(token, ttl);
    }
    
    public AuthResponse refreshToken(String refreshToken) {
        if (!jwtService.isTokenValid(refreshToken)) {
            throw new RuntimeException("Invalid or expired refresh token");
        }
        
        String username = jwtService.extractUsername(refreshToken);
        String role = jwtService.extractRole(refreshToken);
        
        Credential credential = credentialRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));
                
        if (!credential.isEnabled()) {
            throw new RuntimeException("Account is disabled");
        }
        
        String newToken = jwtService.generateToken(username, role);
        String newRefreshToken = jwtService.generateRefreshToken(username, role);
        
        return new AuthResponse(newToken, newRefreshToken, username, role);
    }
    
    public ValidateResponse validateToken(String token) {
        if (blacklistService.isBlacklisted(token)) {
            return new ValidateResponse(false, null, null, "Token is blacklisted");
        }
        
        if (!jwtService.isTokenValid(token)) {
            return new ValidateResponse(false, null, null, "Token is invalid or expired");
        }
        
        String username = jwtService.extractUsername(token);
        String role = jwtService.extractRole(token);
        return new ValidateResponse(true, username, role, "Token is valid");
    }
    
    public Credential getCredentialByUsername(String username) {
        return credentialRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }
}
