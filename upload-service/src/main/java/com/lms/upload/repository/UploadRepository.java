package com.lms.upload.repository;

import com.lms.upload.entity.UploadedFile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface UploadRepository extends JpaRepository<UploadedFile, Long> {
    List<UploadedFile> findByUploaderUsername(String username);
    Optional<UploadedFile> findByIdAndUploaderUsername(Long id, String username);
}
