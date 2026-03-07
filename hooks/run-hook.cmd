:; exec bash "$0" "$@"
@echo off
:: Cross-platform polyglot wrapper for hooks
:: When run on Unix, the first line hands off to bash
:: When run on Windows, the first line is a label and cmd takes over

:: Get the hook name from the first argument
set "HOOK=%~1"
if "%HOOK%"=="" (
    echo {"error": "No hook specified"} >&2
    exit /b 1
)

:: Resolve plugin root relative to this script
set "PLUGIN_ROOT=%~dp0.."

:: Execute the hook
call "%PLUGIN_ROOT%\hooks\%HOOK%" %*
exit /b %ERRORLEVEL%
