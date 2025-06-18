@echo off
chcp 65001 >nul
color 0A
setlocal enabledelayedexpansion

:: Устанавливаем локальную версию
set "VERSION=2.1"

:: Проверка обновлений (в начале)
call :check_update

title Універсальне очищення ПК

:: Проверка запуска от имени администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Запустіть файл від імені адміністратора!
    pause
    exit
)

:: Создание резервной папки
set "STAMP=%COMPUTERNAME%_%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%_%TIME:~0,2%-%TIME:~6,2%"
set "STAMP=%STAMP: =0%"
set "BACKUP_ROOT=%~dp0Backup\%STAMP%"
mkdir "!BACKUP_ROOT!" >nul 2>&1

:: Главное меню
:main_menu
cls
echo ==================================================
echo         УНІВЕРСАЛЬНЕ ОЧИЩЕННЯ ПК [v!VERSION!]
echo    Користувач: %username%   ПК: %computername%
echo ==================================================
echo.
echo Виберіть дію:
echo 1. Очистити браузери
echo 2. Очистити месенджери
echo 3. Вимкнення автозапуску всіх програм
echo 4. Відновити з резервної копії
echo 5. Очистити історію провідника та Quick Access
echo 6. Цифровий відбілювач
echo 7. Видалити тимчасові файли
echo 8. Перевірка шкідливих процесів
echo 9. Режим холодного видалення 💣
echo 0. Вихід
echo.
set /p choice=Ваш вибір: 

if "!choice!"=="1" goto browser_select
if "!choice!"=="2" goto messenger_select
if "!choice!"=="3" goto disable_all_startup
if "!choice!"=="4" goto restore_menu
if "!choice!"=="5" goto clear_quick_access
if "!choice!"=="6" goto deep_trace_wipe
if "!choice!"=="7" goto clear_temp_files
if "!choice!"=="8" goto CheckThreats_Debug
if "!choice!"=="9" goto total_wipe
if "!choice!"=="0" exit

echo ❌ Невірний вибір.
pause
goto main_menu



:: Блок обновления
:check_update
set "REPO_BASE=https://raw.githubusercontent.com/sane4ekgs/clenup_sanhez/main"
set "TMPV=%TEMP%\version.txt"
set "TMPB=%TEMP%\clenup.bat"

echo ==================================================
echo (ℹ️) Получаю версию с:
echo      !REPO_BASE!/.version.txt
echo --------------------------------------------------
curl -s -L -o "!TMPV!" "!REPO_BASE!/.version.txt" >nul 2>&1
if exist "!TMPV!" (
    set /p REMOTE_VER=<"!TMPV!"
    del "!TMPV!"
)

if not defined REMOTE_VER (
    echo ⚠️ Не удалось получить версию. Проверку пропущено.
    goto :eof
)

if /I "!REMOTE_VER!"=="!VERSION!" (
    echo ✅ Скрипт актуален (v!VERSION!)
    goto :eof
)

echo 🆕 Доступна новая версія: !REMOTE_VER! (у тебя: !VERSION!)
echo      Загружаю:
echo      !REPO_BASE!/clenup.bat
echo --------------------------------------------------
curl -s -L -o "!TMPB!" "!REPO_BASE!/clenup.bat" >nul 2>&1
if exist "!TMPB!" (
    echo 🔁 Заменяю текущий скрипт...
    copy /Y "!TMPB!" "%~f0" >nul
    if errorlevel 1 (
        echo ❌ Не удалось заменить скрипт!
        pause
        goto :eof
    )
    del "!TMPB!"
    echo ✅ Обновление завершено! Перезапуск...
    echo 🔍 Локальная версия: !VERSION! / Удалённая: !REMOTE_VER!
    timeout /t 2 >nul
    start "" "%~f0"
    exit
) else (
    echo ❌ Ошибка при загрузке с !REPO_BASE!/clenup.bat
)
goto :eof

:clear_quick_access
cls
echo ==== ОЧИСТКА ШВИДКОГО ДОСТУПУ ====
:: Очистка списка недавних файлів
del /f /q "%APPDATA%\Microsoft\Windows\Recent\*" >nul 2>&1

:: Очистка списка часто используемых папок
del /f /q "%APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\*" >nul 2>&1
del /f /q "%APPDATA%\Microsoft\Windows\Recent\CustomDestinations\*" >nul 2>&1

