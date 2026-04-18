# setup-eureka-server.ps1
# Complete Eureka Server setup

$serviceName = "eureka-server"
$baseDir = $serviceName
$packagePath = "src/main/java/com/lms/eureka"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Setting up Eureka Server" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

# Create directory structure
$dirs = @(
    "$baseDir/$packagePath",
    "$baseDir/src/main/resources"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Write-Host "Created: $dir" -ForegroundColor Gray
}

# Function to write file content
function Write-File {
    param($relativePath, $content)
    $fullPath = Join-Path $baseDir $relativePath
    Set-Content -Path $fullPath -Value $content -Encoding UTF8
    Write-Host "  Written: $relativePath" -ForegroundColor Green
}

# -------------------- pom.xml --------------------
$pomContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.1.5</version>
        <relativePath/>
    </parent>

    <groupId>com.lms</groupId>
    <artifactId>eureka-server</artifactId>
    <version>1.0.0</version>
    <name>eureka-server</name>

    <properties>
        <java.version>17</java.version>
        <spring-cloud.version>2022.0.4</spring-cloud.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
    </dependencies>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>\${spring-cloud.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
"@
Write-File -relativePath "pom.xml" -content $pomContent

# -------------------- application.yml --------------------
$appYaml = @"
server:
  port: 8761

eureka:
  instance:
    hostname: localhost
  client:
    register-with-eureka: false
    fetch-registry: false
    service-url:
      defaultZone: http://\${eureka.instance.hostname}:\${server.port}/eureka/
  server:
    enable-self-preservation: false
    eviction-interval-timer-in-ms: 60000

spring:
  application:
    name: eureka-server

logging:
  level:
    com.netflix.eureka: INFO
    com.netflix.discovery: INFO
"@
Write-File -relativePath "src/main/resources/application.yml" -content $appYaml

# -------------------- Main Application --------------------
$mainApp = @"
package com.lms.eureka;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;

@SpringBootApplication
@EnableEurekaServer
public class EurekaServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(EurekaServerApplication.class, args);
    }
}
"@
Write-File -relativePath "$packagePath/EurekaServerApplication.java" -content $mainApp

# -------------------- Dockerfile --------------------
$dockerfile = @"
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8761
ENTRYPOINT ["java", "-jar", "app.jar"]
"@
Write-File -relativePath "Dockerfile" -content $dockerfile

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Eureka Server setup complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Directory: $baseDir" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. cd $baseDir" -ForegroundColor White
Write-Host "2. Run 'mvn clean install' to build" -ForegroundColor White
Write-Host "3. Run 'docker build -t eureka-server .' to build Docker image" -ForegroundColor White
Write-Host "4. Or run locally with 'mvn spring-boot:run'" -ForegroundColor White
Write-Host ""
Write-Host "The Eureka Server will start on port 8761" -ForegroundColor Green
Write-Host "Dashboard: http://localhost:8761" -ForegroundColor Cyan