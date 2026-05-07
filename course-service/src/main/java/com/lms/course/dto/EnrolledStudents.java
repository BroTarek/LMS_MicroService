package com.lms.course.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class EnrolledStudents {
    private Long id;
    private String studentUsername;   // instead of "studentid"
    private String status;            // PENDING, APPROVED, REJECTED
    private LocalDateTime requestedAt;
    private LocalDateTime respondedAt;   // when the enrollment was approved (respondedAt)
}