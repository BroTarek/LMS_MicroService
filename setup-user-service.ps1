# setup-user-service.ps1
# Complete User Service setup

$serviceName = "user-service"
$baseDir = $serviceName
$packagePath = "src/main/java/com/lms/user"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Setting up User Service" -ForegroundColor Green
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
    "$baseDir/$packagePath/client",
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
    <artifactId>user-service</artifactId>
    <version>1.0.0</version>
    <name>user-service</name>

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
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-openfeign</artifactId>
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
spring.application.name=user-service
server.port=8082

# Eureka
eureka.client.service-url.defaultZone=http://localhost:8761/eureka
eureka.instance.prefer-ip-address=true

# Database
spring.datasource.url=jdbc:postgresql://localhost:5433/userdb
spring.datasource.username=postgres
spring.datasource.password=password
spring.jpa.hibernate.ddl-auto=update
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect

# Feign
feign.client.config.default.connectTimeout=5000
feign.client.config.default.readTimeout=5000

logging.level.com.lms.user=DEBUG
"@
Write-File -relativePath "src/main/resources/application.properties" -content $appProps

# -------------------- Main Application --------------------
$mainApp = @"
package com.lms.user;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients
public class UserServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(UserServiceApplication.class, args);
    }
}
"@
Write-File -relativePath "$packagePath/UserServiceApplication.java" -content $mainApp

# -------------------- Entities --------------------
# UserProfile entity
$userProfileEntity = @"
package com.lms.user.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_profiles")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserProfile {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String username;
    
    @Column(nullable = false)
    private String fullName;
    
    @Column(nullable = false, unique = true)
    private String email;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
"@
Write-File -relativePath "$packagePath/entity/UserProfile.java" -content $userProfileEntity

# Teacher entity
$teacherEntity = @"
package com.lms.user.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Entity
@Table(name = "teachers")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Teacher {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @OneToOne
    @JoinColumn(name = "user_profile_id", unique = true)
    private UserProfile userProfile;
    
    private String department;
    private String title;
}
"@
Write-File -relativePath "$packagePath/entity/Teacher.java" -content $teacherEntity

# Student entity
$studentEntity = @"
package com.lms.user.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Entity
@Table(name = "students")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Student {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @OneToOne
    @JoinColumn(name = "user_profile_id", unique = true)
    private UserProfile userProfile;
    
    @Column(name = "grade_level")
    private String gradeLevel;
    
    private String major;
}
"@
Write-File -relativePath "$packagePath/entity/Student.java" -content $studentEntity

# -------------------- Repositories --------------------
$userProfileRepo = @"
package com.lms.user.repository;

import com.lms.user.entity.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface UserProfileRepository extends JpaRepository<UserProfile, Long> {
    Optional<UserProfile> findByUsername(String username);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
}
"@
Write-File -relativePath "$packagePath/repository/UserProfileRepository.java" -content $userProfileRepo

$teacherRepo = @"
package com.lms.user.repository;

import com.lms.user.entity.Teacher;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface TeacherRepository extends JpaRepository<Teacher, Long> {
    Optional<Teacher> findByUserProfileUsername(String username);
}
"@
Write-File -relativePath "$packagePath/repository/TeacherRepository.java" -content $teacherRepo

$studentRepo = @"
package com.lms.user.repository;

import com.lms.user.entity.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface StudentRepository extends JpaRepository<Student, Long> {
    Optional<Student> findByUserProfileUsername(String username);
}
"@
Write-File -relativePath "$packagePath/repository/StudentRepository.java" -content $studentRepo

# -------------------- Feign Client (Course Service) --------------------
$courseServiceClient = @"
package com.lms.user.client;

import com.lms.user.dto.CourseSummary;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import java.util.List;

@FeignClient(name = "COURSE-SERVICE")
public interface CourseServiceClient {
    
    @GetMapping("/api/courses/teacher/{username}")
    List<CourseSummary> getCoursesByTeacher(@PathVariable("username") String username);
    
    @GetMapping("/api/courses/student/{username}")
    List<CourseSummary> getCoursesByStudent(@PathVariable("username") String username);
}
"@
Write-File -relativePath "$packagePath/client/CourseServiceClient.java" -content $courseServiceClient

# -------------------- DTOs --------------------
$userProfileResponse = @"
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
}
"@
Write-File -relativePath "$packagePath/dto/UserProfileResponse.java" -content $userProfileResponse

