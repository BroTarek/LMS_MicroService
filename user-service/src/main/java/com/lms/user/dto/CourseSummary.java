package com.lms.user.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CourseSummary {
    private Long id;
    private String title;
    private String teacherName;
    private String teacherUsername;
}
