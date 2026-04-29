package com.lms.auth.service;

import com.lms.auth.dto.*;
import com.lms.auth.entity.Credential;
import com.lms.auth.repository.CredentialRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {
    
    private final CredentialRepository credentialRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final BlacklistService blacklistService;
    
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
        // TODO: Call User Service to create profile via WebClient
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
