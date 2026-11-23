@echo off
:: IDM ??????????????????
taskkill /F /IM "IDMan.exe" /T >NUL 2>&1
timeout /t 1 >NUL 2>&1
reg delete "HKCU\Software\Classes\Wow6432Node\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}" /f >NUL 2>&1
reg delete "HKCU\Software\Classes\Wow6432Node\CLSID\{79873CC5-3951-43ED-BDF9-D8759474B6FD}" /f >NUL 2>&1
reg delete "HKCU\Software\DownloadManager" /f /v "scansk" >NUL 2>&1
reg delete "HKCU\Software\DownloadManager" /f /v "tvfrdt" >NUL 2>&1
reg delete "HKCU\Software\DownloadManager" /f /v "radxcnt" >NUL 2>&1
reg add "HKCU\Software\DownloadManager" /f /v "CheckUpdtVM" /t REG_DWORD /d 0 >NUL 2>&1
reg add "HKCU\Software\DownloadManager" /f /v "LstCheck" /d "12/31/2099" >NUL 2>&1
reg add "HKCU\Software\DownloadManager" /f /v "TipStartUp" /t REG_DWORD /d 0 >NUL 2>&1
exit /b 0