:: Очистка данных быстрого доступа в реестре
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths" /f >nul 2>&1

echo ✅ История быстрого доступа очищена!
pause
goto main_menu

:deep_trace_wipe
cls
echo === 🧼 ОЧИСТКА USB / ЗАПУСКІВ / СЛІДІВ ===

echo ⚠️ Сліди підключень та запусків будуть стерті.
echo 1. Так, очистити
echo 2. Ні, назад
set /p confirm=Ваш вибір (1/2): 
if "%confirm%" NEQ "1" (
    echo ❎ Скасовано.
    pause
    goto main_menu
)

:: Закриваємо провідник та брокер
taskkill /IM explorer.exe /F >nul 2>&1
taskkill /IM RuntimeBroker.exe /F >nul 2>&1

:: 🔌 Очистка історії підключених USB-дисків і флешок
reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\USBSTOR" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2" /f >nul 2>&1

:: 🧠 Видалення історії запусків програм
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /f >nul 2>&1

:: 🧾 Очистка TypedPaths ("Цей комп'ютер" → шлях вручну)
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths" /f >nul 2>&1

:: 🕓 Очистка історії активності
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ActivityHistory" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps" /f >nul 2>&1

:: 🗂️ Видалення Recent Items та thumbcache
del /f /q "%APPDATA%\Microsoft\Windows\Recent\*" >nul 2>&1
del /f /q "%APPDATA%\Microsoft\Windows\Recent Items\*" >nul 2>&1
del /f /q "%APPDATA%\Microsoft\Windows\Explorer\thumbcache*" >nul 2>&1

:: Повертаємо explorer
start explorer.exe

echo ✅ Сліди запусків, USB, історії очищено.
pause
goto main_menu

:clear_temp_files
cls
echo ==== ОЧИСТКА ТИМЧАСОВИХ ФАЙЛІВ ====
:: Очистка кешу та тимчасових файлів Windows
del /f /q "%TEMP%\*" >nul 2>&1
rd /s /q "%TEMP%" >nul 2>&1
cleanmgr /sagerun:1 >nul 2>&1
echo ✅ Тимчасові файли очищені!
pause
goto main_menu


:browser_select
cls
echo ==================================================
echo                 ВИБІР БРАУЗЕРА                     
echo ==================================================
echo 1. Google Chrome
echo 2. Microsoft Edge
echo 3. Mozilla Firefox
echo 4. Opera
echo 5. Brave
echo 0. Назад
set /p bchoice=Ваш вибір: 

if "!bchoice!"=="1" goto browser_chrome
if "!bchoice!"=="2" goto browser_edge
if "!bchoice!"=="3" goto browser_firefox
if "!bchoice!"=="4" goto browser_opera
if "!bchoice!"=="5" goto browser_brave
if "!bchoice!"=="0" goto main_menu

echo ❌ Невірний вибір.
pause
goto browser_select

:: Google Chrome
:browser_chrome
cls
echo ==== GOOGLE CHROME ====
echo 1. Очистити історію
echo 2. Видалити всі дані
echo 0. Назад
set /p ch=Ваш вибір: 

if "!ch!"=="1" goto chrome_history
if "!ch!"=="2" goto chrome_full
if "!ch!"=="0" goto browser_select
echo ❌ Невірний вибір.
pause
goto browser_chrome

:chrome_history
taskkill /F /IM chrome.exe >nul 2>&1
set "CONFIG=%LOCALAPPDATA%\Google\Chrome\User Data\Local State"
set "DATE=%DATE:/=-%_%TIME::=-%"
set "DATE=%DATE: =_%"

:: Отримуємо останній активний профіль
for /f "tokens=2 delims=:" %%L in ('findstr /C:"last_active_profiles" "%CONFIG%"') do (
    set "raw=%%~L"
)
set "raw=%raw:[=%"
set "raw=%raw:]=%"
set "raw=%raw:~1,-1%"
set "PROFILE=%raw%"
if not defined PROFILE set "PROFILE=Default"

set "SRC=%LOCALAPPDATA%\Google\Chrome\User Data\%PROFILE%"
set "DST=%~dp0Backup\Chrome\%DATE%\%PROFILE%"
mkdir "!DST!" >nul 2>&1

