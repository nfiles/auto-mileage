@ECHO OFF

docker run -it --rm -v %CD%\scripts:/scripts -v %CD%\functions:/function microsoft/azure-cli
