package com.lms.upload.service;

import com.lms.upload.dto.UploadResponse;
import com.lms.upload.entity.UploadedFile;
import com.lms.upload.repository.UploadRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UploadService {
    
    private final UploadRepository uploadRepository;
    private final FileStorageService fileStorageService;
    private static final String BASE_URL = "http://localhost:8084/api/uploads/";
    
    @Transactional
    public UploadResponse saveFileMetadata(MultipartFile file, String uploaderUsername) {
        String filePath = fileStorageService.storeFile(file, uploaderUsername);
        
        UploadedFile uploadedFile = new UploadedFile();
        uploadedFile.setFileName(file.getOriginalFilename());
        uploadedFile.setFilePath(filePath);
        uploadedFile.setUploaderUsername(uploaderUsername);
        uploadedFile.setFileSize(file.getSize());
        uploadedFile.setMimeType(file.getContentType());
        
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
        return uploadRepository.findByIdAndUploaderUsername(uploadId, username)
                .orElseThrow(() -> new RuntimeException("Upload not found or not owned by user"));
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
