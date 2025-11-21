@echo off
echo ========================================
echo   GETTING YOUR CURRENT IP ADDRESS
echo ========================================
echo.
ipconfig | findstr /i "IPv4"
echo.
echo ========================================
echo Copy the IP address above and update it in:
echo lib\config\app_config.dart
echo (Line 7: devIpAddress = 'YOUR_IP_HERE')
echo ========================================
pause
