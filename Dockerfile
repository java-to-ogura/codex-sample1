FROM gradle:8-jdk17 AS build
WORKDIR /home/gradle/src

# ★ CA証明書を更新
USER root
RUN apt-get update && apt-get install -y ca-certificates && update-ca-certificates
USER gradle

COPY settings.gradle .
COPY build.gradle .

RUN gradle --no-daemon help || true

COPY . .

RUN gradle bootJar --no-daemon

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /home/gradle/src/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
