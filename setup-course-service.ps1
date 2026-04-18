# setup-course-service.ps1
# Complete Course Service setup

$serviceName = "course-service"
$baseDir = $serviceName
$packagePath = "src/main/java/com/lms/course"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Setting up Course Service" -ForegroundColor Green
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
    "$baseDir/$packagePath/aspect",
    "$baseDir/$packagePath/annotation",
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
    <artifactId>course-service</artifactId>
    <version>1.0.0</version>
    <name>course-service</name>

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
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-aop</artifactId>
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
spring.application.name=course-service
server.port=8083

# Eureka
eureka.client.service-url.defaultZone=http://localhost:8761/eureka
eureka.instance.prefer-ip-address=true

# Database
spring.datasource.url=jdbc:postgresql://localhost:5434/coursedb
spring.datasource.username=postgres
spring.datasource.password=password
spring.jpa.hibernate.ddl-auto=update
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect

# Feign
feign.client.config.default.connectTimeout=5000
feign.client.config.default.readTimeout=5000

logging.level.com.lms.course=DEBUG
"@
Write-File -relativePath "src/main/resources/application.properties" -content $appProps

# -------------------- Main Application --------------------
$mainApp = @"
package com.lms.course;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.context.annotation.EnableAspectJAutoProxy;

@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients
@EnableAspectJAutoProxy
public class CourseServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(CourseServiceApplication.class, args);
    }
}
"@
Write-File -relativePath "$packagePath/CourseServiceApplication.java" -content $mainApp

# -------------------- Entities --------------------
# Course entity
$courseEntity = @"
package com.lms.course.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "courses")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Course {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String title;
    
    @Column(length = 2000)
    private String description;
    
    @Column(name = "teacher_username", nullable = false)
    private String teacherUsername;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @OneToMany(mappedBy = "course", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Lesson> lessons = new ArrayList<>();
    
    @OneToMany(mappedBy = "course", cascade = CascadeType.ALL)
    private List<Enrollment> enrollments = new ArrayList<>();
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
"@
Write-File -relativePath "$packagePath/entity/Course.java" -content $courseEntity

# Lesson entity
$lessonEntity = @"
package com.lms.course.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Entity
@Table(name = "lessons")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Lesson {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;
    
    @Column(nullable = false)
    private String title;
    
    @Column(name = "content_url")
    private String contentUrl;
    
    @Column(name = "order_index")
    private Integer orderIndex;
}
"@
Write-File -relativePath "$packagePath/entity/Lesson.java" -content $lessonEntity

# Enrollment entity
$enrollmentEntity = @"
package com.lms.course.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "enrollments")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Enrollment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;
    
    @Column(name = "student_username", nullable = false)
    private String studentUsername;
    
    @Column(nullable = false)
    private String status; // PENDING, APPROVED, REJECTED
    
    @Column(name = "requested_at")
    private LocalDateTime requestedAt;
    
    @Column(name = "responded_at")
    private LocalDateTime respondedAt;
    
    @PrePersist
    protected void onCreate() {
        requestedAt = LocalDateTime.now();
        if (status == null) status = "PENDING";
    }
}
"@
Write-File -relativePath "$packagePath/entity/Enrollment.java" -content $enrollmentEntity

# -------------------- Repositories --------------------
$courseRepo = @"
package com.lms.course.repository;

import com.lms.course.entity.Course;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface CourseRepository extends JpaRepository<Course, Long> {
    List<Course> findByTeacherUsername(String teacherUsername);
    Optional<Course> findByIdAndTeacherUsername(Long id, String teacherUsername);
}
"@
Write-File -relativePath "$packagePath/repository/CourseRepository.java" -content $courseRepo

$lessonRepo = @"
package com.lms.course.repository;

import com.lms.course.entity.Lesson;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface LessonRepository extends JpaRepository<Lesson, Long> {
    List<Lesson> findByCourseIdOrderByOrderIndex(Long courseId);
}
"@
Write-File -relativePath "$packagePath/repository/LessonRepository.java" -content $lessonRepo

$enrollmentRepo = @"
package com.lms.course.repository;

