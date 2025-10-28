# PredictHealthApp

Standalone Java console application that collects health-related data and outputs both JSON and XML.

---

## Prerequisites

- **Java 11+** installed
- Internet access
- No Maven required (manual `.jar` setup included)

---

## Linux / Mac

1. Make sure you are in the project folder containing `PredictHealthApp.java`.
2. Create a setup script `prerequisites.sh` with the following content:

```bash
#!/bin/bash

# Update system
sudo apt update && sudo apt upgrade -y

# Install Java 11 if not installed
if ! java -version 2>&1 | grep -q "11"; then
    echo "Installing OpenJDK 11..."
    sudo apt install -y openjdk-11-jdk
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

echo "Setup complete. Compile with: javac -cp 'lib/*' PredictHealthApp.java"
```

## Run
chmod +x prerequisites.sh
./prerequisites.sh

# Windows

## Development: Powershell Libraries

mkdir lib
cd lib

$version="2.15.2"

$urls = @(
    "https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-core/$version/jackson-core-$version.jar",
    "https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/$version/jackson-databind-$version.jar",
    "https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-annotations/$version/jackson-annotations-$version.jar",
    "https://repo1.maven.org/maven2/com/fasterxml/jackson/dataformat/jackson-dataformat-xml/$version/jackson-dataformat-xml-$version.jar"
)

foreach ($url in $urls) {
    $fileName = Split-Path $url -Leaf
    Invoke-WebRequest -Uri $url -OutFile $fileName
}

cd ..

## Development: Create Class
javac -cp "lib/*" PredictHealthApp.java

## Development: Build JAR
jar cfm PredictHealthApp.jar manifest.txt PredictHealthApp.class

## Development: Run Program
java -jar PredictHealthApp.jar