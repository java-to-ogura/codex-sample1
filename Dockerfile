# ---- Build Stage ----
FROM gradle:8-jdk17 AS build

# 必要なツールと証明書の取得・登録
RUN apt-get update && apt-get install -y wget openssl ca-certificates && \
    echo | openssl s_client -showcerts -connect repo.maven.apache.org:443 -servername repo.maven.apache.org 2>/dev/null \
    | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /usr/local/share/ca-certificates/mavenrepo.crt && \
    update-ca-certificates && \
    keytool -import -noprompt -trustcacerts -alias mavenrepo \
        -keystore "$JAVA_HOME/lib/security/cacerts" \
        -storepass changeit -file /usr/local/share/ca-certificates/mavenrepo.crt

WORKDIR /home/gradle/src
COPY settings.gradle ./
COPY build.gradle ./

# Gradleの依存を早めに解決してキャッシュ活用
RUN gradle --no-daemon help || true

COPY . ./
RUN gradle bootJar --no-daemon

# ---- Runtime Stage ----
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /home/gradle/src/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
