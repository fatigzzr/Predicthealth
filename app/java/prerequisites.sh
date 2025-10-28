#!/bin/bash

# Update system
sudo apt update && sudo apt upgrade -y

# Install Java 11 if not installed
if ! java -version 2>&1 | grep -q "11"; then
    echo "Installing OpenJDK 11..."
    sudo apt install -y openjdk-11-jdk
fi

# Install Maven if not installed
if ! mvn -v >/dev/null 2>&1; then
    echo "Installing Maven..."
    sudo apt install -y maven
fi

# Create lib folder for Jackson jars
mkdir -p lib
cd lib

# Download Jackson Jars
JACKSON_VERSION=2.15.2
declare -a jars=("jackson-core" "jackson-databind" "jackson-annotations" "jackson-dataformat-xml")
for jar in "${jars[@]}"; do
    if [ ! -f ${jar}-${JACKSON_VERSION}.jar ]; then
        wget https://repo1.maven.org/maven2/com/fasterxml/jackson/core/${jar}/${JACKSON_VERSION}/${jar}-${JACKSON_VERSION}.jar
    fi
done
cd ..

echo "Prerequisites installed. Compile with javac -cp 'lib/*' PredictHealthApp.java"
