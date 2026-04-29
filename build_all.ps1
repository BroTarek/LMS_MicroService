$services = "api-gateway", "auth-service", "course-service", "eureka-server", "upload-service", "user-service"

foreach ($service in $services) {
    Write-Host "Building $service..."
    docker run --rm -v "$((Get-Location).Path)\$service`:/app" -v "$env:USERPROFILE\.m2:/root/.m2" -w /app maven:3.8.5-openjdk-17 mvn clean package -DskipTests
}

Write-Host "Starting Docker containers..."
docker-compose up -d --build
