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
