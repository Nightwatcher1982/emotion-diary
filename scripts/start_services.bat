@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: AI情绪日记APP - Windows服务启动脚本
:: 支持启动、重启、停止、状态检查等功能

title AI情绪日记APP - 服务管理

:: 配置
set BACKEND_DIR=backend
set FRONTEND_DIR=frontend
set BACKEND_PORT=8000
set FRONTEND_PORT=5173
set LOG_DIR=logs

:: 创建日志目录
if not exist %LOG_DIR% mkdir %LOG_DIR%

:: 日志文件
set BACKEND_LOG=%LOG_DIR%\backend.log
set FRONTEND_LOG=%LOG_DIR%\frontend.log
set SCRIPT_LOG=%LOG_DIR%\services.log

:: 颜色定义 (Windows 10+)
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "PURPLE=[95m"
set "CYAN=[96m"
set "NC=[0m"

:: 记录日志
echo %date% %time% - 脚本启动 - 命令: %* >> %SCRIPT_LOG%

:: 检查端口是否被占用
:check_port
set port=%1
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%port% "') do (
    if "%%a" neq "" (
        set pid=%%a
        exit /b 0
    )
)
exit /b 1

:: 杀死进程
:kill_process
set target_pid=%1
if defined target_pid (
    taskkill /PID %target_pid% /F >nul 2>&1
    if !errorlevel! equ 0 (
        echo %GREEN%✅ 进程已终止 ^(PID: %target_pid%^)%NC%
    )
)
exit /b 0

:: 停止服务
:stop_service
set service_name=%1
set port=%2

echo 正在停止 %service_name%...
call :check_port %port%
if !errorlevel! equ 0 (
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%port% "') do (
        call :kill_process %%a
    )
    echo %GREEN%✅ %service_name% 已停止%NC%
) else (
    echo %YELLOW%⚠️  %service_name% 未在运行%NC%
)
exit /b 0

:: 检查服务状态
:check_service_status
set service_name=%1
set port=%2

call :check_port %port%
if !errorlevel! equ 0 (
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%port% "') do (
        echo %GREEN%✅ %service_name% 正在运行%NC% ^(PID: %%a, Port: %port%^)
        exit /b 0
    )
) else (
    echo %RED%❌ %service_name% 未运行%NC% ^(Port: %port%^)
    exit /b 1
)

:: 启动后端服务
:start_backend
echo 正在启动后端服务...

:: 检查后端目录
if not exist %BACKEND_DIR% (
    echo %RED%错误: 后端目录 %BACKEND_DIR% 不存在%NC%
    exit /b 1
)

:: 检查Django项目
if not exist %BACKEND_DIR%\manage.py (
    echo %RED%错误: Django项目文件 manage.py 不存在%NC%
    exit /b 1
)

:: 启动Django服务
cd %BACKEND_DIR%
start /b python manage.py runserver 127.0.0.1:%BACKEND_PORT% > ..\%BACKEND_LOG% 2>&1
cd ..

:: 等待服务启动
timeout /t 3 /nobreak >nul

:: 验证启动状态
call :check_port %BACKEND_PORT%
if !errorlevel! equ 0 (
    echo %GREEN%✅ 后端服务启动成功%NC% ^(Port: %BACKEND_PORT%^)
    exit /b 0
) else (
    echo %RED%❌ 后端服务启动失败%NC%
    exit /b 1
)

:: 启动前端服务
:start_frontend
echo 正在启动前端服务...

:: 检查前端目录
if not exist %FRONTEND_DIR% (
    echo %RED%错误: 前端目录 %FRONTEND_DIR% 不存在%NC%
    exit /b 1
)

:: 检查package.json
if not exist %FRONTEND_DIR%\package.json (
    echo %RED%错误: 前端项目文件 package.json 不存在%NC%
    exit /b 1
)

:: 检查node_modules
if not exist %FRONTEND_DIR%\node_modules (
    echo 安装前端依赖...
    cd %FRONTEND_DIR%
    call npm install
    cd ..
)

:: 启动前端服务
cd %FRONTEND_DIR%
start /b npm run dev:h5 > ..\%FRONTEND_LOG% 2>&1
cd ..

:: 等待服务启动
timeout /t 5 /nobreak >nul

:: 验证启动状态
call :check_port %FRONTEND_PORT%
if !errorlevel! equ 0 (
    echo %GREEN%✅ 前端服务启动成功%NC% ^(Port: %FRONTEND_PORT%^)
    exit /b 0
) else (
    echo %RED%❌ 前端服务启动失败%NC%
    exit /b 1
)

:: 显示服务状态
:show_status
echo %CYAN%📊 AI情绪日记APP - 服务状态%NC%
echo ================================
call :check_service_status "后端服务" %BACKEND_PORT%
set backend_status=!errorlevel!
call :check_service_status "前端服务" %FRONTEND_PORT%
set frontend_status=!errorlevel!
echo ================================

if !backend_status! equ 0 if !frontend_status! equ 0 (
    echo %GREEN%🎉 所有服务运行正常%NC%
    echo.
    echo %YELLOW%📱 访问地址:%NC%
    echo    前端应用: %BLUE%http://localhost:%FRONTEND_PORT%%NC%
    echo    后端API:  %BLUE%http://127.0.0.1:%BACKEND_PORT%%NC%
    echo    测试账号: %PURPLE%testuser / testpass123%NC%
) else (
    echo %RED%⚠️  部分服务未运行%NC%
)
exit /b 0

