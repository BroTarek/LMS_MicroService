package com.lms.course.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CreateLessonRequest {
    @NotBlank
    private String title;
    
    private String contentUrl;
    
    @NotNull
    private Integer orderIndex;
}
