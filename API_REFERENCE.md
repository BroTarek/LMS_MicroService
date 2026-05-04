# LMS Microservice — API Reference

All requests go through the **API Gateway** at `http://localhost:8080`.

> **Auth note:** Most endpoints require a JWT token in the `Authorization` header.  
> The gateway validates the token and forwards `X-Username` and `X-Role` headers to downstream services automatically.

---

## 🔐 Auth Service — `/auth/**`

> All `/auth/**` endpoints are public (no token required), except `/auth/logout` and `/auth/validate`.

### POST `/auth/register`
Register a new user account.

```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "alice",
    "password": "secret123",
    "role": "STUDENT",
    "fullName": "Alice Smith",
    "email": "alice@test.com"
  }'
```

| Field | Type | Required | Constraint |
|-------|------|----------|------------|
| `username` | String | ✅ | Not blank |
| `password` | String | ✅ | Not blank |
| `role` | String | ✅ | `"STUDENT"` or `"TEACHER"` |
| `fullName` | String | ✅ | Not blank |
| `email` | String | ✅ | Not blank |

**Response:** `200 OK` (empty body)

---

### POST `/auth/login`
Login and receive a JWT token.

```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "alice",
    "password": "secret123"
  }'
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiJ9...",
  "username": "alice",
  "role": "STUDENT"
}
```

---

### POST `/auth/refresh`
Get a new access token using a refresh token.

```bash
curl -X POST http://localhost:8080/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "<your_refresh_token>"
  }'
```

**Response:** Same as `/auth/login`

---

### POST `/auth/logout`
Invalidate the current token. Requires auth.

```bash
curl -X POST http://localhost:8080/auth/logout \
  -H "Authorization: Bearer <your_token>"
```

**Response:** `200 OK` (empty body)

---

### GET `/auth/validate`
Validate a token. Requires auth.

```bash
curl http://localhost:8080/auth/validate \
  -H "Authorization: Bearer <your_token>"
```

**Response:**
```json
{
  "username": "alice",
  "role": "STUDENT",
  "valid": true
}
```

---

## 👤 User Service — `/api/users/**`

### GET `/api/users/me`
Get the authenticated user's profile.

```bash
curl http://localhost:8080/api/users/me \
  -H "Authorization: Bearer <your_token>"
```

**Response:**
```json
{
  "username": "alice",
  "fullName": "Alice Smith",
  "email": "alice@test.com",
  "role": "STUDENT",
  "bio": null
}
```

---

### PUT `/api/users/me`
Update the authenticated user's profile.

```bash
curl -X PUT http://localhost:8080/api/users/me \
  -H "Authorization: Bearer <your_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "Alice Johnson",
    "bio": "Passionate learner."
  }'
```

**Response:** Updated profile object (same shape as GET `/api/users/me`)

---

## 🎓 Student Endpoints — `/api/students/**`

> Requires `role: STUDENT`

### GET `/api/students/my-courses`
Get all courses the authenticated student is enrolled in (with teacher names resolved).

```bash
curl http://localhost:8080/api/students/my-courses \
  -H "Authorization: Bearer <student_token>"
```

**Response:**
```json
[
  {
    "id": 1,
    "title": "Spring Boot Basics",
    "description": "Learn Spring Boot",
    "teacherUsername": "bob",
    "teacherName": "Bob Jones"
  }
]
```

---

## 🧑‍🏫 Teacher Endpoints — `/api/teachers/**`

> Requires `role: TEACHER`

### GET `/api/teachers/my-courses`
Get all courses created by the authenticated teacher (with teacher names resolved).

```bash
curl http://localhost:8080/api/teachers/my-courses \
  -H "Authorization: Bearer <teacher_token>"
```

**Response:** Same shape as student `/my-courses`

---

## 📚 Course Service — `/api/courses/**`

### GET `/api/courses`
List all courses. Public — no token required.

```bash
curl http://localhost:8080/api/courses
```

---

### GET `/api/courses/{id}`
Get a single course by ID.

```bash
curl http://localhost:8080/api/courses/1
```

---

### POST `/api/courses`
Create a new course. Requires `role: TEACHER`.

