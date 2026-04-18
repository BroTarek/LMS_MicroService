package com.lms.gateway.filter;

import com.lms.gateway.dto.ValidateResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Component
@RequiredArgsConstructor
@Slf4j
public class AuthServiceClient {
    
    private final WebClient.Builder webClientBuilder;
    
    @Value("\")
    private String eurekaUrl;
    
    public Mono<ValidateResponse> validateToken(String token) {
        // Use service discovery via load-balanced WebClient
        WebClient webClient = webClientBuilder.build();
        
        return webClient
            .get()
            .uri("http://AUTH-SERVICE/auth/validate")
            .header("Authorization", "Bearer " + token)
            .retrieve()
            .bodyToMono(ValidateResponse.class)
            .onErrorResume(e -> {
                log.error("Error calling auth service: {}", e.getMessage());
                ValidateResponse errorResponse = new ValidateResponse(false, null, null, "Auth service unavailable");
                return Mono.just(errorResponse);
            });
    }
}
