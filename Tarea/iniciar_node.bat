@echo off
chcp 65001 > nul
title Sistema Experto de Integrales - Servidor Node.js

echo ======================================================================
echo    PROYECTO FINAL DE PROGRAMACION DECLARATIVA - CICLO 02/2026
echo    Sistema Experto de Integrales y Calculo de Area bajo la Curva
echo ======================================================================
echo.
echo [*] Verificando Node.js...
where node >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] No se encontro node.exe en el PATH de Windows.
    echo Asegurese de tener instalado Node.js o use 'iniciar.bat' con Prolog.
    pause
    exit /b 1
)

echo [OK] Node.js detectado.
echo [*] Abriendo la interfaz en su navegador web predeterminado...
echo.

start "" "http://localhost:8080/"

node "%~dp0server.js"

pause

