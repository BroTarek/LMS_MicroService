package com.lms.user.service;

import com.lms.user.dto.UserProfileUpdateRequest;
import com.lms.user.dto.UserProfileResponse;
import com.lms.user.entity.*;
import com.lms.user.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserProfileService {
    
    private final UserProfileRepository userProfileRepository;
    private final TeacherRepository teacherRepository;
    private final StudentRepository studentRepository;
    
    @Transactional
    public UserProfile createProfile(String username, String fullName, String email) {
        if (userProfileRepository.existsByUsername(username)) {
            throw new RuntimeException("Profile already exists for username: " + username);
        }
        if (userProfileRepository.existsByEmail(email)) {
            throw new RuntimeException("Email already in use: " + email);
        }
        UserProfile profile = new UserProfile();
        profile.setUsername(username);
        profile.setFullName(fullName);
        profile.setEmail(email);
        return userProfileRepository.save(profile);
    }
    
    @Transactional
    public Teacher createTeacherProfile(String username, String department, String title) {
        UserProfile profile = userProfileRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("UserProfile not found for username: " + username));
        Teacher teacher = new Teacher();
        teacher.setUserProfile(profile);
        teacher.setDepartment(department);
        teacher.setTitle(title);
        return teacherRepository.save(teacher);
    }
    
    @Transactional
    public Student createStudentProfile(String username, String gradeLevel, String major) {
        UserProfile profile = userProfileRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("UserProfile not found for username: " + username));
        Student student = new Student();
        student.setUserProfile(profile);
        student.setGradeLevel(gradeLevel);
        student.setMajor(major);
        return studentRepository.save(student);
    }
    
    public UserProfile getProfile(String username) {
        return userProfileRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found: " + username));
    }
    
    public UserProfileResponse getFullProfileResponse(String username) {
        UserProfile profile = getProfile(username);
        UserProfileResponse response = new UserProfileResponse(
            profile.getUsername(), profile.getFullName(), profile.getEmail(), getUserRole(username)
        );
        
        teacherRepository.findByUserProfileUsername(username).ifPresent(teacher -> {
            response.setDepartment(teacher.getDepartment());
            response.setTitle(teacher.getTitle());
        });
        
        studentRepository.findByUserProfileUsername(username).ifPresent(student -> {
            response.setGradeLevel(student.getGradeLevel());
            response.setMajor(student.getMajor());
        });
        
        return response;
    }
    
    @Transactional
    public UserProfile updateProfile(String username, UserProfileUpdateRequest request) {
        UserProfile profile = getProfile(username);
        profile.setFullName(request.getFullName());
        profile.setEmail(request.getEmail());
        
        teacherRepository.findByUserProfileUsername(username).ifPresent(teacher -> {
            if (request.getDepartment() != null) teacher.setDepartment(request.getDepartment());
            if (request.getTitle() != null) teacher.setTitle(request.getTitle());
            teacherRepository.save(teacher);
        });
        
        studentRepository.findByUserProfileUsername(username).ifPresent(student -> {
            if (request.getGradeLevel() != null) student.setGradeLevel(request.getGradeLevel());
            if (request.getMajor() != null) student.setMajor(request.getMajor());
            studentRepository.save(student);
        });
        
        return userProfileRepository.save(profile);
    }
    
    public String getUserRole(String username) {
        if (teacherRepository.findByUserProfileUsername(username).isPresent()) {
            return "TEACHER";
        } else if (studentRepository.findByUserProfileUsername(username).isPresent()) {
            return "STUDENT";
        }
        throw new RuntimeException("Role not found for user: " + username);
    }
}
