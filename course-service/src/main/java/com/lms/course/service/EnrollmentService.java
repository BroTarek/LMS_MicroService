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
