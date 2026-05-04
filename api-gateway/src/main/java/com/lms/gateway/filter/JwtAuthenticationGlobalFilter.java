package com.lms.gateway.filter;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.List;

@Component
@RequiredArgsConstructor
@Slf4j
public class JwtAuthenticationGlobalFilter implements GlobalFilter, Ordered {
    
    private final AuthServiceClient authServiceClient;
    
    private static final List<String> PUBLIC_PATHS = List.of(
        "/auth/register",
        "/auth/login",
        "/auth/refresh",
        "/auth/logout",
        "/auth/validate"
    );
    
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String path = exchange.getRequest().getURI().getPath();
        HttpMethod method = exchange.getRequest().getMethod();
        
        // Skip authentication for public paths and public GET requests
        if (isPublicPath(path, method)) {
            return chain.filter(exchange);
        }
        
        // Extract JWT token from Authorization header
        String authHeader = exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            log.warn("Missing or invalid Authorization header for path: {}", path);
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }
        
        String token = authHeader.substring(7).trim();
        
        // Validate token with Auth Service
        return authServiceClient.validateToken(token)
            .flatMap(response -> {
                if (response.isValid()) {
                    // Add user context to downstream request headers
                    ServerHttpRequest mutatedRequest = exchange.getRequest().mutate()
                        .header("X-Username", response.getUsername())
                        .header("X-Role", response.getRole())
                        .build();
                    
                    ServerWebExchange mutatedExchange = exchange.mutate()
                        .request(mutatedRequest)
                        .build();
                    
                    return chain.filter(mutatedExchange);
                } else {
                    log.warn("Invalid token for path {}: {}", path, response.getMessage());
                    exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
                    return exchange.getResponse().setComplete();
                }
            });
    }
    
    private boolean isPublicPath(String path, HttpMethod method) {
        // Auth endpoints are always public
        if (PUBLIC_PATHS.stream().anyMatch(path::startsWith)) {
            return true;
        }
        
        // Public GET endpoints
        if (method == HttpMethod.GET) {
            // "/api/courses/my" is NOT public, but other /api/courses/** are
            if (path.equals("/api/courses/my") || path.equals("/api/enrollments/my-courses")) {
                return false;
            }
            return path.startsWith("/api/courses") || 
                   path.startsWith("/api/lessons");
        }
        
        return false;
    }
    
    @Override
    public int getOrder() {
        return -100; // Run before other filters
    }
}
