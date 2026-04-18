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