:: 启动所有服务
:start_all
echo %CYAN%🚀 AI情绪日记APP - 启动所有服务%NC%
echo ================================

:: 检查并停止已运行的服务
call :check_port %BACKEND_PORT%
if !errorlevel! equ 0 (
    echo %YELLOW%⚠️  后端服务已在运行，正在重启...%NC%
    call :stop_service "后端服务" %BACKEND_PORT%
    timeout /t 2 /nobreak >nul
)

call :check_port %FRONTEND_PORT%
if !errorlevel! equ 0 (
    echo %YELLOW%⚠️  前端服务已在运行，正在重启...%NC%
    call :stop_service "前端服务" %FRONTEND_PORT%
    timeout /t 2 /nobreak >nul
)

:: 启动后端
call :start_backend
if !errorlevel! equ 0 (
    timeout /t 2 /nobreak >nul
    :: 启动前端
    call :start_frontend
    if !errorlevel! equ 0 (
        echo.
        echo %GREEN%🎉 所有服务启动完成！%NC%
        echo.
        call :show_status
    ) else (
        echo %RED%❌ 前端服务启动失败%NC%
        exit /b 1
    )
) else (
    echo %RED%❌ 后端服务启动失败%NC%
    exit /b 1
)
exit /b 0

:: 停止所有服务
:stop_all
echo %CYAN%🛑 AI情绪日记APP - 停止所有服务%NC%
echo ================================

call :stop_service "前端服务" %FRONTEND_PORT%
call :stop_service "后端服务" %BACKEND_PORT%

echo %GREEN%✅ 所有服务已停止%NC%
exit /b 0

:: 重启所有服务
:restart_all
echo %CYAN%🔄 AI情绪日记APP - 重启所有服务%NC%
echo ================================

call :stop_all
timeout /t 3 /nobreak >nul
call :start_all
exit /b 0

:: 查看日志
:show_logs
set service=%1

if "%service%"=="backend" (
    echo %CYAN%📋 后端服务日志 ^(最近50行^):%NC%
    echo ================================
    if exist %BACKEND_LOG% (
        powershell "Get-Content '%BACKEND_LOG%' | Select-Object -Last 50"
    ) else (
        echo 日志文件不存在
    )
) else if "%service%"=="frontend" (
    echo %CYAN%📋 前端服务日志 ^(最近50行^):%NC%
    echo ================================
    if exist %FRONTEND_LOG% (
        powershell "Get-Content '%FRONTEND_LOG%' | Select-Object -Last 50"
    ) else (
        echo 日志文件不存在
    )
) else if "%service%"=="script" (
    echo %CYAN%📋 脚本运行日志 ^(最近50行^):%NC%
    echo ================================
    if exist %SCRIPT_LOG% (
        powershell "Get-Content '%SCRIPT_LOG%' | Select-Object -Last 50"
    ) else (
        echo 日志文件不存在
    )
) else (
    echo %CYAN%📋 所有服务日志:%NC%
    echo ================================
    echo %YELLOW%后端日志:%NC%
    if exist %BACKEND_LOG% (
        powershell "Get-Content '%BACKEND_LOG%' | Select-Object -Last 20"
    ) else (
        echo 无日志文件
    )
    echo.
    echo %YELLOW%前端日志:%NC%
    if exist %FRONTEND_LOG% (
        powershell "Get-Content '%FRONTEND_LOG%' | Select-Object -Last 20"
    ) else (
        echo 无日志文件
    )
)
exit /b 0

:: 显示帮助信息
:show_help
echo %CYAN%🔧 AI情绪日记APP - 服务管理脚本%NC%
echo ================================
echo 用法: %~nx0 [命令] [选项]
echo.
echo %YELLOW%可用命令:%NC%
echo   start, s       - 启动所有服务
echo   stop           - 停止所有服务
echo   restart, r     - 重启所有服务
echo   status, st     - 查看服务状态
echo   logs [service] - 查看日志 ^(backend/frontend/script/all^)
echo   help, h        - 显示帮助信息
echo.
echo %YELLOW%示例:%NC%
echo   %~nx0 start       # 启动所有服务
echo   %~nx0 restart     # 重启所有服务
echo   %~nx0 status      # 查看状态
echo   %~nx0 logs backend # 查看后端日志
echo.
echo %YELLOW%服务信息:%NC%
echo   后端服务: Django ^(端口 %BACKEND_PORT%^)
echo   前端服务: Vite/Uniapp ^(端口 %FRONTEND_PORT%^)
echo   日志目录: %LOG_DIR%\
exit /b 0

:: 主程序
if "%1"=="" goto show_help
if "%1"=="start" goto start_all
if "%1"=="s" goto start_all
if "%1"=="stop" goto stop_all
if "%1"=="restart" goto restart_all
if "%1"=="r" goto restart_all
if "%1"=="status" goto show_status
if "%1"=="st" goto show_status
if "%1"=="logs" (
    call :show_logs %2
    goto end
)
if "%1"=="help" goto show_help
if "%1"=="h" goto show_help
goto show_help

:end
pause 