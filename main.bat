@echo off
setlocal

if "%MLX_HOST%"=="" (set HOST=localhost) else (set HOST=%MLX_HOST%)
if "%MLX_PORT%"=="" (set PORT=8000) else (set PORT=%MLX_PORT%)

REM Allow passing server address as argument: main.bat my-mac.local:8000
if not "%~1"=="" (
    for /f "tokens=1,2 delims=:" %%a in ("%~1") do (
        set HOST=%%a
        if not "%%b"=="" set PORT=%%b
    )
)

set SERVER_URL=http://%HOST%:%PORT%

echo === MLX Audio TTS (Windows Client) ===
echo.
echo MLX requires Apple Silicon — the server must run on a Mac.
echo This launcher opens the browser and connects to: %SERVER_URL%
echo.
echo Starting browser...
start "" "%~dp0tts.html?server=%HOST%:%PORT%"
echo.

echo === Done ===
echo The TTS UI has been opened in your browser.
echo If the page doesn't connect, make sure the MLX Audio server is running on your Mac.
echo   On the Mac, run: python -m mlx_audio.server --host 0.0.0.0 --port %PORT%
echo.
pause