if exist "!SRC!\History" (
    xcopy /E /I /Y "!SRC!" "!DST!" >nul
    del /f /q "!SRC!\History" >nul
    echo ✅ Chrome (%PROFILE%): історія очищена, резерв збережено.
) else (
    echo ❌ History у Chrome профілі %PROFILE% не знайдено.
)
pause
goto browser_chrome

:chrome_full
taskkill /F /IM chrome.exe >nul 2>&1
set "DATE=%DATE:/=-%_%TIME::=-%"
set "DATE=%DATE: =_%"
set "SRC=%LOCALAPPDATA%\Google\Chrome"
set "DST=%~dp0Backup\Chrome\%DATE%"
if exist "!SRC!" (
    mkdir "!DST!" >nul 2>&1
    xcopy /E /I /Y "!SRC!" "!DST!" >nul
    rd /s /q "!SRC!"
    echo ✅ Chrome: всі дані видалені, резерв збережено.
) else (
    echo ❌ Chrome не знайдено.
)
pause
goto browser_chrome


:: Microsoft Edge
:browser_edge
cls
echo ==== MICROSOFT EDGE ====
echo 1. Очистити історію
echo 2. Видалити всі дані
echo 0. Назад
set /p ed=Ваш вибір: 

if "!ed!"=="1" goto edge_history
if "!ed!"=="2" goto edge_full
if "!ed!"=="0" goto browser_select
echo ❌ Невірний вибір.
pause
goto browser_edge

:edge_history
taskkill /F /IM msedge.exe >nul 2>&1
set "CONFIG=%LOCALAPPDATA%\Microsoft\Edge\User Data\Local State"
set "DATE=%DATE:/=-%_%TIME::=-%"
set "DATE=%DATE: =_%"

:: Отримуємо останній активний профіль
for /f "tokens=2 delims=:" %%L in ('findstr /C:"last_active_profiles" "%CONFIG%"') do (
    set "raw=%%~L"
)
set "raw=%raw:[=%"
set "raw=%raw:]=%"
set "raw=%raw:~1,-1%"
set "PROFILE=%raw%"
if not defined PROFILE set "PROFILE=Default"

set "SRC=%LOCALAPPDATA%\Microsoft\Edge\User Data\%PROFILE%"
set "DST=%~dp0Backup\Edge\%DATE%\%PROFILE%"
mkdir "!DST!" >nul 2>&1

if exist "!SRC!\History" (
    xcopy /E /I /Y "!SRC!" "!DST!" >nul
    del /f /q "!SRC!\History" >nul
    echo ✅ Chrome (%PROFILE%): історія очищена, резерв збережено.
) else (
    echo ❌ History у Chrome профілі %PROFILE% не знайдено.
)
pause
goto browser_edge


:edge_full
taskkill /F /IM msedge.exe >nul 2>&1
set "DATE=%DATE:/=-%_%TIME::=-%"
set "DATE=%DATE: =_%"
set "SRC=%LOCALAPPDATA%\Microsoft\Edge"
set "DST=%~dp0Backup\Edge\%DATE%"
if exist "!SRC!" (
    mkdir "!DST!" >nul 2>&1
    xcopy /E /I /Y "!SRC!" "!DST!" >nul
    rd /s /q "!SRC!"
    echo ✅ Edge: всі дані видалені, резерв збережено.
) else (
    echo ❌ Edge не знайдено.
)
pause
goto browser_edge

:: Mozilla Firefox
:browser_firefox
cls
echo ==== MOZILLA FIREFOX ====
echo 1. Очистити історію
echo 2. Видалити всі дані
echo 0. Назад
set /p ff=Ваш вибір: 

if "!ff!"=="1" goto firefox_history
if "!ff!"=="2" goto firefox_full
if "!ff!"=="0" goto browser_select
echo ❌ Невірний вибір.
pause
goto browser_firefox

:firefox_history
taskkill /F /IM firefox.exe >nul 2>&1
set "INI=%APPDATA%\Mozilla\Firefox\profiles.ini"
set "DATE=%DATE:/=-%_%TIME::=-%"
set "DATE=%DATE: =_%"
set "DST=%~dp0Backup\Firefox\%DATE%"
set "PROFILE="
set "found="
for /f "tokens=*" %%L in ('type "%INI%"') do (
    echo %%L | findstr /C:"Default=1" >nul && set found=1
    if defined found (
        echo %%L | findstr /C:"Path=" >nul && (
            for /f "tokens=2 delims==" %%P in ("%%L") do set "PROFILE=%%P"
        )
    )
)