$userProfileUpdateRequest = @"
package com.lms.user.dto;

import lombok.Data;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

@Data
public class UserProfileUpdateRequest {
    @NotBlank
    private String fullName;
    
    @NotBlank
    @Email
    private String email;
}
"@
Write-File -relativePath "$packagePath/dto/UserProfileUpdateRequest.java" -content $userProfileUpdateRequest

$internalCreateUserRequest = @"
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
"@
Write-File -relativePath "$packagePath/dto/InternalCreateUserRequest.java" -content $internalCreateUserRequest

$courseSummary = @"
package com.lms.user.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CourseSummary {
    private Long id;
    private String title;
    private String teacherName;
}
"@
Write-File -relativePath "$packagePath/dto/CourseSummary.java" -content $courseSummary

# -------------------- Service --------------------
$userProfileService = @"
package com.lms.user.service;

import com.lms.user.dto.UserProfileUpdateRequest;
import com.lms.user.entity.*;
import com.lms.user.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserProfileService {
    
    private final UserProfileRepository userProfileRepository;
    private final TeacherRepository teacherRepository;
    private final StudentRepository studentRepository;
    
    @Transactional
    public UserProfile createProfile(String username, String fullName, String email) {
        if (userProfileRepository.existsByUsername(username)) {
            throw new RuntimeException("Profile already exists for username: " + username);
        }
        if (userProfileRepository.existsByEmail(email)) {
            throw new RuntimeException("Email already in use: " + email);
        }
        UserProfile profile = new UserProfile();
        profile.setUsername(username);
        profile.setFullName(fullName);
        profile.setEmail(email);
        return userProfileRepository.save(profile);
    }
    
    @Transactional
    public Teacher createTeacherProfile(String username, String department, String title) {
        UserProfile profile = userProfileRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("UserProfile not found for username: " + username));
        Teacher teacher = new Teacher();
        teacher.setUserProfile(profile);
        teacher.setDepartment(department);
        teacher.setTitle(title);
        return teacherRepository.save(teacher);
    }
    
    @Transactional
    public Student createStudentProfile(String username, String gradeLevel, String major) {
        UserProfile profile = userProfileRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("UserProfile not found for username: " + username));
        Student student = new Student();
        student.setUserProfile(profile);
        student.setGradeLevel(gradeLevel);
        student.setMajor(major);
        return studentRepository.save(student);
    }
    
    public UserProfile getProfile(String username) {
        return userProfileRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found: " + username));
    }
    
    @Transactional
    public UserProfile updateProfile(String username, UserProfileUpdateRequest request) {
        UserProfile profile = getProfile(username);
        profile.setFullName(request.getFullName());
        profile.setEmail(request.getEmail());
        return userProfileRepository.save(profile);
    }
    
    public String getUserRole(String username) {
        if (teacherRepository.findByUserProfileUsername(username).isPresent()) {
            return "TEACHER";
        } else if (studentRepository.findByUserProfileUsername(username).isPresent()) {
            return "STUDENT";
        }
        throw new RuntimeException("Role not found for user: " + username);
    }
}
"@
Write-File -relativePath "$packagePath/service/UserProfileService.java" -content $userProfileService

# -------------------- Controllers --------------------
# Internal controller (for Auth Service)
$internalUserController = @"
package com.lms.user.controller;

import com.lms.user.dto.InternalCreateUserRequest;
import com.lms.user.service.UserProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/internal/users")
@RequiredArgsConstructor
public class InternalUserController {
    
    private final UserProfileService userProfileService;
    
    @PostMapping
    public ResponseEntity<Void> createUserFromAuth(@RequestBody InternalCreateUserRequest request) {
        userProfileService.createProfile(request.getUsername(), request.getFullName(), request.getEmail());
        if ("TEACHER".equalsIgnoreCase(request.getRole())) {
            userProfileService.createTeacherProfile(request.getUsername(), "Pending", "Pending");
        } else {
            userProfileService.createStudentProfile(request.getUsername(), "Pending", "Pending");
        }
        return ResponseEntity.ok().build();
    }
}
"@
Write-File -relativePath "$packagePath/controller/InternalUserController.java" -content $internalUserController

# UserController (public)
$userController = @"
package com.lms.user.controller;

