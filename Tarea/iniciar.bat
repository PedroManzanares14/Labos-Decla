@echo off
chcp 65001 > nul
title Sistema Experto de Integrales - SWI-Prolog

echo ======================================================================
echo    PROYECTO FINAL DE PROGRAMACION DECLARATIVA - CICLO 02/2026
echo    Sistema Experto de Integrales y Calculo de Area bajo la Curva
echo ======================================================================
echo.
echo [*] Verificando instalacion de SWI-Prolog (swipl)...
where swipl >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] No se encontro swipl.exe en el PATH de Windows.
    echo Asegurese de tener instalado SWI-Prolog y agregado al PATH.
    echo.
    echo Alternativa: Puede intentar iniciar con 'iniciar_node.bat'
    pause
    exit /b 1
)

echo [OK] SWI-Prolog detectado correctamente.
echo [*] Iniciando servidor HTTP nativo en SWI-Prolog...
echo [*] Abriendo la interfaz en su navegador web predeterminado...
echo.

start "" "http://localhost:8080/"

swipl -s "%~dp0backend\server.pl"

pause