if not defined PROFILE (
    for /d %%F in ("%APPDATA%\Mozilla\Firefox\Profiles\*.default-release") do set "PROFILE=%%~nxF"
)

if defined PROFILE (
    xcopy /E /I /Y "%APPDATA%\Mozilla\Firefox\Profiles\%PROFILE%" "!DST!\%PROFILE%" >nul
    del /f /q "%APPDATA%\Mozilla\Firefox\Profiles\%PROFILE%\places.sqlite" >nul
    echo ✅ Firefox (%PROFILE%): історія очищена, резерв збережено.
) else (
    echo ❌ Профіль Firefox не знайдено.
)
pause
goto browser_firefox

:firefox_full
taskkill /F /IM firefox.exe >nul 2>&1

:: Резерв
set "DATE=%DATE:/=-%_%TIME::=-%"
set "DATE=%DATE: =_%"
set "SRC=%APPDATA%\Mozilla\Firefox"
set "DST=%~dp0Backup\Firefox\%DATE%"
if exist "!SRC!" (
    mkdir "!DST!" >nul 2>&1
    xcopy /E /I /Y "!SRC!" "!DST!" >nul
    rd /s /q "!SRC!"
    echo ✅ Firefox: всі дані видалені, резерв збережено.
) else (
    echo ❌ Дані Firefox не знайдено.
)
pause
goto browser_firefox

:: Brave
:browser_brave
cls
echo ==== BRAVE BROWSER ====
echo 1. Очистити історію
echo 2. Видалити всі дані
echo 0. Назад
set /p br=Ваш вибір: 

if "!br!"=="1" goto brave_history
if "!br!"=="2" goto brave_full
if "!br!"=="0" goto browser_select
echo ❌ Невірний вибір.
pause
goto browser_brave

:brave_history
taskkill /F /IM brave.exe >nul 2>&1
set "CONFIG=%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Local State"
set "DATE=%DATE:/=-%_%TIME::=-%"
set "DATE=%DATE: =_%"

:: Отримуємо останній активний профіль
for /f "tokens=2 delims=:" %%L in ('findstr /C:"last_active_profiles" "%CONFIG%"') do (
    set "raw=%%~L"
)
set "raw=%raw:[=%"
set "raw=%raw:]=%"
set "raw=%raw:~1,-1%"
set "PROFILE=%raw%"
if not defined PROFILE set "PROFILE=Default"

set "SRC=%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\%PROFILE%"
set "DST=%~dp0Backup\Brave\%DATE%\%PROFILE%"
mkdir "!DST!" >nul 2>&1

if exist "!SRC!\History" (
    xcopy /E /I /Y "!SRC!" "!DST!" >nul
    del /f /q "!SRC!\History" >nul
    echo ✅ Chrome (%PROFILE%): історія очищена, резерв збережено.
) else (
    echo ❌ History у Chrome профілі %PROFILE% не знайдено.
)
pause
goto browser_brave


:brave_full
taskkill /F /IM brave.exe >nul 2>&1
set "DATE=%DATE:/=-%_%TIME::=-%"
set "DATE=%DATE: =_%"
set "SRC=%LOCALAPPDATA%\BraveSoftware\Brave-Browser"
set "DST=%~dp0Backup\Brave\%DATE%"
if exist "!SRC!" (
    mkdir "!DST!" >nul 2>&1
    xcopy /E /I /Y "!SRC!" "!DST!" >nul
    rd /s /q "!SRC!"
    echo ✅ Brave: всі дані видалені, резерв збережено.
) else (
    echo ❌ Brave не знайдено.
)
pause
goto browser_brave

 :: Opera
:browser_opera
cls
echo ==== OPERA ====
echo 1. Очистити історію
echo 2. Видалити всі дані
echo 0. Назад
set /p op=Ваш вибір: 

if "!op!"=="1" goto opera_history
if "!op!"=="2" goto opera_full
if "!op!"=="0" goto browser_select
echo ❌ Невірний вибір.
pause
goto browser_opera