```bash
curl -X POST http://localhost:8080/api/courses \
  -H "Authorization: Bearer <teacher_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Spring Boot Basics",
    "description": "A beginner course on Spring Boot."
  }'
```

| Field | Type | Required |
|-------|------|----------|
| `title` | String | ✅ |
| `description` | String | ❌ |

**Response:** Created `Course` object

---

### PUT `/api/courses/{id}`
Update a course. Must be the course owner (teacher).

```bash
curl -X PUT http://localhost:8080/api/courses/1 \
  -H "Authorization: Bearer <teacher_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Spring Boot Advanced",
    "description": "Updated description."
  }'
```

---

### DELETE `/api/courses/{id}`
Delete a course. Must be the course owner.

```bash
curl -X DELETE http://localhost:8080/api/courses/1 \
  -H "Authorization: Bearer <teacher_token>"
```

---

### GET `/api/courses/my`
Get courses for the authenticated user. Returns teacher's courses if `TEACHER`, enrolled courses if `STUDENT`.

```bash
curl http://localhost:8080/api/courses/my \
  -H "Authorization: Bearer <your_token>"
```

---

### GET `/api/courses/teacher/{username}`
Get all courses by a specific teacher.

```bash
curl http://localhost:8080/api/courses/teacher/bob
```

---

### GET `/api/courses/student/{username}`
Get all courses a specific student is enrolled in.

```bash
curl http://localhost:8080/api/courses/student/alice
```

---

## 📖 Lesson Service — `/api/courses/{courseId}/lessons/**`

### GET `/api/courses/{courseId}/lessons`
List all lessons for a course.

```bash
curl http://localhost:8080/api/courses/1/lessons \
  -H "Authorization: Bearer <your_token>"
```

---

### GET `/api/courses/{courseId}/lessons/{lessonId}`
Get a single lesson.

```bash
curl http://localhost:8080/api/courses/1/lessons/1 \
  -H "Authorization: Bearer <your_token>"
```

---

### POST `/api/courses/{courseId}/lessons`
Add a lesson to a course. Must be course owner.

```bash
curl -X POST http://localhost:8080/api/courses/1/lessons \
  -H "Authorization: Bearer <teacher_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Introduction to Spring Boot",
    "contentUrl": "https://example.com/lesson1.mp4",
    "orderIndex": 1
  }'
```

| Field | Type | Required |
|-------|------|----------|
| `title` | String | ✅ |
| `contentUrl` | String | ❌ |
| `orderIndex` | Integer | ✅ |

---

### PUT `/api/courses/{courseId}/lessons/{lessonId}`
Update a lesson. Must be course owner.

```bash
curl -X PUT http://localhost:8080/api/courses/1/lessons/1 \
  -H "Authorization: Bearer <teacher_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Intro — Updated",
    "contentUrl": "https://example.com/lesson1-v2.mp4",
    "orderIndex": 1
  }'
```

---

### DELETE `/api/courses/{courseId}/lessons/{lessonId}`
Delete a lesson. Must be course owner.

```bash
curl -X DELETE http://localhost:8080/api/courses/1/lessons/1 \
  -H "Authorization: Bearer <teacher_token>"
```

---

## 📋 Enrollment Service — `/api/enrollments/**`

### POST `/api/enrollments`
Request enrollment in a course. Requires `role: STUDENT`.

```bash
curl -X POST http://localhost:8080/api/enrollments \
  -H "Authorization: Bearer <student_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "courseId": 1
  }'
```

---

### GET `/api/enrollments/pending?courseId={id}`
Get pending enrollment requests for a course. Must be course owner (teacher).

```bash
curl "http://localhost:8080/api/enrollments/pending?courseId=1" \
  -H "Authorization: Bearer <teacher_token>"
```

---

### POST `/api/enrollments/{enrollmentId}/approve`
Approve an enrollment request. Must be course owner.

```bash
curl -X POST http://localhost:8080/api/enrollments/1/approve \
  -H "Authorization: Bearer <teacher_token>"
```

---

### POST `/api/enrollments/{enrollmentId}/reject`
Reject an enrollment request. Must be course owner.

