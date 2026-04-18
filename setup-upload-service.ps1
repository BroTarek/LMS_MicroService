# setup-upload-service.ps1
# Complete Upload Service setup

$serviceName = "upload-service"
$baseDir = $serviceName
$packagePath = "src/main/java/com/lms/upload"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Setting up Upload Service" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

# Create directory structure
$dirs = @(
    "$baseDir/$packagePath",
    "$baseDir/$packagePath/entity",
    "$baseDir/$packagePath/repository",
    "$baseDir/$packagePath/service",
    "$baseDir/$packagePath/controller",
    "$baseDir/$packagePath/dto",
    "$baseDir/$packagePath/config",
    "$baseDir/$packagePath/exception",
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
    <artifactId>upload-service</artifactId>
    <version>1.0.0</version>
    <name>upload-service</name>

    <properties>
        <java.version>17</java.version>
        <spring-cloud.version>2022.0.4</spring-cloud.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
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

# -------------------- application.properties --------------------
$appProps = @"
spring.application.name=upload-service
server.port=8084

# Eureka
eureka.client.service-url.defaultZone=http://localhost:8761/eureka
eureka.instance.prefer-ip-address=true

# Database
spring.datasource.url=jdbc:postgresql://localhost:5435/uploaddb
spring.datasource.username=postgres
spring.datasource.password=password
spring.jpa.hibernate.ddl-auto=update
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect

# File storage
file.upload-dir=./uploads

# Max file size (10MB)
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB

logging.level.com.lms.upload=DEBUG
"@
Write-File -relativePath "src/main/resources/application.properties" -content $appProps

# -------------------- Main Application --------------------
$mainApp = @"
package com.lms.upload;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication
@EnableDiscoveryClient
public class UploadServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(UploadServiceApplication.class, args);
    }
}
"@
Write-File -relativePath "$packagePath/UploadServiceApplication.java" -content $mainApp

# -------------------- Entity --------------------
$uploadedFileEntity = @"
package com.lms.upload.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "uploaded_files")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UploadedFile {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String fileName;
    
    @Column(nullable = false)
    private String filePath;
    
    @Column(name = "uploader_username", nullable = false)
    private String uploaderUsername;
    
    @Column(name = "uploaded_at")
    private LocalDateTime uploadedAt;
    
    @Column(name = "file_size")
    private Long fileSize;
    
    @Column(name = "mime_type")
    private String mimeType;
    
    @PrePersist
    protected void onCreate() {
        uploadedAt = LocalDateTime.now();
    }
}
"@
Write-File -relativePath "$packagePath/entity/UploadedFile.java" -content $uploadedFileEntity

# -------------------- Repository --------------------
$uploadRepository = @"
package com.lms.upload.repository;

import com.lms.upload.entity.UploadedFile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface UploadRepository extends JpaRepository<UploadedFile, Long> {
    List<UploadedFile> findByUploaderUsername(String username);
    Optional<UploadedFile> findByIdAndUploaderUsername(Long id, String username);
}
"@
Write-File -relativePath "$packagePath/repository/UploadRepository.java" -content $uploadRepository

# -------------------- DTOs --------------------
$uploadResponse = @"
package com.lms.upload.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UploadResponse {
    private Long id;
    private String fileName;
    private String url;
    private String uploadedAt;
    private Long fileSize;
    private String mimeType;
}
"@
Write-File -relativePath "$packagePath/dto/UploadResponse.java" -content $uploadResponse

# -------------------- Service: FileStorageService --------------------
$fileStorageService = @"
package com.lms.upload.service;

import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@Service
public class FileStorageService {
    
    @Value("\${file.upload-dir}")
    private String uploadDir;
    
    private Path fileStoragePath;
    
    @PostConstruct
    public void init() {
        try {
            this.fileStoragePath = Paths.get(uploadDir).toAbsolutePath().normalize();
            Files.createDirectories(this.fileStoragePath);
        } catch (IOException e) {
            throw new RuntimeException("Could not create upload directory", e);
        }
    }
    
    public String storeFile(MultipartFile file, String uploaderUsername) {
        try {
            // Generate unique filename to avoid collisions
            String originalFilename = file.getOriginalFilename();
            String fileExtension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String newFileName = UUID.randomUUID().toString() + fileExtension;
            
            Path targetPath = this.fileStoragePath.resolve(newFileName);
            Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);
            
            return targetPath.toString();
        } catch (IOException e) {
            throw new RuntimeException("Could not store file", e);
        }
    }
    
    public Resource loadFileAsResource(String filePath) {
        try {
            Path path = Paths.get(filePath).normalize();
            Resource resource = new UrlResource(path.toUri());
            if (resource.exists()) {
                return resource;
            } else {
                throw new RuntimeException("File not found: " + filePath);
            }
        } catch (MalformedURLException e) {
            throw new RuntimeException("File not found", e);
        }
    }
    
    public void deleteFile(String filePath) {
        try {
            Path path = Paths.get(filePath);
            Files.deleteIfExists(path);
        } catch (IOException e) {
            throw new RuntimeException("Could not delete file: " + filePath, e);
        }
    }
}
"@
Write-File -relativePath "$packagePath/service/FileStorageService.java" -content $fileStorageService

# -------------------- Service: UploadService --------------------
$uploadService = @"
package com.lms.upload.service;

