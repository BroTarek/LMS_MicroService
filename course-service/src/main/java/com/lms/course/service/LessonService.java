package com.lms.course.service;

import com.lms.course.dto.CreateLessonRequest;
import com.lms.course.entity.Course;
import com.lms.course.entity.Lesson;
import com.lms.course.repository.LessonRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
public class LessonService {
    
    private final LessonRepository lessonRepository;
    private final CourseService courseService;
    
    @Transactional
    public Lesson addLesson(Long courseId, CreateLessonRequest request, String teacherUsername) {
        Course course = courseService.getCourse(courseId);
        if (!course.getTeacherUsername().equals(teacherUsername)) {
            throw new RuntimeException("You are not the owner of this course");
        }
        Lesson lesson = new Lesson();
        lesson.setCourse(course);
        lesson.setTitle(request.getTitle());
        lesson.setContentUrl(request.getContentUrl());
        lesson.setOrderIndex(request.getOrderIndex());
        return lessonRepository.save(lesson);
    }
    
    public List<Lesson> getLessonsByCourse(Long courseId) {
        return lessonRepository.findByCourseIdOrderByOrderIndex(courseId);
    }
    
    public Lesson getLesson(Long lessonId) {
        return lessonRepository.findById(lessonId)
                .orElseThrow(() -> new RuntimeException("Lesson not found: " + lessonId));
    }

    @Transactional
    public Lesson updateLesson(Long courseId, Long lessonId, CreateLessonRequest request, String teacherUsername) {
        Course course = courseService.getCourse(courseId);
        if (!course.getTeacherUsername().equals(teacherUsername)) {
            throw new RuntimeException("You are not the owner of this course");
        }
        Lesson lesson = getLesson(lessonId);
        if (!lesson.getCourse().getId().equals(courseId)) {
            throw new RuntimeException("Lesson does not belong to this course");
        }
        lesson.setTitle(request.getTitle());
        lesson.setContentUrl(request.getContentUrl());
        lesson.setOrderIndex(request.getOrderIndex());
        return lessonRepository.save(lesson);
    }

    @Transactional
    public void deleteLesson(Long courseId, Long lessonId, String teacherUsername) {
        Course course = courseService.getCourse(courseId);
        if (!course.getTeacherUsername().equals(teacherUsername)) {
            throw new RuntimeException("You are not the owner of this course");
        }
        Lesson lesson = getLesson(lessonId);
        if (!lesson.getCourse().getId().equals(courseId)) {
            throw new RuntimeException("Lesson does not belong to this course");
        }
        lessonRepository.delete(lesson);
    }
}
