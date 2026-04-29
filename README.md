# 📚 LMS Microservice Project

> A **Learning Management System** built with a **Spring Boot Microservices Architecture** using Java 17, Spring Cloud, PostgreSQL, Redis, and Docker.

---

## 📖 Table of Contents

1. [Project Overview](#-project-overview)
2. [Architecture Diagram](#-architecture-diagram)
3. [Tech Stack](#-tech-stack)
4. [Services Explained](#-services-explained)
5. [Project Structure](#-project-structure)
6. [How to Run](#-how-to-run)
7. [How to Work on a Specific Service](#-how-to-work-on-a-specific-service)
8. [Key Concepts You Need to Know](#-key-concepts-you-need-to-know)
9. [Common Commands](#-common-commands)

---

## 🧭 Project Overview

This project is a **microservices-based LMS** (Learning Management System) — think of a simplified version of platforms like Coursera or Udemy. Instead of being one giant application, it is **split into small, independent services** that each do one job well and communicate with each other over HTTP.

### What can the system do?
- Register and authenticate users (login/register with JWT tokens)
- Manage user profiles
- Create and browse courses
- Upload files (course materials, videos, etc.)
- Route all client requests through a single entry point (API Gateway)

---

## 🏛️ Architecture Diagram

```
                        ┌─────────────┐
         Client ───────▶│  API Gateway │:8080
                        └──────┬──────┘
                               │ routes requests
              ┌────────────────┼────────────────┐
              │                │                │
    ┌─────────▼──┐   ┌─────────▼──┐   ┌────────▼───┐   ┌──────────────┐
    │Auth Service│   │User Service│   │Course Svc  │   │Upload Service│
    │   :8081    │   │   :8082    │   │   :8083    │   │    :8084     │
    └─────┬──────┘   └─────┬──────┘   └─────┬──────┘   └──────┬───────┘
          │                │                │                  │
    ┌─────▼──┐       ┌─────▼──┐       ┌─────▼──┐        ┌─────▼──┐
    │auth-db │       │user-db │       │course-db│       │upload-db│
    │  :5432 │       │  :5433 │       │  :5434  │       │  :5435  │
    └────────┘       └────────┘       └─────────┘        └─────────┘
          │
    ┌─────▼──┐
    │  Redis │  ← JWT token blacklist (for logout)
    │  :6379 │
    └────────┘

All services register themselves with:
    ┌────────────────┐
    │  Eureka Server │:8761  ← Service Discovery
    └────────────────┘
```

---

## 🧰 Tech Stack

| Technology | Version | Purpose |
|---|---|---|
| **Java** | 17 | Primary programming language |
| **Spring Boot** | 3.1.5 | Framework for building services |
| **Spring Cloud Gateway** | 2022.0.4 | API Gateway & request routing |
| **Spring Cloud Netflix Eureka** | 2022.0.4 | Service discovery & registry |
| **Spring Security** | (included) | Authentication & authorization |
| **Spring Data JPA** | (included) | ORM for database access |
| **Spring Data Redis** | (included) | Redis integration |
| **PostgreSQL** | 15 | Relational database (one per service) |
| **Redis** | 7 | In-memory store (JWT blacklist) |
| **jjwt (JJWT)** | 0.11.5 | JWT token creation & validation |
| **Lombok** | (latest) | Reduces boilerplate (auto-generates getters/setters) |
| **Maven** | 3+ | Build tool & dependency management |
| **Docker & Docker Compose** | latest | Containerization & orchestration |

---

## 🧩 Services Explained

### 1. 🔍 Eureka Server (`:8761`)
The **service registry**. Every service registers itself here when it starts up. Other services look up addresses from Eureka instead of using hardcoded IPs.
- Dashboard: http://localhost:8761

### 2. 🚪 API Gateway (`:8080`)
The **single entry point** for all client requests. You never call `auth-service` or `user-service` directly — you always go through the gateway.
- Built with **Spring Cloud Gateway** (reactive / WebFlux-based)
- Looks up where to route each request via Eureka
- Can apply filters (e.g., JWT validation) before forwarding

### 3. 🔐 Auth Service (`:8081`)
Handles **registration, login, logout, and token refresh**.
- Uses **Spring Security** to protect endpoints
- Issues **JWT tokens** (via JJWT library) on login
- Stores **blacklisted tokens** in **Redis** (so logout actually works)
- Has its own dedicated **PostgreSQL** database (`authdb`)
- Internal package structure:
  - `controller/` — REST endpoints (`/auth/register`, `/auth/login`, etc.)
  - `service/` — business logic
  - `entity/` — JPA database models
  - `repository/` — database queries (Spring Data JPA)
  - `dto/` — Data Transfer Objects (request/response shapes)
  - `config/` — Spring Security config, JWT config
  - `exception/` — custom error handling

### 4. 👤 User Service (`:8082`)
Manages **user profiles and information**.
- Its own PostgreSQL database (`userdb`)

### 5. 📘 Course Service (`:8083`)
Manages **courses, lessons, and enrollments**.
- Its own PostgreSQL database (`coursedb`)
- Has extra packages: `annotation/`, `aspect/`, `client/`
  - `client/` → calls other services (e.g., Auth Service) via HTTP (Feign or RestTemplate)
  - `aspect/` → AOP (Aspect-Oriented Programming) for cross-cutting concerns like logging

### 6. 📁 Upload Service (`:8084`)
Handles **file uploads** (PDFs, videos, images).
- Its own PostgreSQL database (`uploaddb`)
- Files are stored in a Docker volume at `/app/uploads`

---

## 📁 Project Structure

```
LMS_MicroService/
│
├── docker-compose.yml          ← Orchestrates ALL services together
│
├── eureka-server/              ← Service discovery
│   ├── src/
│   ├── pom.xml
│   └── Dockerfile
│
├── api-gateway/                ← Routes all requests
│   ├── src/
│   ├── pom.xml
│   └── Dockerfile
│
├── auth-service/               ← Login / Register / JWT
│   ├── src/main/java/com/lms/auth/
│   │   ├── controller/
│   │   ├── service/
│   │   ├── entity/
│   │   ├── repository/
│   │   ├── dto/
│   │   ├── config/
│   │   └── exception/
│   ├── src/main/resources/
│   │   └── application.properties
│   ├── pom.xml
│   └── Dockerfile
│
├── user-service/               ← User profiles
├── course-service/             ← Courses & content
├── upload-service/             ← File handling
│
└── setup-*.ps1                 ← PowerShell scripts to scaffold services
```

---

## 🚀 How to Run

### Option A: Fully Dockerized Build (No Local Maven Required)

If you do not have Maven installed locally (or just want a clean build environment), use the included `build_all.ps1` script. This script automatically spins up temporary Docker containers to compile the `.jar` files using your local `.m2` cache to save bandwidth, and then starts `docker-compose`.

> **Requirement:** Docker Desktop must be installed and running.

```powershell
# Navigate to the project root and run the build script
powershell -ExecutionPolicy Bypass -File .\build_all.ps1
```

*(Note: The first run downloads all Spring Boot dependencies, which may take 5–10 minutes depending on your internet connection. Subsequent builds will be heavily cached and finish in seconds!)*

### Option B: Everything via Docker Compose (If you have local Maven)

```powershell
# First, compile the project using your local Maven
mvn clean package -DskipTests

# Build all images and start all services
docker-compose up --build

# To stop everything
docker-compose down
```

First run takes **5–10 minutes**. After that:
- Eureka Dashboard → http://localhost:8761
- API Gateway (your main endpoint) → http://localhost:8080

---

### Option B: Run One Service Locally (For Development)

Use this when you are **working on a specific service** and want fast code → test cycles.

**Step 1:** Start the infrastructure (databases + Eureka) in Docker:
```powershell
docker-compose up eureka-server auth-db user-db course-db upload-db auth-redis
```

**Step 2:** Open the service you are working on in **IntelliJ IDEA**

**Step 3:** Run the main application class (e.g., `AuthServiceApplication.java`) directly from IntelliJ

The service will connect to the Docker databases and register with the Docker Eureka server.

---

### Option C: Fully Local (No Docker at All)

Install manually:
1. [Java 17](https://adoptium.net/) — set `JAVA_HOME`
2. [PostgreSQL 15](https://www.postgresql.org/download/) — create 4 databases: `authdb`, `userdb`, `coursedb`, `uploaddb`
3. [Redis](https://redis.io/download/) — start on port 6379
4. Run each service with Maven: `mvn spring-boot:run`

---

## 💻 How to Work on a Specific Service

Here is the recommended **day-to-day workflow**:

### Step 1: Open the Service in IntelliJ
Open the **service folder** (e.g., `auth-service/`) as a Maven project in IntelliJ IDEA.

### Step 2: Understand the Layer Structure
Every service follows the same **layered architecture**:

```
Controller → Service → Repository → Database
```

| Layer | Responsibility | Example file |
|---|---|---|
| `controller/` | Receives HTTP requests, returns responses | `AuthController.java` |
| `service/` | Business logic lives here | `AuthService.java` |
| `repository/` | Talks to the database | `UserRepository.java` |
| `entity/` | Maps to database tables | `User.java` |
| `dto/` | Shapes of request/response JSON | `LoginRequest.java` |
| `config/` | Spring beans, security setup | `SecurityConfig.java` |
| `exception/` | Custom error classes & handlers | `UserNotFoundException.java` |

### Step 3: Edit Code
- Most of your work will be in `service/` and `controller/`
- `entity/` if you're changing the database schema
- `dto/` if you're changing what the API accepts/returns

### Step 4: Test
Use **Postman** or **curl** to test your endpoints through the API Gateway:
```
POST http://localhost:8080/auth/register
POST http://localhost:8080/auth/login
GET  http://localhost:8080/courses
```

---

## 📚 Key Concepts You Need to Know

### What is a Microservice?
Instead of one big app, you have multiple small apps. Each one:
- Has its own database
- Runs independently
- Communicates with others via HTTP

### What is Eureka (Service Discovery)?
Services don't call each other by hardcoded IP. They register a name (e.g., `auth-service`) with Eureka, and others look that name up to find the current address.

### What is an API Gateway?
One URL for your entire system. The client calls `localhost:8080/auth/login` and the gateway figures out to forward that to the Auth Service at port 8081.

### What is JWT?
A **JSON Web Token** — a secure string returned after login. The client sends it in every subsequent request as a header:
```
Authorization: Bearer <token>
```

### What is Redis used for here?
When a user logs out, their JWT is added to a **blacklist in Redis**. Since JWTs are stateless, this is the way to invalidate them before they expire.

### What is Lombok?
A Java library that auto-generates repetitive code. Instead of writing `getEmail()`, `setEmail()`, etc. by hand, you just annotate your class with `@Getter @Setter` or `@Data`.

---

## ⚡ Common Commands

```powershell
# Start everything
docker-compose up --build

# Start only specific services
docker-compose up eureka-server auth-db auth-redis

# Stop all containers
docker-compose down

# Stop and delete all volumes (wipes databases!)
docker-compose down -v

# View logs of a specific service
docker-compose logs -f auth-service

# Build a single service JAR (inside its folder)
mvn clean package -DskipTests

# Run a service locally with Maven
mvn spring-boot:run
```

---

## 🗂️ Port Reference

| Service | Port |
|---|---|
| API Gateway | 8080 |
| Auth Service | 8081 |
| User Service | 8082 |
| Course Service | 8083 |
| Upload Service | 8084 |
| Eureka Server | 8761 |
| auth-db (PostgreSQL) | 5432 |
| user-db (PostgreSQL) | 5433 |
| course-db (PostgreSQL) | 5434 |
| upload-db (PostgreSQL) | 5435 |
| Redis | 6379 |

---

## 🛠️ Troubleshooting & Project History

During the initial orchestration and compilation of this project, several critical issues from the scaffolded generation scripts were resolved. If you are modifying the foundational code, keep these in mind:

1. **PowerShell Encoding Bugs (`\ufeff` & `@Value("\")`)**: The original PowerShell setup scripts injected a hidden UTF-8 BOM encoding that caused Java compiler errors (`illegal character: '\ufeff'`). It also improperly escaped strings, turning `@Value("${variable}")` into `@Value("\")`. These have been stripped and corrected across all `pom.xml` and `.java` files.
2. **Missing Security Dependencies**: `user-service`, `course-service`, and `upload-service` contained `SecurityConfig.java` files, but their `pom.xml` files were missing the `spring-boot-starter-security` dependency, causing "package does not exist" errors.
3. **Missing DTOs**: The `api-gateway` failed to compile because it relied on `ValidateResponse.java` to communicate with the `auth-service`, but the file was missing from the gateway's `dto` package.
4. **Java Lambda Compilation Errors**: In `course-service` (`AuthorizationAspect.java`), a local variable modified inside a `for` loop was used inside a lambda `orElseThrow()`. Java requires variables used in lambdas to be `final` or effectively final. This was fixed by assigning it to a new `final` variable before the lambda.