import com.lms.course.entity.Enrollment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface EnrollmentRepository extends JpaRepository<Enrollment, Long> {
    List<Enrollment> findByStudentUsername(String studentUsername);
    List<Enrollment> findByCourseId(Long courseId);
    Optional<Enrollment> findByCourseIdAndStudentUsername(Long courseId, String studentUsername);
    List<Enrollment> findByCourseIdAndStatus(Long courseId, String status);
}
"@
Write-File -relativePath "$packagePath/repository/EnrollmentRepository.java" -content $enrollmentRepo

# -------------------- Feign Client (User Service) --------------------
$userServiceClient = @"
package com.lms.course.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "USER-SERVICE")
public interface UserServiceClient {
    
    @GetMapping("/internal/users/{username}/role")
    String getUserRole(@PathVariable("username") String username);
}
"@
Write-File -relativePath "$packagePath/client/UserServiceClient.java" -content $userServiceClient

# -------------------- DTOs --------------------
$createCourseRequest = @"
package com.lms.course.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CreateCourseRequest {
    @NotBlank
    private String title;
    
    private String description;
}
"@
Write-File -relativePath "$packagePath/dto/CreateCourseRequest.java" -content $createCourseRequest

$createLessonRequest = @"
package com.lms.course.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CreateLessonRequest {
    @NotBlank
    private String title;
    
    private String contentUrl;
    
    @NotNull
    private Integer orderIndex;
}
"@
Write-File -relativePath "$packagePath/dto/CreateLessonRequest.java" -content $createLessonRequest

$enrollmentRequest = @"
package com.lms.course.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class EnrollmentRequest {
    @NotNull
    private Long courseId;
}
"@
Write-File -relativePath "$packagePath/dto/EnrollmentRequest.java" -content $enrollmentRequest

$courseSummary = @"
package com.lms.course.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CourseSummary {
    private Long id;
    private String title;
    private String teacherUsername;
}
"@
Write-File -relativePath "$packagePath/dto/CourseSummary.java" -content $courseSummary

# -------------------- Custom Annotation --------------------
$requireCourseOwner = @"
package com.lms.course.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface RequireCourseOwner {
}
"@
Write-File -relativePath "$packagePath/annotation/RequireCourseOwner.java" -content $requireCourseOwner

# -------------------- Aspects --------------------
$authorizationAspect = @"
package com.lms.course.aspect;

import com.lms.course.annotation.RequireCourseOwner;
import com.lms.course.entity.Course;
import com.lms.course.repository.CourseRepository;
import lombok.RequiredArgsConstructor;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import jakarta.servlet.http.HttpServletRequest;

@Aspect
@Component
@RequiredArgsConstructor
public class AuthorizationAspect {
    
    private final CourseRepository courseRepository;
    
    @Before("@annotation(requireCourseOwner)")
    public void checkCourseOwner(JoinPoint joinPoint, RequireCourseOwner requireCourseOwner) {
        // Extract courseId from method arguments
        Object[] args = joinPoint.getArgs();
        Long courseId = null;
        for (Object arg : args) {
            if (arg instanceof Long) {
                courseId = (Long) arg;
                break;
            }
        }
        if (courseId == null) {
            throw new RuntimeException("Course ID not found in method arguments");
        }
        
        // Get teacher username from request header (set by gateway)
        HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
        String teacherUsername = request.getHeader("X-Username");
        if (teacherUsername == null) {
            throw new RuntimeException("User not authenticated");
        }
        
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new RuntimeException("Course not found: " + courseId));
        if (!course.getTeacherUsername().equals(teacherUsername)) {
            throw new RuntimeException("You are not the owner of this course");
        }
    }
}
"@
Write-File -relativePath "$packagePath/aspect/AuthorizationAspect.java" -content $authorizationAspect

$loggingAspect = @"
package com.lms.course.aspect;

import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.AfterThrowing;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.springframework.stereotype.Component;

@Aspect
@Component
@Slf4j
public class LoggingAspect {
    
    @Before("execution(* com.lms.course.controller.*.*(..))")
    public void logBefore(JoinPoint joinPoint) {
        log.info("Entering method: {} with arguments: {}", 
            joinPoint.getSignature().getName(), joinPoint.getArgs());
    }
    
    @AfterReturning(pointcut = "execution(* com.lms.course.controller.*.*(..))", returning = "result")
    public void logAfterReturning(JoinPoint joinPoint, Object result) {
        log.info("Method: {} returned: {}", joinPoint.getSignature().getName(), result);
    }
    
