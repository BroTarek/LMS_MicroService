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
