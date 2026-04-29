package com.lms.upload.controller;

import com.lms.upload.dto.UploadResponse;
import com.lms.upload.entity.UploadedFile;
import com.lms.upload.service.FileStorageService;
import com.lms.upload.service.UploadService;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/uploads")
@RequiredArgsConstructor
public class UploadController {
    
    private final UploadService uploadService;
    private final FileStorageService fileStorageService;
    
    @PostMapping
    public ResponseEntity<UploadResponse> uploadFile(@RequestParam("file") MultipartFile file,
                                                     @RequestHeader("X-Username") String username) {
        return ResponseEntity.ok(uploadService.saveFileMetadata(file, username));
    }
    
    @GetMapping
    public ResponseEntity<List<UploadResponse>> getUserUploads(@RequestHeader("X-Username") String username) {
        return ResponseEntity.ok(uploadService.getUserUploads(username));
    }
    
    @GetMapping("/{uploadId}/download")
    public ResponseEntity<Resource> downloadFile(@PathVariable Long uploadId,
                                                 @RequestHeader("X-Username") String username) {
        UploadedFile file = uploadService.getUploadEntity(uploadId, username);
        Resource resource = fileStorageService.loadFileAsResource(file.getFilePath());
        
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(file.getMimeType()))
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + file.getFileName() + "\"")
                .body(resource);
    }
    
    @DeleteMapping("/{uploadId}")
    public ResponseEntity<Void> deleteFile(@PathVariable Long uploadId,
                                          @RequestHeader("X-Username") String username) {
        uploadService.deleteUpload(uploadId, username);
        return ResponseEntity.ok().build();
    }
}
