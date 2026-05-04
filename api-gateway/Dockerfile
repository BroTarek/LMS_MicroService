# Stage 1: Build the JAR with Maven
FROM eclipse-temurin:17-jdk-jammy AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*
COPY pom.xml .
RUN sed -i 's/\r//' pom.xml
RUN mvn dependency:go-offline -B
COPY src ./src
RUN find src -type f -exec sed -i 's/\r//' {} \;
RUN mvn clean package -DskipTests -B

# Stage 2: Run the JAR
FROM eclipse-temurin:17-jdk-jammy
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
