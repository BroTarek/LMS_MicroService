package com.lms.course.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "USER-SERVICE")
public interface UserServiceClient {
    
    @GetMapping("/internal/users/{username}/role")
    String getUserRole(@PathVariable("username") String username);
}