:opera_history
taskkill /F /IM opera.exe >nul 2>&1
set "DATE=%DATE:/=-%_%TIME::=-%"
set "DATE=%DATE: =_%"
set "DST=%~dp0Backup\Opera\%DATE%"
mkdir "!DST!" >nul 2>&1
xcopy /E /I /Y "%APPDATA%\Opera Software\Opera Stable" "!DST!\Opera Stable" >nul
del /f /q "%APPDATA%\Opera Software\Opera Stable\History" >nul
echo ✅ Opera: історія очищена, резерв збережено.
pause
goto browser_opera

:opera_full
taskkill /F /IM opera.exe >nul 2>&1
set "DATE=%DATE:/=-%_%TIME::=-%"
set "DATE=%DATE: =_%"
set "SRC=%APPDATA%\Opera Software"
set "DST=%~dp0Backup\Opera\%DATE%"
if exist "!SRC!" (
    mkdir "!DST!" >nul 2>&1
    xcopy /E /I /Y "!SRC!" "!DST!" >nul
    rd /s /q "!SRC!"
    echo ✅ Opera: всі дані видалені, резерв збережено.
) else (
    echo ❌ Opera не знайдено.
)
pause
goto browser_opera
:: Меню мессенджеров
:messenger_select
cls
echo ==================================================
echo               ВИБІР МЕСЕНДЖЕРА                  
echo ==================================================
echo 1. Telegram
echo 2. Discord
echo 3. Skype
echo 4. Viber
echo 5. WhatsApp
echo 6. Signal
echo 0. Назад
set /p m=Ваш вибір: 
if "!m!"=="1" goto m_telegram
if "!m!"=="2" goto m_discord
if "!m!"=="3" goto m_skype
if "!m!"=="4" goto m_viber
if "!m!"=="5" goto m_whatsapp
if "!m!"=="6" goto m_signal
if "!m!"=="0" goto main_menu

echo ❌ Невірний вибір.
pause
goto messenger_select

:m_telegram
cls
set "SRC=%APPDATA%\Telegram Desktop"
echo ==== TELEGRAM ====
echo 1. Кеш
echo 2. Повне очищення
echo 0. Назад
set /p tg=Ваш вибір:
if "!tg!"=="0" goto messenger_select
taskkill /IM telegram.exe /F >nul

if "!tg!"=="1" call :create_backup "!SRC!\tdata\cache" "Telegram" "Cache" & rd /s /q "!SRC!\tdata\cache"
if "!tg!"=="2" call :create_backup "!SRC!" "Telegram" "Full" & rd /s /q "!SRC!"

pause
goto messenger_select

:m_discord
cls
set "SRC=%APPDATA%\discord"
echo ==== DISCORD ====
echo 1. Кеш
echo 2. Повне очищення
echo 0. Назад
set /p dc=Ваш вибір:
if "!dc!"=="0" goto messenger_select
taskkill /IM discord.exe /F >nul

if "!dc!"=="1" call :create_backup "!SRC!\Cache" "Discord" "Cache" & rd /s /q "!SRC!\Cache"
if "!dc!"=="2" call :create_backup "!SRC!" "Discord" "Full" & rd /s /q "!SRC!"

pause
goto messenger_select

:m_skype
cls
set "SRC=%APPDATA%\Skype"
echo ==== SKYPE ====
echo 1. Кеш
echo 2. Повне очищення
echo 0. Назад
set /p sk=Ваш вибір:
if "!sk!"=="0" goto messenger_select
taskkill /IM skype.exe /F >nul

if "!sk!"=="1" call :create_backup "!SRC!\My Skype Received Files" "Skype" "Files" & rd /s /q "!SRC!\My Skype Received Files"
if "!sk!"=="2" call :create_backup "!SRC!" "Skype" "Full" & rd /s /q "!SRC!"

pause
goto messenger_select

:m_viber
cls
set "SRC=%APPDATA%\ViberPC"
echo ==== VIBER ====
echo 1. Кеш
echo 2. Повне очищення
echo 0. Назад
set /p vb=Ваш вибір:
if "!vb!"=="0" goto messenger_select
taskkill /IM Viber.exe /F >nul

