@echo off
setlocal EnableDelayedExpansion

REM Define constants
set "TEMP_FILE=temp_output.wav"

REM Prompt for the full path to the WAV file
set /p "audio_path=Enter the full path to the WAV file: "
if not exist "%audio_path%" (
    echo The specified file does not exist.
    goto :end
)

REM Determine the available duration for extension
for /f %%A in ('powershell -command "(New-Object Media.SoundPlayer '%audio_path%').Length / 1000"') do (
    set "available_duration=%%A"
)

REM Get the duration to extend the audio
set /p "duration_to_extend=Enter duration to extend (seconds): "
if %duration_to_extend% leq 0 (
    echo Invalid duration. Please enter a positive number.
    goto :end
)

REM Extend the audio by filling with current audio
set "extended_audio="
setlocal DisableDelayedExpansion
for /l %%B in (1, 1, %duration_to_extend%) do (
    setlocal EnableDelayedExpansion
    set "extended_audio=!extended_audio!%audio_path:~2!"
    endlocal
)
setlocal EnableDelayedExpansion
set "remaining_duration=%duration_to_extend%"
for /f %%C in ('powershell -command "%remaining_duration% %% %available_duration%"') do (
    set "remaining_duration=%%C"
)
for /f "delims=" %%D in ('powershell -command "(Get-Content '%audio_path%' -Raw) + (Get-Content '%audio_path%' -Raw | Select-String -n '^' | Select-Object -Last %remaining_duration%)"') do (
    set "extended_audio=!extended_audio!%%D"
)

REM Export the final audio to a temporary file
echo %extended_audio% > "%TEMP%\%TEMP_FILE%"

REM Play the extended audio
echo Playing extended audio...
powershell -command "(New-Object Media.SoundPlayer '%TEMP%\%TEMP_FILE%').PlaySync()"

REM Display the result
echo Audio playback finished.

REM Display the download link for the extended audio file
echo Download link: %TEMP%\%TEMP_FILE%

:end
REM Cleanup
exit /b