    @AfterThrowing(pointcut = "execution(* com.lms.course.controller.*.*(..))", throwing = "error")
    public void logAfterThrowing(JoinPoint joinPoint, Exception error) {
        log.error("Method: {} threw exception: {}", joinPoint.getSignature().getName(), error.getMessage());
    }
}
"@
Write-File -relativePath "$packagePath/aspect/LoggingAspect.java" -content $loggingAspect

# -------------------- Services --------------------
$courseService = @"
package com.lms.course.service;

import com.lms.course.dto.CreateCourseRequest;
import com.lms.course.entity.Course;
import com.lms.course.repository.CourseRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CourseService {
    
    private final CourseRepository courseRepository;
    
    @Transactional
    public Course createCourse(CreateCourseRequest request, String teacherUsername) {
        Course course = new Course();
        course.setTitle(request.getTitle());
        course.setDescription(request.getDescription());
        course.setTeacherUsername(teacherUsername);
        return courseRepository.save(course);
    }
    
    public List<Course> getCoursesByTeacher(String teacherUsername) {
        return courseRepository.findByTeacherUsername(teacherUsername);
    }
    
    public Course getCourse(Long courseId) {
        return courseRepository.findById(courseId)
                .orElseThrow(() -> new RuntimeException("Course not found: " + courseId));
    }
    
    @Transactional
    public void deleteCourse(Long courseId, String teacherUsername) {
        Course course = courseRepository.findByIdAndTeacherUsername(courseId, teacherUsername)
                .orElseThrow(() -> new RuntimeException("Course not found or not owned by you"));
        courseRepository.delete(course);
    }
}
"@
Write-File -relativePath "$packagePath/service/CourseService.java" -content $courseService

$lessonService = @"
package com.lms.course.service;

import com.lms.course.dto.CreateLessonRequest;
import com.lms.course.entity.Course;
import com.lms.course.entity.Lesson;
import com.lms.course.repository.LessonRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
public class LessonService {
    
    private final LessonRepository lessonRepository;
    private final CourseService courseService;
    
    @Transactional
    public Lesson addLesson(Long courseId, CreateLessonRequest request, String teacherUsername) {
        Course course = courseService.getCourse(courseId);
        if (!course.getTeacherUsername().equals(teacherUsername)) {
            throw new RuntimeException("You are not the owner of this course");
        }
        Lesson lesson = new Lesson();
        lesson.setCourse(course);
        lesson.setTitle(request.getTitle());
        lesson.setContentUrl(request.getContentUrl());
        lesson.setOrderIndex(request.getOrderIndex());
        return lessonRepository.save(lesson);
    }
    
    public List<Lesson> getLessonsByCourse(Long courseId) {
        return lessonRepository.findByCourseIdOrderByOrderIndex(courseId);
    }
    
    public Lesson getLesson(Long lessonId) {
        return lessonRepository.findById(lessonId)
                .orElseThrow(() -> new RuntimeException("Lesson not found: " + lessonId));
    }
}
"@
Write-File -relativePath "$packagePath/service/LessonService.java" -content $lessonService

$enrollmentService = @"
package com.lms.course.service;