if "!vb!"=="1" call :create_backup "!SRC!\cache" "Viber" "Cache" & rd /s /q "!SRC!\cache"
if "!vb!"=="2" call :create_backup "!SRC!" "Viber" "Full" & rd /s /q "!SRC!"

pause
goto messenger_select

:m_whatsapp
cls
set "SRC=%APPDATA%\WhatsApp"
echo ==== WHATSAPP ====
echo 1. Кеш
echo 2. Повне очищення
echo 0. Назад
set /p wa=Ваш вибір:
if "!wa!"=="0" goto messenger_select
taskkill /IM WhatsApp.exe /F >nul

if "!wa!"=="1" call :create_backup "!SRC!\Cache" "WhatsApp" "Cache" & rd /s /q "!SRC!\Cache"
if "!wa!"=="2" call :create_backup "!SRC!" "WhatsApp" "Full" & rd /s /q "!SRC!"

pause
goto messenger_select

:m_signal
cls
set "SRC=%APPDATA%\Signal"
echo ==== SIGNAL ====
echo 1. Кеш
echo 2. Повне очищення
echo 0. Назад
set /p sg=Ваш вибір:
if "!sg!"=="0" goto messenger_select
taskkill /IM signal.exe /F >nul

if "!sg!"=="1" call :create_backup "!SRC!\Cache" "Signal" "Cache" & rd /s /q "!SRC!\Cache"
if "!sg!"=="2" call :create_backup "!SRC!" "Signal" "Full" & rd /s /q "!SRC!"

pause
goto messenger_select

:disable_all_startup
cls
echo ==== ВИМКНЕННЯ АВТОЗАПУСКУ ВСІХ ПРОГРАМ ====

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Запустіть файл від імені адміністратора!
    pause
    goto main_menu
)

:: Чистим HKCU
for /f "tokens=1" %%A in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" ^| findstr /i "\\"') do (
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v %%A /f >nul 2>&1
)

:: Также чистим HKLM, если запущено с админ-доступом
for /f "tokens=1" %%A in ('reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" ^| findstr /i "\\"') do (
    reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v %%A /f >nul 2>&1
)

echo ✅ Усі програми видалено з автозапуску (HKCU + HKLM)
pause
goto main_menu

:restore_menu
cls
echo ==================================================
echo        ВІДНОВЛЕННЯ З РЕЗЕРВНОЇ КОПІЇ
echo ==================================================
echo 1. Відновити з резерву
echo 2. Видалити одну резервну копію
echo 3. Видалити ВСІ резервні копії
echo 0. Назад
set /p restore_choice=Ваш вибір: 

if "%restore_choice%"=="1" goto restore_select
if "%restore_choice%"=="2" goto delete_one_backup
if "%restore_choice%"=="3" goto delete_all_backups
if "%restore_choice%"=="0" goto main_menu

echo ❌ Невірний вибір.
pause
goto restore_menu

:restore_select
cls
echo 📦 ДОСТУПНІ ЗАСТОСУНКИ ДЛЯ ВІДНОВЛЕННЯ:

setlocal enabledelayedexpansion
set i=0
for /d %%F in ("%~dp0Backup\*") do (
    set /a i+=1
    set "apps[!i!]=%%~nxF"
    echo !i!. %%~nxF
)

echo 0. Назад
set /p appnum=Виберіть застосунок:

if "%appnum%"=="0" goto restore_menu

set "APPNAME="
if defined apps[%appnum%] (
    set "APPNAME=!apps[%appnum%]!"
) else (
    echo ❌ Невірний номер!
    pause
    goto restore_select
)

cls
echo 📂 Доступні резерви для %APPNAME%:
set j=0
for /d %%D in ("%~dp0Backup\%APPNAME%\*") do (
    set /a j+=1
    set "dates[!j!]=%%~nxD"
    echo !j!. %%~nxD
)

echo 0. Назад
set /p datenum=Виберіть копію:

if "%datenum%"=="0" goto restore_select

set "DATESTR="
if defined dates[%datenum%] (
    set "DATESTR=!dates[%datenum%]!"
) else (
    echo ❌ Невірна дата!
    pause
    goto restore_select
)

