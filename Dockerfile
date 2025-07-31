FROM gradle:8-jdk17 AS build

# Gradleキャッシュの場所を一時ディレクトリに変更（パーミッション回避）
ENV GRADLE_USER_HOME=/tmp/.gradle

WORKDIR /home/gradle/src

# SSL証明書エラー回避（証明書更新）
USER root
RUN apt-get update && apt-get install -y ca-certificates && update-ca-certificates
USER gradle

# Gradle設定ファイルを先にコピー
COPY settings.gradle .
COPY build.gradle .

# Pluginリゾルブ
RUN gradle --no-daemon help || true

# 残りのファイル（.gradle除外されている前提）
COPY . .

# JARのビルド
RUN gradle bootJar --no-daemon

# 実行用ステージ
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /home/gradle/src/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