import com.lms.upload.dto.UploadResponse;
import com.lms.upload.entity.UploadedFile;
import com.lms.upload.repository.UploadRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UploadService {
    
    private final UploadRepository uploadRepository;
    private final FileStorageService fileStorageService;
    private static final String BASE_URL = "http://localhost:8084/api/uploads/";
    
    @Transactional
    public UploadResponse saveFileMetadata(MultipartFile file, String uploaderUsername) {
        String filePath = fileStorageService.storeFile(file, uploaderUsername);
        
        UploadedFile uploadedFile = new UploadedFile();
        uploadedFile.setFileName(file.getOriginalFilename());
        uploadedFile.setFilePath(filePath);
        uploadedFile.setUploaderUsername(uploaderUsername);
        uploadedFile.setFileSize(file.getSize());
        uploadedFile.setMimeType(file.getContentType());
        
        UploadedFile saved = uploadRepository.save(uploadedFile);
        
        return mapToResponse(saved);
    }
    
    public List<UploadResponse> getUserUploads(String username) {
        return uploadRepository.findByUploaderUsername(username)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    public UploadedFile getUploadEntity(Long uploadId, String username) {
        return uploadRepository.findByIdAndUploaderUsername(uploadId, username)
                .orElseThrow(() -> new RuntimeException("Upload not found or not owned by user"));
    }
    
    @Transactional
    public void deleteUpload(Long uploadId, String username) {
        UploadedFile file = getUploadEntity(uploadId, username);
        fileStorageService.deleteFile(file.getFilePath());
        uploadRepository.delete(file);
    }
    
    private UploadResponse mapToResponse(UploadedFile file) {
        String formattedDate = file.getUploadedAt() != null ? 
                file.getUploadedAt().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME) : null;
        String downloadUrl = BASE_URL + file.getId() + "/download";
        return new UploadResponse(
                file.getId(),
                file.getFileName(),
                downloadUrl,
                formattedDate,
                file.getFileSize(),
                file.getMimeType()
        );
    }
}
"@
Write-File -relativePath "$packagePath/service/UploadService.java" -content $uploadService

# -------------------- Controller --------------------
$uploadController = @"
package com.lms.upload.controller;

import com.lms.upload.dto.UploadResponse;
import com.lms.upload.entity.UploadedFile;
import com.lms.upload.service.FileStorageService;
import com.lms.upload.service.UploadService;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/uploads")
@RequiredArgsConstructor
public class UploadController {
    
    private final UploadService uploadService;
    private final FileStorageService fileStorageService;
    
    @PostMapping
    public ResponseEntity<UploadResponse> uploadFile(@RequestParam("file") MultipartFile file,
                                                     @RequestHeader("X-Username") String username) {
        return ResponseEntity.ok(uploadService.saveFileMetadata(file, username));
    }
    
    @GetMapping
    public ResponseEntity<List<UploadResponse>> getUserUploads(@RequestHeader("X-Username") String username) {
        return ResponseEntity.ok(uploadService.getUserUploads(username));
    }
    
    @GetMapping("/{uploadId}/download")
    public ResponseEntity<Resource> downloadFile(@PathVariable Long uploadId,
                                                 @RequestHeader("X-Username") String username) {
        UploadedFile file = uploadService.getUploadEntity(uploadId, username);
        Resource resource = fileStorageService.loadFileAsResource(file.getFilePath());
        
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(file.getMimeType()))
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + file.getFileName() + "\"")
                .body(resource);
    }
    
    @DeleteMapping("/{uploadId}")
    public ResponseEntity<Void> deleteFile(@PathVariable Long uploadId,
                                          @RequestHeader("X-Username") String username) {
        uploadService.deleteUpload(uploadId, username);
        return ResponseEntity.ok().build();
    }
}
"@
Write-File -relativePath "$packagePath/controller/UploadController.java" -content $uploadController

# -------------------- Security Config (simple, rely on gateway) --------------------
$securityConfig = @"
package com.lms.upload.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .anyRequest().authenticated()
            );
        return http.build();
    }
}
"@
Write-File -relativePath "$packagePath/config/SecurityConfig.java" -content $securityConfig

# -------------------- Global Exception Handler --------------------
$exceptionHandler = @"
package com.lms.upload.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<Map<String, String>> handleRuntimeException(RuntimeException ex) {
        Map<String, String> error = new HashMap<>();
        error.put("error", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }
    
    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public ResponseEntity<Map<String, String>> handleMaxSizeException(MaxUploadSizeExceededException ex) {
        Map<String, String> error = new HashMap<>();
        error.put("error", "File size exceeds maximum allowed (10MB)");
        return ResponseEntity.status(HttpStatus.PAYLOAD_TOO_LARGE).body(error);
    }
}
"@
Write-File -relativePath "$packagePath/exception/GlobalExceptionHandler.java" -content $exceptionHandler

# -------------------- Dockerfile --------------------
$dockerfile = @"
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8084
ENTRYPOINT ["java", "-jar", "app.jar"]
"@
Write-File -relativePath "Dockerfile" -content $dockerfile

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Upload Service setup complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Directory: $baseDir" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. cd $baseDir" -ForegroundColor White
Write-Host "2. Run 'mvn clean install' to build" -ForegroundColor White
Write-Host "3. Run 'docker build -t upload-service .' to build Docker image" -ForegroundColor White
Write-Host "4. Or run locally with 'mvn spring-boot:run'" -ForegroundColor White
Write-Host ""
Write-Host "The service will start on port 8084" -ForegroundColor Green
Write-Host "Endpoints:" -ForegroundColor Cyan
Write-Host "  - POST /api/uploads (upload file, requires X-Username header)" -ForegroundColor Gray
Write-Host "  - GET /api/uploads (list user's uploads)" -ForegroundColor Gray
Write-Host "  - GET /api/uploads/{uploadId}/download (download file)" -ForegroundColor Gray
Write-Host "  - DELETE /api/uploads/{uploadId} (delete file)" -ForegroundColor Gray
Write-Host ""
Write-Host "Files are stored in ./uploads directory (configurable via file.upload-dir)" -ForegroundColor Yellow
Write-Host "Max file size: 10MB (configurable)" -ForegroundColor Yellow