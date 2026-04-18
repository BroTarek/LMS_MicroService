# setup-api-gateway.ps1
# Complete API Gateway Service setup

$serviceName = "api-gateway"
$baseDir = $serviceName
$packagePath = "src/main/java/com/lms/gateway"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Setting up API Gateway Service" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

# Create directory structure
$dirs = @(
    "$baseDir/$packagePath",
    "$baseDir/$packagePath/config",
    "$baseDir/$packagePath/filter",
    "$baseDir/src/main/resources"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Write-Host "Created: $dir" -ForegroundColor Gray
}

# Function to write file content
function Write-File {
    param($relativePath, $content)
    $fullPath = Join-Path $baseDir $relativePath
    Set-Content -Path $fullPath -Value $content -Encoding UTF8
    Write-Host "  Written: $relativePath" -ForegroundColor Green
}

# -------------------- pom.xml --------------------
$pomContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.1.5</version>
        <relativePath/>
    </parent>

    <groupId>com.lms</groupId>
    <artifactId>api-gateway</artifactId>
    <version>1.0.0</version>
    <name>api-gateway</name>

    <properties>
        <java.version>17</java.version>
        <spring-cloud.version>2022.0.4</spring-cloud.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-gateway</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-webflux</artifactId>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>\${spring-cloud.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <excludes>
                        <exclude>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
"@
Write-File -relativePath "pom.xml" -content $pomContent

# -------------------- application.yml --------------------
$appYaml = @"
spring:
  application:
    name: api-gateway
  cloud:
    gateway:
      routes:
        - id: auth-service
          uri: lb://AUTH-SERVICE
          predicates:
            - Path=/auth/**
        - id: user-service
          uri: lb://USER-SERVICE
          predicates:
            - Path=/api/users/**,/internal/users/**
        - id: course-service
          uri: lb://COURSE-SERVICE
          predicates:
            - Path=/api/courses/**,/api/enrollments/**,/api/lessons/**
        - id: upload-service
          uri: lb://UPLOAD-SERVICE
          predicates:
            - Path=/api/uploads/**

server:
  port: 8080

eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka
  instance:
    prefer-ip-address: true

logging:
  level:
    com.lms.gateway: DEBUG
    org.springframework.cloud.gateway: TRACE
"@
Write-File -relativePath "src/main/resources/application.yml" -content $appYaml

# -------------------- Main Application --------------------
$mainApp = @"
package com.lms.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication
@EnableDiscoveryClient
public class ApiGatewayApplication {
    public static void main(String[] args) {
        SpringApplication.run(ApiGatewayApplication.class, args);
    }
}
"@
Write-File -relativePath "$packagePath/ApiGatewayApplication.java" -content $mainApp

# -------------------- WebClient Config (for calling Auth Service) --------------------
$webClientConfig = @"
package com.lms.gateway.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
public class WebClientConfig {
    
    @Bean
    public WebClient.Builder webClientBuilder() {
        return WebClient.builder();
    }
}
"@
Write-File -relativePath "$packagePath/config/WebClientConfig.java" -content $webClientConfig

# -------------------- Auth Service Client --------------------
$authClient = @"
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
    
    @Value("\${eureka.client.service-url.defaultZone}")
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
"@
Write-File -relativePath "$packagePath/filter/AuthServiceClient.java" -content $authClient

# -------------------- ValidateResponse DTO --------------------
$validateResponseDto = @"
package com.lms.gateway.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ValidateResponse {
    private boolean valid;
    private String username;
    private String role;
    private String message;
}
"@
Write-File -relativePath "$packagePath/dto/ValidateResponse.java" -content $validateResponseDto

# Create DTO directory
New-Item -ItemType Directory -Force -Path "$baseDir/$packagePath/dto" | Out-Null

# -------------------- JwtAuthenticationGlobalFilter --------------------
$globalFilter = @"
package com.lms.gateway.filter;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
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
    
    // Paths that don't require authentication
    private static final List<String> PUBLIC_PATHS = List.of(
        "/auth/register",
        "/auth/login"
    );
    
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String path = exchange.getRequest().getURI().getPath();
        
        // Skip authentication for public paths
        if (isPublicPath(path)) {
            return chain.filter(exchange);
        }
        
        // Extract JWT token from Authorization header
        String authHeader = exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            log.warn("Missing or invalid Authorization header for path: {}", path);
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }
        
        String token = authHeader.substring(7);
        
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
    
    private boolean isPublicPath(String path) {
        return PUBLIC_PATHS.stream().anyMatch(path::startsWith);
    }
    
    @Override
    public int getOrder() {
        return -100; // Run before other filters
    }
}
"@
Write-File -relativePath "$packagePath/filter/JwtAuthenticationGlobalFilter.java" -content $globalFilter

# -------------------- Dockerfile --------------------
$dockerfile = @"
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
"@
Write-File -relativePath "Dockerfile" -content $dockerfile

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "API Gateway setup complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Directory: $baseDir" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. cd $baseDir" -ForegroundColor White
Write-Host "2. Run 'mvn clean install' to build" -ForegroundColor White
Write-Host "3. Run 'docker build -t api-gateway .' to build Docker image" -ForegroundColor White
Write-Host "4. Or run locally with 'mvn spring-boot:run'" -ForegroundColor White
Write-Host ""
Write-Host "The gateway will start on port 8080 and route requests to services via Eureka." -ForegroundColor Green
Write-Host "Public endpoints (no auth): /auth/register, /auth/login" -ForegroundColor Cyan
Write-Host "All other endpoints require a valid JWT token in Authorization header." -ForegroundColor Cyan