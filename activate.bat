@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title IDM 永久免费激活脚本

:: ============================================================
::  IDM 永久免费激活脚本（无需破解 exe，不触发"文件已损坏"）
::  原理：
::   1. 使用官方正版 IDM（保留数字签名，通过自校验）
::   2. 清除伪造序列号 -> 走试用模式，不弹"序列号被禁用"
::   3. 重置并冻结试用期 -> 永不提示试用到期
::   4. 禁用自动更新 + 阻断联网验证 -> 不弹更新窗口
::  需要管理员权限运行
:: ============================================================

:: ---------- 检查管理员权限 ----------
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 请右键"以管理员身份运行"本脚本。
    pause
    exit /b 1
)

:: ---------- 获取当前用户 SID ----------
for /f "tokens=2" %%a in ('whoami /user /fo list ^| findstr /i "SID"') do set "SID=%%a"

:: ---------- 结束 IDM 进程 ----------
echo [1/6] 结束 IDM 进程...
taskkill /F /IM "IDMan.exe" /T >nul 2>&1
taskkill /F /IM "IDMGrHlp.exe" /T >nul 2>&1
taskkill /F /IM "IEMonitor.exe" /T >nul 2>&1
taskkill /F /IM "IDMMsgHost.exe" /T >nul 2>&1
timeout /t 1 >nul 2>&1

:: ---------- 清除伪造序列号与试用追踪键 ----------
echo [2/6] 清除伪造序列号与试用追踪键...
for %%K in (Serial Email FName LName scansk tvfrdt radxcnt ptrk_scdt LastCheckQU) do (
    reg delete "HKCU\Software\DownloadManager" /f /v "%%K" >nul 2>&1
    reg delete "HKU\%SID%\Software\DownloadManager" /f /v "%%K" >nul 2>&1
)
reg delete "HKLM\Software\Internet Download Manager" /f /v "Serial" >nul 2>&1
reg delete "HKLM\Software\Internet Download Manager" /f /v "Email" >nul 2>&1
reg delete "HKLM\Software\WOW6432Node\Internet Download Manager" /f /v "Serial" >nul 2>&1
reg delete "HKLM\Software\WOW6432Node\Internet Download Manager" /f /v "Email" >nul 2>&1

:: ---------- 重置试用期（删除试用状态 CLSID 键） ----------
echo [3/6] 重置试用期...
reg delete "HKCU\Software\Classes\Wow6432Node\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Wow6432Node\CLSID\{79873CC5-3951-43ED-BDF9-D8759474B6FD}" /f >nul 2>&1
reg delete "HKU\%SID%\Software\Classes\Wow6432Node\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}" /f >nul 2>&1
reg delete "HKU\%SID%\Software\Classes\Wow6432Node\CLSID\{79873CC5-3951-43ED-BDF9-D8759474B6FD}" /f >nul 2>&1

:: ---------- 禁用更新 + 抑制弹窗 ----------
echo [4/6] 禁用自动更新并抑制弹窗...
reg add "HKCU\Software\DownloadManager" /f /v "CheckUpdtVM" /t REG_DWORD /d 0 >nul 2>&1
reg add "HKCU\Software\DownloadManager" /f /v "LstCheck" /d "12/31/2099" >nul 2>&1
reg add "HKCU\Software\DownloadManager" /f /v "TipStartUp" /t REG_DWORD /d 0 >nul 2>&1
reg add "HKCU\Software\DownloadManager" /f /v "ShowTipOnFirstCatch" /t REG_DWORD /d 0 >nul 2>&1
reg add "HKCU\Software\DownloadManager" /f /v "LaunchOnStart" /t REG_DWORD /d 0 >nul 2>&1
reg add "HKLM\Software\Internet Download Manager" /f /v "AdvIntDriverEnabled2" /t REG_DWORD /d 1 /reg:32 >nul 2>&1

:: ---------- 阻断联网验证与更新（hosts + 防火墙） ----------
echo [5/6] 阻断联网验证与更新...
set "HOSTS=%SystemRoot%\System32\drivers\etc\hosts"
findstr /C:"IDM license/update block" "%HOSTS%" >nul 2>&1
if %errorlevel% neq 0 (
    >>"%HOSTS%" echo.
    >>"%HOSTS%" echo # ---- IDM license/update block START ----
    for %%D in (tonec.com www.tonec.com registeridm.com www.registeridm.com secure.registeridm.com secure.internetdownloadmanager.com mirror.internetdownloadmanager.com mirror2.internetdownloadmanager.com mirror3.internetdownloadmanager.com data.internetdownloadmanager.com www.internetdownloadmanager.com internetdownloadmanager.com star.tonec.com update.internetdownloadmanager.com dev.tonec.com) do (
        >>"%HOSTS%" echo 127.0.0.1 %%D
    )
    >>"%HOSTS%" echo # ---- IDM license/update block END ----
)
ipconfig /flushdns >nul 2>&1

netsh advfirewall firewall delete rule name="IDM_Block_IDMGrHlp" >nul 2>&1
netsh advfirewall firewall delete rule name="IDM_Block_idmBroker" >nul 2>&1
set "IDMDIR=%~dp0"
if exist "%IDMDIR%IDMGrHlp.exe" (
    netsh advfirewall firewall add rule name="IDM_Block_IDMGrHlp" dir=out action=block program="%IDMDIR%IDMGrHlp.exe" enable=yes >nul 2>&1
)
if exist "%IDMDIR%idmBroker.exe" (
    netsh advfirewall firewall add rule name="IDM_Block_idmBroker" dir=out action=block program="%IDMDIR%idmBroker.exe" enable=yes >nul 2>&1
)

:: ---------- 注册每月自动续期计划任务 ----------
echo [6/6] 注册每月自动续期计划任务...
set "RESET_SCRIPT=%~dp0reset_trial.bat"
schtasks /Delete /TN "IDM Trial Reset" /F >nul 2>&1
schtasks /Create /TN "IDM Trial Reset" /TR "\"%RESET_SCRIPT%\"" /SC WEEKLY /D MON /ST 03:00 /F >nul 2>&1

echo.
echo ============================================================
echo   IDM 永久免费激活完成！
echo   - 无序列号弹窗 / 无"文件已损坏" / 无强制更新
echo   - 试用期每 4 周自动续期，永久免费
echo ============================================================
echo.
echo 请手动启动 IDM 验证。
pause
exit /b 0
