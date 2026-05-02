package com.lms.upload.service;

import com.lms.upload.dto.UploadResponse;
import com.lms.upload.entity.UploadedFile;
import com.lms.upload.repository.UploadRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UploadService {
    
    private final UploadRepository uploadRepository;
    private final FileStorageService fileStorageService;
    private final RestTemplate restTemplate;
    private static final String BASE_URL = "http://localhost:8084/api/uploads/";
    
    @Transactional
    public UploadResponse saveFileMetadata(MultipartFile file, Long courseId, String uploaderUsername) {
        String filePath = fileStorageService.storeFile(file, uploaderUsername);
        
        UploadedFile uploadedFile = new UploadedFile();
        uploadedFile.setFileName(file.getOriginalFilename());
        uploadedFile.setFilePath(filePath);
        uploadedFile.setUploaderUsername(uploaderUsername);
        uploadedFile.setFileSize(file.getSize());
        uploadedFile.setMimeType(file.getContentType());
        uploadedFile.setCourseId(courseId);
        
        UploadedFile saved = uploadRepository.save(uploadedFile);
        
        return mapToResponse(saved);
    }
    
    public List<UploadResponse> getUserUploads(String username) {
        return uploadRepository.findByUploaderUsername(username)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    public UploadedFile getUploadEntity(Long uploadId, String username) {
        UploadedFile file = uploadRepository.findById(uploadId)
                .orElseThrow(() -> new RuntimeException("Upload not found"));
                
        // If owner, allow access
        if (file.getUploaderUsername().equals(username)) {
            return file;
        }
        
        // If file is linked to a course, check if user is enrolled
        if (file.getCourseId() != null) {
            try {
                HttpHeaders headers = new HttpHeaders();
                headers.set("X-Username", username);
                HttpEntity<String> entity = new HttpEntity<>(headers);
                
                ResponseEntity<List<Map<String, Object>>> response = restTemplate.exchange(
                        "http://COURSE-SERVICE/api/courses/student/" + username,
                        HttpMethod.GET,
                        entity,
                        new ParameterizedTypeReference<List<Map<String, Object>>>() {}
                );
                
                if (response.getBody() != null) {
                    boolean isEnrolled = response.getBody().stream()
                            .anyMatch(course -> file.getCourseId().equals(Long.valueOf(course.get("id").toString())));
                    if (isEnrolled) {
                        return file;
                    }
                }
            } catch (Exception e) {
                // Ignore error and fall through to access denied
            }
        }
        
        throw new RuntimeException("Access Denied: You are not enrolled in the course for this file");
    }
    
    @Transactional
    public void deleteUpload(Long uploadId, String username) {
        UploadedFile file = getUploadEntity(uploadId, username);
        fileStorageService.deleteFile(file.getFilePath());
        uploadRepository.delete(file);
    }
    
    private UploadResponse mapToResponse(UploadedFile file) {
        String formattedDate = file.getUploadedAt() != null ? 
                file.getUploadedAt().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME) : null;
        String downloadUrl = BASE_URL + file.getId() + "/download";
        return new UploadResponse(
                file.getId(),
                file.getFileName(),
                downloadUrl,
                formattedDate,
                file.getFileSize(),
                file.getMimeType()
        );
    }
}
