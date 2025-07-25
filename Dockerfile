FROM gradle:8-jdk17 AS build

WORKDIR /home/gradle/src

# プラグインと依存解決のため、gradleファイルを先にコピー
COPY settings.gradle build.gradle ./

# ここで一度プラグイン解決（失敗しても無視してOK）
RUN gradle --no-daemon help || true

# 残りのソースをコピー
COPY . .

# JARをビルド
RUN gradle bootJar --no-daemon

# 実行用イメージ
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /home/gradle/src/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
