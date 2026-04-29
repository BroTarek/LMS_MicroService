# 🐧 Linux Setup — Continue From Here

> This file was created so you can pick up exactly where you left off after booting into Linux.

---

## ✅ What's Already Done (no need to redo)

- All 6 **Dockerfiles** are fixed — changed `FROM openjdk:17-jdk-slim` (deprecated/removed from Docker Hub)
  to `FROM eclipse-temurin:17-jdk-jammy` (the official replacement).
  Affected files:
  - `api-gateway/Dockerfile`
  - `auth-service/Dockerfile`
  - `eureka-server/Dockerfile`
  - `user-service/Dockerfile`
  - `course-service/Dockerfile`
  - `upload-service/Dockerfile`
- `README.md` written at the project root with full explanation of the project.

---

## 🚀 Step-by-Step: Getting It Running on Linux

### Step 1 — Install Required Tools

```bash
# Java 17
sudo apt update
sudo apt install openjdk-17-jdk -y

# Maven (Java build tool)
sudo apt install maven -y

# Verify both are installed
java -version
mvn -version
```

For Docker, you have two options:

**Option A — Docker Desktop (GUI, you have the .deb in Downloads):**
```bash
# The file is at ~/Downloads/docker-desktop-amd64\ \(1\).deb
sudo apt install ~/Downloads/docker-desktop-amd64\ \(1\).deb
```

**Option B — Docker Engine (CLI only, simpler):**
```bash
sudo apt install docker.io docker-compose -y

# Add yourself to the docker group (so you don't need sudo every time)
sudo usermod -aG docker $USER

# IMPORTANT: Log out and log back in after this for it to take effect
```

---

### Step 2 — Navigate to the Project

The project lives on your Windows D: drive, which Linux mounts at `/mnt/d`:

```bash
cd /mnt/d/Boody/College/Level\ 3/2nd\ term/SE-2/project/LMS_MicroService
```

Verify you're in the right place:
```bash
ls
# You should see: docker-compose.yml  auth-service  course-service  api-gateway  etc.
```

---

### Step 3 — Build All Service JARs

Each service needs to be compiled into a `.jar` file before Docker can package it.
Run this from the project root:

```bash
for service in eureka-server auth-service user-service course-service upload-service api-gateway; do
  echo "========== Building $service =========="
  cd $service
  mvn clean package -DskipTests
  cd ..
done
```

This will take a few minutes on first run (Maven downloads dependencies).
When done, each service will have a `.jar` file in its `target/` folder.

---

### Step 4 — Start Everything with Docker

```bash
docker-compose up --build
```

First run pulls base images and builds containers — takes ~5 minutes.

Once running, open your browser:
- **Eureka Dashboard** → http://localhost:8761 ← check all services are registered here
- **API Gateway** → http://localhost:8080 ← your main entry point for all requests

---

### Step 5 — Test with Postman or curl

You also have `postman-linux-x64.tar.gz` in your Downloads. To install:
```bash
cd ~/Downloads
tar -xzf postman-linux-x64.tar.gz
./Postman/Postman   # run it
```

Test a basic endpoint:
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@test.com","password":"123456"}'
```

---

## ⚠️ Known Issue: Project on NTFS Drive

Since the project is on the Windows D: drive (`/mnt/d`), Docker volumes might have
permission issues. If `docker-compose up` fails with a volume/permission error, run:

```bash
# Option 1: Copy the project to your Linux home directory
cp -r /mnt/d/Boody/College/Level\ 3/2nd\ term/SE-2/project/LMS_MicroService ~/LMS_MicroService
cd ~/LMS_MicroService
docker-compose up --build
```

---

## 🛑 Useful Commands

```bash
# Stop all containers
docker-compose down

# View logs of a specific service
docker-compose logs -f auth-service

# Restart a single service after code changes
docker-compose restart course-service

# Rebuild a single service
docker-compose up --build course-service

# Stop everything and wipe all data (databases too)
docker-compose down -v
```

---

## 🗂️ Port Reference

| Service         | Port |
|-----------------|------|
| API Gateway     | 8080 |
| Auth Service    | 8081 |
| User Service    | 8082 |
| Course Service  | 8083 |
| Upload Service  | 8084 |
| Eureka Server   | 8761 |
| auth-db         | 5432 |
| user-db         | 5433 |
| course-db       | 5434 |
| upload-db       | 5435 |
| Redis           | 6379 |
