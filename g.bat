@echo off
call flutter clean
call flutter pub get

REM 檢查是否有參數
if "%1"=="" (
    REM 沒有參數，正常執行
    call call flutter run -d chrome
) else (
    REM 有參數，選擇對應設備
    if "%1"=="e" call flutter run -d edge
)