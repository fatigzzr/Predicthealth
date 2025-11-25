@echo off
REM Compile
javac -encoding UTF-8 -d out -cp "lib/*" PredictHealthJava.java
IF ERRORLEVEL 1 (
    echo Compilation failed.
    exit /b 1
)

REM Create JAR
jar cfm PredictHealthJava.jar manifest.txt -C out .
IF ERRORLEVEL 1 (
    echo JAR creation failed.
    exit /b 1
)

REM Run program
java -Dfile.encoding=UTF-8 -cp "lib/*;PredictHealthJava.jar" PredictHealthJava
pause
