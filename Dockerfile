FROM gradle:8-jdk17 AS build
WORKDIR /home/gradle/src

# Gradle設定ファイルを先にコピー
COPY settings.gradle .
COPY build.gradle .

# pluginの依存解決のみ先に実行（pluginManagementの解決）
RUN gradle --no-daemon help || true

# 残りの全ファイルをコピー
COPY . .

# JARのビルド
RUN gradle bootJar --no-daemon

# 実行用イメージ
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /home/gradle/src/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
