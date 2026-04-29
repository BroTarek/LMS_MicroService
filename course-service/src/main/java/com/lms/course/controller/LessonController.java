package com.lms.course.controller;

import com.lms.course.annotation.RequireCourseOwner;
import com.lms.course.dto.CreateLessonRequest;
import com.lms.course.entity.Lesson;
import com.lms.course.service.LessonService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/courses/{courseId}/lessons")
@RequiredArgsConstructor
public class LessonController {
    
    private final LessonService lessonService;
    
    @PostMapping
    @RequireCourseOwner
    public ResponseEntity<Lesson> addLesson(@PathVariable Long courseId,
                                            @Valid @RequestBody CreateLessonRequest request,
                                            @RequestHeader("X-Username") String username) {
        return ResponseEntity.ok(lessonService.addLesson(courseId, request, username));
    }
    
    @GetMapping
    public ResponseEntity<List<Lesson>> getLessons(@PathVariable Long courseId) {
        return ResponseEntity.ok(lessonService.getLessonsByCourse(courseId));
    }
    
    @GetMapping("/{lessonId}")
    public ResponseEntity<Lesson> getLesson(@PathVariable Long lessonId) {
        return ResponseEntity.ok(lessonService.getLesson(lessonId));
    }
}