:: Автовизначення APPDATA/LOCALAPPDATA
set "TARGET=APPDATA"
if /I "%APPNAME%"=="Chrome" set "TARGET=LOCALAPPDATA"
if /I "%APPNAME%"=="Edge" set "TARGET=LOCALAPPDATA"
if /I "%APPNAME%"=="Firefox" set "TARGET=APPDATA"
if /I "%APPNAME%"=="Brave" set "TARGET=LOCALAPPDATA"
if /I "%APPNAME%"=="Opera" set "TARGET=APPDATA"

call :restore_backup "%APPNAME%" "%DATESTR%" "%TARGET%"
endlocal
pause
goto restore_menu

:: Пример:
:: call :restore_backup "Chrome" "2024-07-15_12-34" "LOCALAPPDATA"
:: call :restore_backup "Discord" "Full" "APPDATA"

:restore_messengers
cls
echo ==== ВІДНОВЛЕННЯ МЕСЕНДЖЕРІВ ====

echo 📂 Доступні месенджери:
setlocal enabledelayedexpansion
set i=0
for /d %%M in ("%~dp0Backup\*") do (
    set /a i+=1
    set "msg[!i!]=%%~nxM"
    echo !i!. %%~nxM
)

echo 0. Назад
set /p mnum=Введіть номер месенджера: 

if "%mnum%"=="0" goto restore_menu

set "APPNAME="
if defined msg[%mnum%] (
    set "APPNAME=!msg[%mnum%]!"
) else (
    echo ❌ Невірний номер месенджера!
    pause
    goto restore_messengers
)

cls
echo 📂 Доступні резервні копії для %APPNAME%:
set j=0
for /d %%D in ("%~dp0Backup\%APPNAME%\*") do (
    set /a j+=1
    set "bk[!j!]=%%~nxD"
    echo !j!. %%~nxD
)

echo 0. Назад
set /p bnum=Введіть номер резервної копії:

if "%bnum%"=="0" goto restore_messengers

set "BACKNAME="
if defined bk[%bnum%] (
    set "BACKNAME=!bk[%bnum%]!"
) else (
    echo ❌ Невірний номер копії!
    pause
    goto restore_messengers
)

call :restore_backup "%APPNAME%" "%BACKNAME%" "APPDATA"
endlocal
pause
goto restore_menu


:delete_all_backups
cls
echo 🧨 ВИДАЛЕННЯ ВСІХ РЕЗЕРВНИХ КОПІЙ
echo --------------------------------------------------
echo ⚠️ Це дія безповоротна!
echo 1. Так, видалити всі резерви
echo 2. Ні, повернутись назад
set /p answer=Ваш вибір (1/2): 

if "%answer%"=="1" (
    if exist "%~dp0Backup" (
        rd /s /q "%~dp0Backup"
        echo ✅ Усі резервні копії видалено!
    ) else (
        echo ❌ Папка резервних копій не знайдена.
    )
    pause
    goto restore_menu
) else if "%answer%"=="2" (
    echo ❎ Скасовано.
    pause
    goto restore_menu
) else (
    echo ❌ Невірний вибір. Спробуйте ще раз.
    pause
    goto delete_all_backups
)

 :: Перевірка шкідливих процесів
:CheckThreats_Debug
 :: Створення логів
set "LOG_DIR=%~dp0Logs"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
set "LOG_FILE=%LOG_DIR%\malware_check_%DATE:/=_%_%TIME::=_%.txt"

cls
echo ================================
echo 🛡️   АНАЛІЗ ПРОЦЕСІВ WINDOWS
echo ================================
echo.
echo 🕵️ Виконується перевірка...
echo.

:: Список ключових слів
setlocal enabledelayedexpansion
set "suspiciousList=keylogger miner crack patch cheat botnet rat hack steal clipper infostealer dropper remote"

:: Починаємо лог
echo 📅 Дата: %DATE% %TIME% > "%LOG_FILE%"
echo ============================== >> "%LOG_FILE%"
echo 🔍 Виявлені підозрілі процеси: >> "%LOG_FILE%"
echo ============================== >> "%LOG_FILE%"

set "FOUND=0"
for /f "skip=3 tokens=*" %%P in ('tasklist') do (
    set "line=%%P"
    for %%K in (!suspiciousList!) do (
        echo !line! | find /i "%%K" >nul && (
            echo ⚠️ !line!
            echo ⚠️ !line! >> "%LOG_FILE%"
            set /a FOUND+=1
        )
    )
)

