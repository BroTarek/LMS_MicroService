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
