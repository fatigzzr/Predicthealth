FROM openjdk:17-jdk-slim

WORKDIR /app

# Copy JAR, libs and config
COPY PredictHealthJava.jar .
COPY lib ./lib
COPY config.properties ./config.properties

# Default: run the packaged Swing app (requires X11/display to see UI)
CMD ["java", "-Dfile.encoding=UTF-8", "-cp", "PredictHealthJava.jar:lib/*", "PredictHealthJava"]