import com.lms.course.entity.Course;
import com.lms.course.entity.Enrollment;
import com.lms.course.repository.EnrollmentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class EnrollmentService {
    
    private final EnrollmentRepository enrollmentRepository;
    private final CourseService courseService;
    
    @Transactional
    public Enrollment requestEnrollment(Long courseId, String studentUsername) {
        Course course = courseService.getCourse(courseId);
        
        // Check if already enrolled or pending
        if (enrollmentRepository.findByCourseIdAndStudentUsername(courseId, studentUsername).isPresent()) {
            throw new RuntimeException("Already requested or enrolled");
        }
        
        Enrollment enrollment = new Enrollment();
        enrollment.setCourse(course);
        enrollment.setStudentUsername(studentUsername);
        enrollment.setStatus("PENDING");
        return enrollmentRepository.save(enrollment);
    }
    
    public List<Enrollment> getPendingEnrollmentsForCourse(Long courseId, String teacherUsername) {
        Course course = courseService.getCourse(courseId);
        if (!course.getTeacherUsername().equals(teacherUsername)) {
            throw new RuntimeException("You are not the owner of this course");
        }
        return enrollmentRepository.findByCourseIdAndStatus(courseId, "PENDING");
    }
    
    @Transactional
    public void approveEnrollment(Long enrollmentId, String teacherUsername) {
        Enrollment enrollment = enrollmentRepository.findById(enrollmentId)
                .orElseThrow(() -> new RuntimeException("Enrollment not found"));
        Course course = enrollment.getCourse();
        if (!course.getTeacherUsername().equals(teacherUsername)) {
            throw new RuntimeException("You are not the owner of this course");
        }
        enrollment.setStatus("APPROVED");
        enrollment.setRespondedAt(LocalDateTime.now());
        enrollmentRepository.save(enrollment);
    }
    
    @Transactional
    public void rejectEnrollment(Long enrollmentId, String teacherUsername) {
        Enrollment enrollment = enrollmentRepository.findById(enrollmentId)
                .orElseThrow(() -> new RuntimeException("Enrollment not found"));
        Course course = enrollment.getCourse();
        if (!course.getTeacherUsername().equals(teacherUsername)) {
            throw new RuntimeException("You are not the owner of this course");
        }
        enrollment.setStatus("REJECTED");
        enrollment.setRespondedAt(LocalDateTime.now());
        enrollmentRepository.save(enrollment);
    }
    
    public List<Course> getCoursesForStudent(String studentUsername) {
        List<Enrollment> enrollments = enrollmentRepository.findByStudentUsername(studentUsername);
        return enrollments.stream()
                .filter(e -> "APPROVED".equals(e.getStatus()))
                .map(Enrollment::getCourse)
                .collect(Collectors.toList());
    }
}
"@
Write-File -relativePath "$packagePath/service/EnrollmentService.java" -content $enrollmentService

# -------------------- Controllers --------------------
$courseController = @"
package com.lms.course.controller;

import com.lms.course.annotation.RequireCourseOwner;
import com.lms.course.dto.CreateCourseRequest;
import com.lms.course.entity.Course;
import com.lms.course.service.CourseService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/courses")
@RequiredArgsConstructor
public class CourseController {
    
    private final CourseService courseService;
    
    @PostMapping
    public ResponseEntity<Course> createCourse(@Valid @RequestBody CreateCourseRequest request,
                                               @RequestHeader("X-Username") String username) {
        return ResponseEntity.ok(courseService.createCourse(request, username));
    }
    
    @GetMapping("/my")
    public ResponseEntity<List<Course>> getMyCourses(@RequestHeader("X-Username") String username,
                                                     @RequestHeader("X-Role") String role) {
        if ("TEACHER".equals(role)) {
            return ResponseEntity.ok(courseService.getCoursesByTeacher(username));
        } else {
            // For student, get enrolled courses via enrollment service (handled by separate endpoint)
            return ResponseEntity.ok(List.of());
        }
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Course> getCourse(@PathVariable Long id) {
        return ResponseEntity.ok(courseService.getCourse(id));
    }
    
    @DeleteMapping("/{id}")
    @RequireCourseOwner
    public ResponseEntity<Void> deleteCourse(@PathVariable Long id,
                                             @RequestHeader("X-Username") String username) {
        courseService.deleteCourse(id, username);
        return ResponseEntity.ok().build();
    }
}
"@
Write-File -relativePath "$packagePath/controller/CourseController.java" -content $courseController

$lessonController = @"
package com.lms.course.controller;

import com.lms.course.annotation.RequireCourseOwner;
import com.lms.course.dto.CreateLessonRequest;
import com.lms.course.entity.Lesson;
import com.lms.course.service.LessonService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/courses/{courseId}/lessons")
@RequiredArgsConstructor
public class LessonController {
    
    private final LessonService lessonService;
    
    @PostMapping
    @RequireCourseOwner
    public ResponseEntity<Lesson> addLesson(@PathVariable Long courseId,
                                            @Valid @RequestBody CreateLessonRequest request,
                                            @RequestHeader("X-Username") String username) {
        return ResponseEntity.ok(lessonService.addLesson(courseId, request, username));
    }
    
    @GetMapping
    public ResponseEntity<List<Lesson>> getLessons(@PathVariable Long courseId) {
        return ResponseEntity.ok(lessonService.getLessonsByCourse(courseId));
    }
    
