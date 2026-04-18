package com.lms.upload.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UploadResponse {
    private Long id;
    private String fileName;
    private String url;
    private String uploadedAt;
    private Long fileSize;
    private String mimeType;
}
