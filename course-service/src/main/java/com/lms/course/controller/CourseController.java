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