```bash
curl -X POST http://localhost:8080/api/enrollments/1/reject \
  -H "Authorization: Bearer <teacher_token>"
```

---

### GET `/api/enrollments/my-courses`
Get courses the authenticated student is enrolled in.

```bash
curl http://localhost:8080/api/enrollments/my-courses \
  -H "Authorization: Bearer <student_token>"
```

---

## 📁 Upload Service — `/api/uploads/**`

### POST `/api/uploads`
Upload a file (optionally attach to a course).

```bash
curl -X POST http://localhost:8080/api/uploads \
  -H "Authorization: Bearer <your_token>" \
  -F "file=@/path/to/document.pdf" \
  -F "courseId=1"
```

| Form Field | Type | Required |
|------------|------|----------|
| `file` | multipart file | ✅ |
| `courseId` | Long | ❌ |

**Response:**
```json
{
  "id": 1,
  "fileName": "document.pdf",
  "mimeType": "application/pdf",
  "courseId": 1,
  "uploadedBy": "alice"
}
```

---

### GET `/api/uploads`
List all uploads by the authenticated user.

```bash
curl http://localhost:8080/api/uploads \
  -H "Authorization: Bearer <your_token>"
```

---

### GET `/api/uploads/{uploadId}/download`
Download an uploaded file.

```bash
curl http://localhost:8080/api/uploads/1/download \
  -H "Authorization: Bearer <your_token>" \
  -o downloaded_file.pdf
```

---

### DELETE `/api/uploads/{uploadId}`
Delete an uploaded file.

```bash
curl -X DELETE http://localhost:8080/api/uploads/1 \
  -H "Authorization: Bearer <your_token>"
```

---

## 🧪 Quick Test Flow (Copy & Paste)

```bash
BASE=http://localhost:8080

# 1. Register a teacher
curl -s -X POST $BASE/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"bob","password":"secret123","role":"TEACHER","fullName":"Bob Jones","email":"bob@test.com"}'

# 2. Register a student
curl -s -X POST $BASE/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"alice","password":"secret123","role":"STUDENT","fullName":"Alice Smith","email":"alice@test.com"}'

# 3. Login as teacher — copy the token!
curl -s -X POST $BASE/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"bob","password":"secret123"}'

# Set tokens (replace with actual values)
TEACHER="<teacher_jwt_token>"
STUDENT="<student_jwt_token>"

# 4. Create a course
curl -s -X POST $BASE/api/courses \
  -H "Authorization: Bearer $TEACHER" \
  -H "Content-Type: application/json" \
  -d '{"title":"Spring Boot Basics","description":"A beginner Spring Boot course."}'

# 5. Add a lesson to course 1
curl -s -X POST $BASE/api/courses/1/lessons \
  -H "Authorization: Bearer $TEACHER" \
  -H "Content-Type: application/json" \
  -d '{"title":"Lesson 1 — Intro","contentUrl":"https://example.com/lesson1.mp4","orderIndex":1}'

# 6. Login as student
curl -s -X POST $BASE/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"alice","password":"secret123"}'

# 7. Student requests enrollment
curl -s -X POST $BASE/api/enrollments \
  -H "Authorization: Bearer $STUDENT" \
  -H "Content-Type: application/json" \
  -d '{"courseId":1}'

# 8. Teacher approves enrollment 1
curl -s -X POST $BASE/api/enrollments/1/approve \
  -H "Authorization: Bearer $TEACHER"

# 9. Student views enrolled courses
curl -s $BASE/api/enrollments/my-courses \
  -H "Authorization: Bearer $STUDENT"
```

---

## 🗺️ Port Reference

| Service | Container Port | Host Port |
|---------|---------------|-----------|
| API Gateway | 8080 | 8080 |
| Auth Service | 8081 | — |
| User Service | 8082 | — |
| Course Service | 8083 | — |
| Upload Service | 8084 | — |
| Eureka Dashboard | 8761 | 8761 |

> Only the **API Gateway (8080)** and **Eureka (8761)** are exposed to the host. All other services communicate internally via the Docker network.
