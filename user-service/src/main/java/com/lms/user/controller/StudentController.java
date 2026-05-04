package com.lms.user.controller;

import com.lms.user.client.CourseServiceClient;
import com.lms.user.dto.CourseSummary;
import com.lms.user.service.UserProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/students")
@RequiredArgsConstructor
public class StudentController {
    
    private final CourseServiceClient courseServiceClient;
    private final UserProfileService userProfileService;
    
    @GetMapping("/my-courses")
    public ResponseEntity<List<CourseSummary>> getMyCourses(@RequestHeader("X-Username") String username) {
        List<CourseSummary> courses = courseServiceClient.getCoursesByStudent(username);
        courses.forEach(course -> {
            if (course.getTeacherUsername() != null) {
                try {
                    course.setTeacherName(userProfileService.getProfile(course.getTeacherUsername()).getFullName());
                } catch (Exception e) {
                    course.setTeacherName("Unknown Teacher");
                }
            }
        });
        return ResponseEntity.ok(courses);
    }
}
