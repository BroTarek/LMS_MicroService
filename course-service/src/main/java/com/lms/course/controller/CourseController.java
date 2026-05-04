package com.lms.course.controller;

import com.lms.course.annotation.RequireCourseOwner;
import com.lms.course.dto.CreateCourseRequest;
import com.lms.course.entity.Course;
import com.lms.course.service.CourseService;
import com.lms.course.service.EnrollmentService;
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
    private final EnrollmentService enrollmentService;
    
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
            return ResponseEntity.ok(enrollmentService.getCoursesForStudent(username));
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

    @GetMapping
    public ResponseEntity<List<Course>> getAllCourses() {
        return ResponseEntity.ok(courseService.getAllCourses());
    }

    @GetMapping("/teacher/{username}")
    public ResponseEntity<List<Course>> getCoursesByTeacher(@PathVariable String username) {
        return ResponseEntity.ok(courseService.getCoursesByTeacher(username));
    }

    @GetMapping("/student/{username}")
    public ResponseEntity<List<Course>> getCoursesByStudent(@PathVariable String username) {
        return ResponseEntity.ok(enrollmentService.getCoursesForStudent(username));
    }

    @PutMapping("/{id}")
    @RequireCourseOwner
    public ResponseEntity<Course> updateCourse(@PathVariable Long id,
                                               @Valid @RequestBody CreateCourseRequest request,
                                               @RequestHeader("X-Username") String username) {
        return ResponseEntity.ok(courseService.updateCourse(id, request, username));
    }
}
