package com.lms.course.aspect;

import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.AfterThrowing;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.springframework.stereotype.Component;

@Aspect
@Component
@Slf4j
public class LoggingAspect {
    
    @Before("execution(* com.lms.course.controller.*.*(..))")
    public void logBefore(JoinPoint joinPoint) {
        log.info("Entering method: {} with arguments: {}", 
            joinPoint.getSignature().getName(), joinPoint.getArgs());
    }
    
    @AfterReturning(pointcut = "execution(* com.lms.course.controller.*.*(..))", returning = "result")
    public void logAfterReturning(JoinPoint joinPoint, Object result) {
        log.info("Method: {} returned: {}", joinPoint.getSignature().getName(), result);
    }
    
    @AfterThrowing(pointcut = "execution(* com.lms.course.controller.*.*(..))", throwing = "error")
    public void logAfterThrowing(JoinPoint joinPoint, Exception error) {
        log.error("Method: {} threw exception: {}", joinPoint.getSignature().getName(), error.getMessage());
    }
}
