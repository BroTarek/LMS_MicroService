package com.lms.upload.service;

import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@Service
public class FileStorageService {
    
    @Value("${file.upload-dir}")
    private String uploadDir;
    
    private Path fileStoragePath;
    
    @PostConstruct
    public void init() {
        try {
            this.fileStoragePath = Paths.get(uploadDir).toAbsolutePath().normalize();
            Files.createDirectories(this.fileStoragePath);
        } catch (IOException e) {
            throw new RuntimeException("Could not create upload directory", e);
        }
    }
    
    public String storeFile(MultipartFile file, String uploaderUsername) {
        try {
            // Generate unique filename to avoid collisions
            String originalFilename = file.getOriginalFilename();
            String fileExtension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String newFileName = UUID.randomUUID().toString() + fileExtension;
            
            Path targetPath = this.fileStoragePath.resolve(newFileName);
            Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);
            
            return targetPath.toString();
        } catch (IOException e) {
            throw new RuntimeException("Could not store file", e);
        }
    }
    
    public Resource loadFileAsResource(String filePath) {
        try {
            Path path = Paths.get(filePath).normalize();
            Resource resource = new UrlResource(path.toUri());
            if (resource.exists()) {
                return resource;
            } else {
                throw new RuntimeException("File not found: " + filePath);
            }
        } catch (MalformedURLException e) {
            throw new RuntimeException("File not found", e);
        }
    }
    
    public void deleteFile(String filePath) {
        try {
            Path path = Paths.get(filePath);
            Files.deleteIfExists(path);
        } catch (IOException e) {
            throw new RuntimeException("Could not delete file: " + filePath, e);
        }
    }
}