import com.lms.user.dto.UserProfileResponse;
import com.lms.user.dto.UserProfileUpdateRequest;
import com.lms.user.entity.UserProfile;
import com.lms.user.service.UserProfileService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    
    private final UserProfileService userProfileService;
    
    @GetMapping("/me")
    public ResponseEntity<UserProfileResponse> getMyProfile(@RequestHeader("X-Username") String username) {
        UserProfile profile = userProfileService.getProfile(username);
        String role = userProfileService.getUserRole(username);
        UserProfileResponse response = new UserProfileResponse(
            profile.getUsername(), profile.getFullName(), profile.getEmail(), role
        );
        return ResponseEntity.ok(response);
    }
    
    @PutMapping("/me")
    public ResponseEntity<UserProfileResponse> updateMyProfile(
            @Valid @RequestBody UserProfileUpdateRequest request,
            @RequestHeader("X-Username") String username) {
        UserProfile profile = userProfileService.updateProfile(username, request);
        String role = userProfileService.getUserRole(username);
        UserProfileResponse response = new UserProfileResponse(
            profile.getUsername(), profile.getFullName(), profile.getEmail(), role
        );
        return ResponseEntity.ok(response);
    }
}
"@
Write-File -relativePath "$packagePath/controller/UserController.java" -content $userController

# TeacherController
$teacherController = @"
package com.lms.user.controller;

import com.lms.user.client.CourseServiceClient;
import com.lms.user.dto.CourseSummary;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/teachers")
@RequiredArgsConstructor
public class TeacherController {
    
    private final CourseServiceClient courseServiceClient;
    
    @GetMapping("/my-courses")
    public ResponseEntity<List<CourseSummary>> getMyCourses(@RequestHeader("X-Username") String username) {
        List<CourseSummary> courses = courseServiceClient.getCoursesByTeacher(username);
        return ResponseEntity.ok(courses);
    }
}
"@
Write-File -relativePath "$packagePath/controller/TeacherController.java" -content $teacherController

# StudentController
$studentController = @"
package com.lms.user.controller;

import com.lms.user.client.CourseServiceClient;
import com.lms.user.dto.CourseSummary;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/students")
@RequiredArgsConstructor
public class StudentController {
    
    private final CourseServiceClient courseServiceClient;
    
    @GetMapping("/my-courses")
    public ResponseEntity<List<CourseSummary>> getMyCourses(@RequestHeader("X-Username") String username) {
        List<CourseSummary> courses = courseServiceClient.getCoursesByStudent(username);
        return ResponseEntity.ok(courses);
    }
}
"@
Write-File -relativePath "$packagePath/controller/StudentController.java" -content $studentController

# -------------------- Security Config (simple, rely on gateway) --------------------
$securityConfig = @"
package com.lms.user.config;

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
                .requestMatchers("/internal/**").permitAll()
                .anyRequest().authenticated()
            );
        return http.build();
    }
}
"@
Write-File -relativePath "$packagePath/config/SecurityConfig.java" -content $securityConfig

# -------------------- Global Exception Handler --------------------
$exceptionHandler = @"
package com.lms.user.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
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
}
"@
Write-File -relativePath "$packagePath/exception/GlobalExceptionHandler.java" -content $exceptionHandler

# -------------------- Dockerfile --------------------
$dockerfile = @"
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8082
ENTRYPOINT ["java", "-jar", "app.jar"]
"@
Write-File -relativePath "Dockerfile" -content $dockerfile

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "User Service setup complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Directory: $baseDir" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. cd $baseDir" -ForegroundColor White
Write-Host "2. Run 'mvn clean install' to build" -ForegroundColor White
Write-Host "3. Run 'docker build -t user-service .' to build Docker image" -ForegroundColor White
Write-Host "4. Or run locally with 'mvn spring-boot:run'" -ForegroundColor White
Write-Host ""
Write-Host "The service will start on port 8082" -ForegroundColor Green
Write-Host "Endpoints:" -ForegroundColor Cyan
Write-Host "  - GET /api/users/me (requires X-Username header from gateway)" -ForegroundColor Gray
Write-Host "  - PUT /api/users/me" -ForegroundColor Gray
Write-Host "  - GET /api/teachers/my-courses" -ForegroundColor Gray
Write-Host "  - GET /api/students/my-courses" -ForegroundColor Gray
Write-Host "  - POST /internal/users (internal, no auth)" -ForegroundColor Gray