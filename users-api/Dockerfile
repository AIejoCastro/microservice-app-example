# Build stage
FROM maven:3.8-openjdk-8 as build-stage
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

# Production stage
FROM openjdk:8-jre-slim as production-stage
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build-stage /app/target/*.jar app.jar
RUN groupadd -r spring && useradd -r -g spring spring
RUN chown -R spring:spring /app
USER spring
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1
ENV JAVA_OPTS="-Xmx512m -Xms256m"
CMD java $JAVA_OPTS -jar app.jar