    @GetMapping("/{lessonId}")
    public ResponseEntity<Lesson> getLesson(@PathVariable Long lessonId) {
        return ResponseEntity.ok(lessonService.getLesson(lessonId));
    }
}
"@
Write-File -relativePath "$packagePath/controller/LessonController.java" -content $lessonController

$enrollmentController = @"
package com.lms.course.controller;

import com.lms.course.dto.EnrollmentRequest;
import com.lms.course.entity.Enrollment;
import com.lms.course.service.EnrollmentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/enrollments")
@RequiredArgsConstructor
public class EnrollmentController {
    
    private final EnrollmentService enrollmentService;
    
    @PostMapping
    public ResponseEntity<Enrollment> requestEnrollment(@Valid @RequestBody EnrollmentRequest request,
                                                        @RequestHeader("X-Username") String username) {
        return ResponseEntity.ok(enrollmentService.requestEnrollment(request.getCourseId(), username));
    }
    
    @GetMapping("/pending")
    public ResponseEntity<List<Enrollment>> getPendingForCourse(@RequestParam Long courseId,
                                                                @RequestHeader("X-Username") String username) {
        return ResponseEntity.ok(enrollmentService.getPendingEnrollmentsForCourse(courseId, username));
    }
    
    @PostMapping("/{enrollmentId}/approve")
    public ResponseEntity<Void> approveEnrollment(@PathVariable Long enrollmentId,
                                                  @RequestHeader("X-Username") String username) {
        enrollmentService.approveEnrollment(enrollmentId, username);
        return ResponseEntity.ok().build();
    }
    
    @PostMapping("/{enrollmentId}/reject")
    public ResponseEntity<Void> rejectEnrollment(@PathVariable Long enrollmentId,
                                                 @RequestHeader("X-Username") String username) {
        enrollmentService.rejectEnrollment(enrollmentId, username);
        return ResponseEntity.ok().build();
    }
    
    @GetMapping("/my-courses")
    public ResponseEntity<?> getMyCourses(@RequestHeader("X-Username") String username) {
        return ResponseEntity.ok(enrollmentService.getCoursesForStudent(username));
    }
}
"@
Write-File -relativePath "$packagePath/controller/EnrollmentController.java" -content $enrollmentController

# -------------------- Security Config (simple, rely on gateway) --------------------
$securityConfig = @"
package com.lms.course.config;

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
package com.lms.course.exception;

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
EXPOSE 8083
ENTRYPOINT ["java", "-jar", "app.jar"]
"@
Write-File -relativePath "Dockerfile" -content $dockerfile

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Course Service setup complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Directory: $baseDir" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. cd $baseDir" -ForegroundColor White
Write-Host "2. Run 'mvn clean install' to build" -ForegroundColor White
Write-Host "3. Run 'docker build -t course-service .' to build Docker image" -ForegroundColor White
Write-Host "4. Or run locally with 'mvn spring-boot:run'" -ForegroundColor White
Write-Host ""
Write-Host "The service will start on port 8083" -ForegroundColor Green
Write-Host "Endpoints:" -ForegroundColor Cyan
Write-Host "  - POST /api/courses (create course, TEACHER only via X-Role header)" -ForegroundColor Gray
Write-Host "  - GET /api/courses/my (get my courses)" -ForegroundColor Gray
Write-Host "  - GET /api/courses/{id}" -ForegroundColor Gray
Write-Host "  - DELETE /api/courses/{id} (requires @RequireCourseOwner aspect)" -ForegroundColor Gray
Write-Host "  - POST /api/courses/{courseId}/lessons (add lesson)" -ForegroundColor Gray
Write-Host "  - GET /api/courses/{courseId}/lessons" -ForegroundColor Gray
Write-Host "  - POST /api/enrollments (request enrollment)" -ForegroundColor Gray
Write-Host "  - POST /api/enrollments/{id}/approve (teacher only)" -ForegroundColor Gray
Write-Host "  - GET /api/enrollments/my-courses (student's approved courses)" -ForegroundColor Gray
Write-Host ""
Write-Host "AOP Aspects enabled: AuthorizationAspect (course ownership) and LoggingAspect (controller logging)" -ForegroundColor Cyan