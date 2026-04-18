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