echo. >> "%LOG_FILE%"
if "!FOUND!"=="0" (
    echo ✅ Нічого підозрілого не знайдено. >> "%LOG_FILE%"
    echo ✅ Нічого підозрілого не знайдено.
) else (
    echo ❗ Знайдено !FOUND! підозрілих процесів! >> "%LOG_FILE%"
    echo ❗ Знайдено !FOUND! підозрілих процесів!
)

echo.
echo 📄 Звіт також збережено тут: %LOG_FILE%
pause
goto main_menu

:total_wipe
cls
echo === ❄️ РЕЖИМ ХОЛОДНОГО ВИДАЛЕННЯ ===
echo ⚠️ Всі сліди будуть стерті негайно, без відновлення!
echo 1. Так, я розумію ризики
echo 2. Ні, повернутись назад
set /p confirm=Ваш вибір (1/2): 

if "%confirm%" NEQ "1" (
    echo ❎ Скасовано.
    pause
    goto main_menu
)

timeout /t 3 >nul



:: === Завершення процесів
taskkill /F /IM chrome.exe >nul 2>&1
taskkill /F /IM msedge.exe >nul 2>&1
taskkill /F /IM firefox.exe >nul 2>&1
taskkill /F /IM brave.exe >nul 2>&1
taskkill /F /IM opera.exe >nul 2>&1
taskkill /F /IM telegram.exe >nul 2>&1
taskkill /F /IM discord.exe >nul 2>&1
taskkill /F /IM skype.exe >nul 2>&1

:: === Браузери
rd /s /q "%LOCALAPPDATA%\Google\Chrome" >nul 2>&1
rd /s /q "%LOCALAPPDATA%\Microsoft\Edge" >nul 2>&1
rd /s /q "%APPDATA%\Mozilla\Firefox" >nul 2>&1
rd /s /q "%LOCALAPPDATA%\BraveSoftware" >nul 2>&1
rd /s /q "%APPDATA%\Opera Software" >nul 2>&1

:: === Месенджери
rd /s /q "%APPDATA%\Telegram Desktop" >nul 2>&1
rd /s /q "%APPDATA%\discord" >nul 2>&1
rd /s /q "%APPDATA%\Skype" >nul 2>&1

:: === Провідник
del /f /q "%APPDATA%\Microsoft\Windows\Recent\*" >nul 2>&1
del /f /q "%APPDATA%\Microsoft\Windows\Recent Items\*" >nul 2>&1
del /f /q "%APPDATA%\Microsoft\Windows\Explorer\thumbcache*" >nul 2>&1

echo ❄️ Усі цифрові сліди стерто. Завдання виконано.
pause
goto main_menu



:create_backup
:: %1 — исходный путь (или файл)
:: %2 — мессенджер (папка в Backup)
:: %3 — тип копии (Cache, Full и т.п.)
set "SRC=%~1"
set "APP=%~2"
set "TYPE=%~3"
set "DST=!BACKUP_ROOT!\%APP%\%TYPE%"

if exist "!SRC!" (
    mkdir "!DST!" >nul
    xcopy /E /I /Y "!SRC!" "!DST!" >nul
    echo ✅ Резерв для %APP%\%TYPE% збережено: !DST!
) else (
    echo ❌ Джерело %SRC% не знайдено.
)
goto :eof



:restore_backup
:: %1 — ім’я папки в Backup (напр. Telegram)
:: %2 — підпапка (датована або Cache/Full)
:: %3 — APPDATA або LOCALAPPDATA

set "APP=%~1"
set "SUB=%~2"
set "TARGET=%~3"

if /I "%TARGET%"=="APPDATA" (
    set "DEST=%APPDATA%\%APP%"
) else (
    set "DEST=%LOCALAPPDATA%\%APP%"
)

set "SRC=%~dp0Backup\%APP%\%SUB%"

if not exist "!SRC!" (
    echo ❌ Резерв не знайдено: !SRC!
    goto :eof
)

echo 🔁 Відновлення: !APP! ← !SUB!
xcopy /E /I /Y "!SRC!" "!DEST!" >nul

if errorlevel 1 (
    echo ⚠️ Помилка копіювання у !DEST!
) else (
    echo ✅ Відновлено успішно до !DEST!
)

goto :eof
