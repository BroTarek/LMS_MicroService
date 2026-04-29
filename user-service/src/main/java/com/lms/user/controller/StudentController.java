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
