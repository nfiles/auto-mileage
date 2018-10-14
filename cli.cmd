@ECHO OFF

docker run -it --rm -v %CD%\scripts:/scripts -v %CD%\functions:/functions ubuntu

REM docker run -it --rm -v %CD%\scripts:/scripts -v %CD%\functions:/functions microsoft/azure-cli
