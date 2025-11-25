# PredictHealthApp

Aplicación de consola Java independiente que recopila datos relacionados con la salud y genera salida en formatos JSON y XML.

---

## Prerequisites

- Java 11+ instalado
- Acceso a Internet

---

# Linux / Mac

1. Asegúrese de estar en la carpeta del proyecto que contiene PredictHealthApp.java.

2. Cree un script de configuración prerequisites.sh con el siguiente contenido:

3. Correr con:

chmod +x prerequisites.sh
./prerequisites.sh


# Windows

1. Instalar librerías con:

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

2. Compilar y correr con:
./run.bat


## Development: Create Class
javac -encoding UTF-8 -d out -cp "lib/*" PredictHealthJava.java

## Development: Build JAR
jar cfm PredictHealthJava.jar manifest.txt -C out .

## Development: Run Program
java -Dfile.encoding=UTF-8 -cp "lib/*;PredictHealthJava.jar" PredictHealthJava
