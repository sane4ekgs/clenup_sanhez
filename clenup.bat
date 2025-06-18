@echo off
chcp 65001 >nul
color 0A
setlocal enabledelayedexpansion

:: Пропустити повторне оновлення після заміни файлу
if exist "%TEMP%\sanchez_updated.flag" (
    del "%TEMP%\sanchez_updated.flag"
    goto main_menu
)

:: Встановлення локальної версії з файлу
set "VERFILE=%~dp0version.txt"
if exist "!VERFILE!" (
    set /p VERSION=<"!VERFILE!"
) else (
    set "VERSION=НЕВІДОМА"
)

:: Перевірка оновлень (на початку)
call :check_update

::echo 🔍 Отримана версія: "!REMOTE_VER!"
::echo 🔍 Локальна версія: "!VERSION!"
::pause

:: Заголовок вікна
title Універсальне очищення ПК

:: Перевірка запуску від імені адміністратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Запустіть файл від імені адміністратора!
    pause
    exit
)

:: Створення папки для резервної копії
set "STAMP=%COMPUTERNAME%%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%%TIME:~0,2%-%TIME:~6,2%"
set "STAMP=%STAMP: =0%"
set "BACKUP_ROOT=%~dp0Backup%STAMP%"
mkdir "!BACKUP_ROOT!" >nul 2>&1

:: Головне меню (тимчасово заглушка)
echo === Головне меню ===
pause

:main_menu
cls
echo ==================================================
echo       🌟 ВАС ВІТАЄ УНІВЕРСАЛЬНИЙ ПОМІЧНИК 🌟
echo          >>>  SANCHEZ  v!VERSION!  <<<
echo --------------------------------------------------
echo 👤 Користувач: %USERNAME%    🖥️ ПК: %COMPUTERNAME%
echo ==================================================
echo.
echo Оберіть дію:
echo 1. 🌐 Очистити браузери
echo 2. 💬 Очистити месенджери
echo 3. 🚫 Вимкнути автозапуск усіх програм
echo 4. ♻️ Відновити з резервної копії
echo 5. 🧹 Очистити Провідник та Швидкий доступ
echo 6. 🕵️‍♂️ Цифровий відбілювач (глибоке очищення)
echo 7. 🗑️ Видалити тимчасові файли
echo 8. 🛡️ Перевірити шкідливі процеси
echo 9. 💣 Режим холодного видалення (безповоротно)
echo 0. ❌ Вийти з програми
echo.
set /p choice=Ваш вибір: 
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

:: === Блок оновлення ===
:check_update
set "REPO_BASE=https://raw.githubusercontent.com/sane4ekgs/clenup_sanhez/main"
set "TMPV=%TEMP%\version.txt"
set "TMPB=%TEMP%\clenup.bat"

:: Виводить повідомлення про завантаження оновлення
::echo ==================================================
::echo (ℹ️) Отримую версію з:
::echo      !REPO_BASE!/.version.txt
::echo --------------------------------------------------
::echo 👉 Завантажую версію...

curl -s -L -o "%~dp0version.txt" "https://raw.githubusercontent.com/sane4ekgs/clenup_sanhez/main/.version.txt"
curl -sS -L -o "!TMPV!" "!REPO_BASE!/.version.txt"

::type "!TMPV!"
::pause

if exist "!TMPV!" (
    set /p REMOTE_VER=<"!TMPV!"
    del "!TMPV!"
)

if not defined REMOTE_VER (
    echo ⚠️ Не вдалося отримати версію. Перевірку пропущено.
    goto :eof
)

if /I "!REMOTE_VER!"=="!VERSION!" (
    echo ✅ Скрипт актуальний (v!VERSION!)
    goto :eof
)

::echo 🆕 Доступна нова версія: !REMOTE_VER! (у вас: !VERSION!)
::echo      Завантажую:
::echo      !REPO_BASE!/clenup.bat
::echo --------------------------------------------------

curl -sS -L -o "!TMPB!" "!REPO_BASE!/clenup.bat"

if exist "!TMPB!" (
    ::echo 🔁 Замінюю поточний скрипт...
    copy /Y "!TMPB!" "%~f0" >nul
    ::if errorlevel 1 (
       :: echo ❌ Не вдалося замінити скрипт!
       :: pause
       :: goto :eof
    )
    del "!TMPB!"
    echo ✅ Оновлення завершено! Перезапуск...

    :: Встановлюємо прапорець, щоб при перезапуску не було оновлення
    echo updated > "%TEMP%\sanchez_updated.flag"

    echo 🔍 Локальна версія: !VERSION! / Віддалена: !REMOTE_VER!
    ::timeout /t 2 >nul
    start "" "%~f0"
    exit
) else (
    echo ❌ Помилка під час завантаження з !REPO_BASE!/clenup.bat
)

goto :eof



:clear_quick_access
cls
echo ==== ОЧИСТКА ШВИДКОГО ДОСТУПУ ====
del /f /q "%APPDATA%\Microsoft\Windows\Recent\*" >nul 2>&1
del /f /q "%APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\*" >nul 2>&1
del /f /q "%APPDATA%\Microsoft\Windows\Recent\CustomDestinations\*" >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths" /f >nul 2>&1
echo ✅ Історія швидкого доступу очищена!
pause
goto main_menu

:deep_trace_wipe
cls
echo === 🧼 ОЧИЩЕННЯ USB / ЗАПУСКІВ / СЛІДІВ ===

echo ⚠️ Сліди підключень та запусків будуть видалені.
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

:: 🔌 Очищення історії підключених USB-дисків і флешок
reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\USBSTOR" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2" /f >nul 2>&1

:: 🧠 Видалення історії запуску програм
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /f >nul 2>&1

:: 🧾 Очищення TypedPaths ("Цей комп'ютер" → шлях вручну)
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths" /f >nul 2>&1

:: 🕓 Очищення історії активності
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ActivityHistory" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps" /f >nul 2>&1

:: 🗂️ Видалення Recent Items та thumbcache
del /f /q "%APPDATA%\Microsoft\Windows\Recent\*" >nul 2>&1
del /f /q "%APPDATA%\Microsoft\Windows\Recent Items\*" >nul 2>&1
del /f /q "%APPDATA%\Microsoft\Windows\Explorer\thumbcache*" >nul 2>&1

:: Повертаємо провідник
start explorer.exe

echo ✅ Сліди запусків, USB, історії очищено.
pause
goto main_menu

:clear_temp_files
cls
echo ==== ОЧИСТКА ТИМЧАСОВИХ ФАЙЛІВ ====
:: Очищення кешу та тимчасових файлів Windows
rd /s /q "%TEMP%" >nul 2>&1
mkdir "%TEMP%" >nul 2>&1
cleanmgr /sagerun:1 >nul 2>&1
echo ✅ Тимчасові файли очищені!
pause
goto main_menu




:: ----------- МЕНЮ БРАУЗЕРІВ -----------

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

if "%bchoice%"=="1" goto browser_chrome
if "%bchoice%"=="2" goto browser_edge
if "%bchoice%"=="3" goto browser_firefox
if "%bchoice%"=="4" goto browser_opera
if "%bchoice%"=="5" goto browser_brave
if "%bchoice%"=="0" goto main_menu

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

if "%ch%"=="1" goto chrome_history
if "%ch%"=="2" goto chrome_full
if "%ch%"=="0" goto browser_select
echo ❌ Невірний вибір.
pause
goto browser_chrome

:chrome_history
taskkill /F /IM chrome.exe >nul 2>&1
set "CONFIG=%LOCALAPPDATA%\Google\Chrome\User Data\Local State"
set "DATE=%DATE:/=-%_%TIME::=-%"
set "DATE=%DATE: =_%"

:: Отримуємо останній активний профіль
for /f "tokens=2 delims=:" %%L in ('findstr /C:"last_active_profiles" "%CONFIG%" 2^>nul') do (
    set "raw=%%~L"
)
set "raw=%raw:[=%"
set "raw=%raw:]=%"
set "raw=%raw:~1,-1%"
set "PROFILE=%raw%"
if not defined PROFILE set "PROFILE=Default"

set "SRC=%LOCALAPPDATA%\Google\Chrome\User Data\%PROFILE%"
set "DST=%BACKUP_ROOT%\Chrome\%DATE%\%PROFILE%"
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
set "DST=%BACKUP_ROOT%\Chrome\%DATE%"
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

if "%ed%"=="1" goto edge_history
if "%ed%"=="2" goto edge_full
if "%ed%"=="0" goto browser_select
echo ❌ Невірний вибір.
pause
goto browser_edge

:edge_history
taskkill /F /IM msedge.exe >nul 2>&1
set "CONFIG=%LOCALAPPDATA%\Microsoft\Edge\User Data\Local State"
set "DATE=%DATE:/=-%_%TIME::=-%"
set "DATE=%DATE: =_%"

for /f "tokens=2 delims=:" %%L in ('findstr /C:"last_active_profiles" "%CONFIG%" 2^>nul') do (
    set "raw=%%~L"
)
set "raw=%raw:[=%"
set "raw=%raw:]=%"
set "raw=%raw:~1,-1%"
set "PROFILE=%raw%"
if not defined PROFILE set "PROFILE=Default"

set "SRC=%LOCALAPPDATA%\Microsoft\Edge\User Data\%PROFILE%"
set "DST=%BACKUP_ROOT%\Edge\%DATE%\%PROFILE%"
mkdir "!DST!" >nul 2>&1

if exist "!SRC!\History" (
    xcopy /E /I /Y "!SRC!" "!DST!" >nul
    del /f /q "!SRC!\History" >nul
    echo ✅ Edge (%PROFILE%): історія очищена, резерв збережено.
) else (
    echo ❌ History у Edge профілі %PROFILE% не знайдено.
)
pause
goto browser_edge


:edge_full
taskkill /F /IM msedge.exe >nul 2>&1
set "DATE=%DATE:/=-%_%TIME::=-%"
set "DATE=%DATE: =_%"
set "SRC=%LOCALAPPDATA%\Microsoft\Edge"
set "DST=%BACKUP_ROOT%\Edge\%DATE%"
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

if "%ff%"=="1" goto firefox_history
if "%ff%"=="2" goto firefox_full
if "%ff%"=="0" goto browser_select
echo ❌ Невірний вибір.
pause
goto browser_firefox

:firefox_history
taskkill /F /IM firefox.exe >nul 2>&1
set "INI=%APPDATA%\Mozilla\Firefox\profiles.ini"
set "DATE=%DATE:/=-%_%TIME::=-%"
set "DATE=%DATE: =_%"
set "DST=%BACKUP_ROOT%\Firefox\%DATE%"
set "PROFILE="
set "found="

for /f "tokens=*" %%L in ('type "%INI%" 2^>nul') do (
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
set "DATE=%DATE:/=-%_%TIME::=-%"
set "DATE=%DATE: =_%"
set "SRC=%APPDATA%\Mozilla\Firefox"
set "DST=%BACKUP_ROOT%\Firefox\%DATE%"
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

if "%br%"=="1" goto brave_history
if "%br%"=="2" goto brave_full
if "%br%"=="0" goto browser_select
echo ❌ Невірний вибір.
pause
goto browser_brave

:brave_history
taskkill /F /IM brave.exe >nul 2>&1
set "CONFIG=%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Local State"
set "DATE=%DATE:/=-%_%TIME::=-%"
set "DATE=%DATE: =_%"

for /f "tokens=2 delims=:" %%L in ('findstr /C:"last_active_profiles" "%CONFIG%" 2^>nul') do (
    set "raw=%%~L"
)
set "raw=%raw:[=%"
set "raw=%raw:]=%"
set "raw=%raw:~1,-1%"
set "PROFILE=%raw%"
if not defined PROFILE set "PROFILE=Default"

set "SRC=%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\%PROFILE%"
set "DST=%BACKUP_ROOT%\Brave\%DATE%\%PROFILE%"
mkdir "!DST!" >nul 2>&1

if exist "!SRC!\History" (
    xcopy /E /I /Y "!SRC!" "!DST!" >nul
    del /f /q "!SRC!\History" >nul
    echo ✅ Brave (%PROFILE%): історія очищена, резерв збережено.
) else (
    echo ❌ History у Brave профілі %PROFILE% не знайдено.
)
pause
goto browser_brave


:brave_full
taskkill /F /IM brave.exe >nul 2>&1
set "DATE=%DATE:/=-%_%TIME::=-%"
set "DATE=%DATE: =_%"
set "SRC=%LOCALAPPDATA%\BraveSoftware\Brave-Browser"
set "DST=%BACKUP_ROOT%\Brave\%DATE%"
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

if "%op%"=="1" goto opera_history
if "%op%"=="2" goto opera_full
if "%op%"=="0" goto browser_select
echo ❌ Невірний вибір.
pause
goto browser_opera

:opera_history
taskkill /F /IM opera.exe >nul 2>&1
set "DATE=%DATE:/=-%_%TIME::=-%"
set "DATE=%DATE: =_%"
set "DST=%BACKUP_ROOT%\Opera\%DATE%"
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
set "DST=%BACKUP_ROOT%\Opera\%DATE%"
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


:: ----------- МЕНЮ МЕСЕНДЖЕРІВ -----------

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
if "%m%"=="1" goto m_telegram
if "%m%"=="2" goto m_discord
if "%m%"=="3" goto m_skype
if "%m%"=="4" goto m_viber
if "%m%"=="5" goto m_whatsapp
if "%m%"=="6" goto m_signal
if "%m%"=="0" goto main_menu

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
if "%tg%"=="0" goto messenger_select
taskkill /IM telegram.exe /F >nul

if "%tg%"=="1" call :create_backup "!SRC!\tdata\cache" "Telegram" "Cache" & rd /s /q "!SRC!\tdata\cache"
if "%tg%"=="2" call :create_backup "!SRC!" "Telegram" "Full" & rd /s /q "!SRC!"

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
if "%dc%"=="0" goto messenger_select
taskkill /IM discord.exe /F >nul

if "%dc%"=="1" call :create_backup "!SRC!\Cache" "Discord" "Cache" & rd /s /q "!SRC!\Cache"
if "%dc%"=="2" call :create_backup "!SRC!" "Discord" "Full" & rd /s /q "!SRC!"

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
if "%sk%"=="0" goto messenger_select
taskkill /IM skype.exe /F >nul

if "%sk%"=="1" call :create_backup "!SRC!\My Skype Received Files" "Skype" "Files" & rd /s /q "!SRC!\My Skype Received Files"
if "%sk%"=="2" call :create_backup "!SRC!" "Skype" "Full" & rd /s /q "!SRC!"

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
if "%vb%"=="0" goto messenger_select
taskkill /IM Viber.exe /F >nul

if "%vb%"=="1" call :create_backup "!SRC!\cache" "Viber" "Cache" & rd /s /q "!SRC!\cache"
if "%vb%"=="2" call :create_backup "!SRC!" "Viber" "Full" & rd /s /q "!SRC!"

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
if "%wa%"=="0" goto messenger_select
taskkill /IM WhatsApp.exe /F >nul

if "%wa%"=="1" call :create_backup "!SRC!\Cache" "WhatsApp" "Cache" & rd /s /q "!SRC!\Cache"
if "%wa%"=="2" call :create_backup "!SRC!" "WhatsApp" "Full" & rd /s /q "!SRC!"

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
if "%sg%"=="0" goto messenger_select
taskkill /IM Signal.exe /F >nul

if "%sg%"=="1" call :create_backup "!SRC!\Cache" "Signal" "Cache" & rd /s /q "!SRC!\Cache"
if "%sg%"=="2" call :create_backup "!SRC!" "Signal" "Full" & rd /s /q "!SRC!"

pause
goto messenger_select


:: ----------- ФУНКЦІЯ РЕЗЕРВНОГО КОПІЮВАННЯ -----------

:create_backup
REM %1 - джерело
REM %2 - назва програми
REM %3 - тип очищення (Cache, Full, Files)

setlocal
set "SRC=%~1"
set "APP=%~2"
set "TYPE=%~3"
set "DATE=%DATE:/=-%_%TIME::=-%"
set "DATE=%DATE: =_%"
set "DST=%BACKUP_ROOT%\%APP%\%DATE%\%TYPE%"

if exist "%SRC%" (
    mkdir "%DST%" >nul 2>&1
    echo Створюємо резервну копію: %APP% [%TYPE%]...
    xcopy /E /I /Y "%SRC%" "%DST%" >nul
    echo Резервна копія %APP% [%TYPE%] створена.
) else (
    echo ❌ Папка для резервного копіювання не знайдена: %SRC%
)
endlocal
goto :eof


:: ----------- МЕНЮ ВІДНОВЛЕННЯ -----------

:restore_menu
cls
echo ================================
echo    Відновлення з резервної копії
echo ================================
echo 1. Google Chrome
echo 2. Microsoft Edge
echo 3. Mozilla Firefox
echo 4. Opera
echo 5. Brave
echo 6. Telegram
echo 7. Discord
echo 8. Skype
echo 9. Viber
echo 10. WhatsApp
echo 11. Signal
echo 0. Назад
echo ================================
set /p r=Виберіть додаток для відновлення: 

if "%r%"=="0" goto main_menu
if "%r%"=="1" set "RESTORE_APP=Chrome" & goto restore_select_date
if "%r%"=="2" set "RESTORE_APP=Edge" & goto restore_select_date
if "%r%"=="3" set "RESTORE_APP=Firefox" & goto restore_select_date
if "%r%"=="4" set "RESTORE_APP=Opera" & goto restore_select_date
if "%r%"=="5" set "RESTORE_APP=Brave" & goto restore_select_date
if "%r%"=="6" set "RESTORE_APP=Telegram" & goto restore_select_date
if "%r%"=="7" set "RESTORE_APP=Discord" & goto restore_select_date
if "%r%"=="8" set "RESTORE_APP=Skype" & goto restore_select_date
if "%r%"=="9" set "RESTORE_APP=Viber" & goto restore_select_date
if "%r%"=="10" set "RESTORE_APP=WhatsApp" & goto restore_select_date
if "%r%"=="11" set "RESTORE_APP=Signal" & goto restore_select_date

echo ❌ Невірний вибір.
pause
goto restore_menu

:restore_select_date
cls
setlocal
set "APP_FOLDER=%BACKUP_ROOT%\%RESTORE_APP%"
if not exist "%APP_FOLDER%" (
    echo ❌ Резервні копії для %RESTORE_APP% не знайдено.
    pause
    endlocal
    goto restore_menu
)

echo Виберіть дату резервної копії:
setlocal enabledelayedexpansion
set i=0
for /f "delims=" %%D in ('dir /b /ad "%APP_FOLDER%"') do (
    set /a i+=1
    set "date_!i!=%%D"
    echo !i!. %%D
)
if !i! equ 0 (
    echo ❌ Резервних копій не знайдено.
    pause
    endlocal
    goto restore_menu
)
echo 0. Назад

set /p datenum=Введіть номер дати: 
if "%datenum%"=="0" (
    endlocal
    goto restore_menu
)

for /f "tokens=1 delims=0123456789" %%A in ("%datenum%") do set "check=%%A"
if defined check (
    echo ❌ Невірний номер.
    pause
    endlocal
    goto restore_select_date
)

if %datenum% LEQ 0 (
    echo ❌ Невірний номер.
    pause
    endlocal
    goto restore_select_date
)

if %datenum% GTR !i! (
    echo ❌ Невірний номер.
    pause
    endlocal
    goto restore_select_date
)

set "RESTORE_DATE=!date_%datenum%!"
endlocal & set "RESTORE_DATE=%RESTORE_DATE%"

echo Ви обрали відновлення для %RESTORE_APP% з дати %RESTORE_DATE%
echo Це перезапише поточні дані програми! Продовжити? (Y/N)
choice /c YN /n >nul
if errorlevel 2 goto restore_menu

call :restore_backup "%BACKUP_ROOT%\%RESTORE_APP%\%RESTORE_DATE%" "%RESTORE_APP%"
goto restore_menu

:restore_backup
REM %1 - шлях до резервної копії
REM %2 - назва програми

setlocal
set "SRC=%~1"
set "APP=%~2"

if /i "%APP%"=="Chrome" (
    set "DST=%LOCALAPPDATA%\Google\Chrome"
) else if /i "%APP%"=="Edge" (
    set "DST=%LOCALAPPDATA%\Microsoft\Edge"
) else if /i "%APP%"=="Firefox" (
    set "DST=%APPDATA%\Mozilla\Firefox"
) else if /i "%APP%"=="Opera" (
    set "DST=%APPDATA%\Opera Software"
) else if /i "%APP%"=="Brave" (
    set "DST=%LOCALAPPDATA%\BraveSoftware\Brave-Browser"
) else if /i "%APP%"=="Telegram" (
    set "DST=%APPDATA%\Telegram Desktop"
) else if /i "%APP%"=="Discord" (
    set "DST=%APPDATA%\discord"
) else if /i "%APP%"=="Skype" (
    set "DST=%APPDATA%\Skype"
) else if /i "%APP%"=="Viber" (
    set "DST=%APPDATA%\ViberPC"
) else if /i "%APP%"=="WhatsApp" (
    set "DST=%APPDATA%\WhatsApp"
) else if /i "%APP%"=="Signal" (
    set "DST=%APPDATA%\Signal"
) else (
    echo ❌ Невідома програма для відновлення.
    pause
    endlocal
    goto :eof
)

if exist "%DST%" (
    echo Завершуємо процеси %APP%...
    taskkill /F /IM "%APP%.exe" >nul 2>&1
    echo Видаляємо поточні дані...
    rd /s /q "%DST%"
)
echo Відновлюємо резервні копії...
xcopy /E /I /Y "%SRC%" "%DST%" >nul
echo ✅ Відновлення %APP% завершено.
pause
endlocal
goto :eof


:: ----------- ВИМКНЕННЯ АВТОЗАПУСКУ -----------

:disable_all_startup
cls
echo Вимкнення автозапуску програм...

reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f >nul 2>&1

echo ✅ Автозапуск очищено.
pause
goto main_menu


:: ----------- ПЕРЕВІРКА ПІДОЗРІЛИХ ПРОЦЕСІВ -----------

:CheckThreats_Debug
cls
echo Перевірка процесів на підозрілі ключові слова...
set "KEYWORDS=keylogger,cheat,cheater,hack,hacker,virus,trojan,miner,mine"

set "OUTLOG=%~dp0CheckThreats.log"
del "%OUTLOG%" >nul 2>&1

for /f "tokens=2 delims=," %%P in ('tasklist /fo csv /nh') do (
    set "proc=%%~P"
    for %%K in (%KEYWORDS%) do (
        echo !proc! | findstr /i "%%K" >nul
        if !errorlevel! EQU 0 (
            echo Підозрілий процес: !proc! (ключове слово: %%K) >> "%OUTLOG%"
        )
    )
)

if exist "%OUTLOG%" (
    echo 🔍 Знайдені підозрілі процеси. Деталі в файлі: %OUTLOG%
) else (
    echo ✅ Підозрілих процесів не виявлено.
)
pause
goto main_menu


:: ----------- ХОЛОДНЕ ВИДАЛЕННЯ -----------

:total_wipe
cls
echo Увага! Тотальне видалення всіх даних браузерів та месенджерів!
echo Це призведе до втрати всіх даних без можливості відновлення.
echo Продовжити? (Y/N)
choice /c YN /n >nul
if errorlevel 2 goto main_menu

echo Виконується видалення...
taskkill /F /IM chrome.exe /IM msedge.exe /IM firefox.exe /IM opera.exe /IM brave.exe /IM telegram.exe /IM discord.exe /IM skype.exe /IM Viber.exe /IM WhatsApp.exe /IM Signal.exe >nul 2>&1

rd /s /q "%LOCALAPPDATA%\Google\Chrome"
rd /s /q "%LOCALAPPDATA%\Microsoft\Edge"
rd /s /q "%APPDATA%\Mozilla\Firefox"
rd /s /q "%APPDATA%\Opera Software"
rd /s /q "%LOCALAPPDATA%\BraveSoftware\Brave-Browser"
rd /s /q "%APPDATA%\Telegram Desktop"
rd /s /q "%APPDATA%\discord"
rd /s /q "%APPDATA%\Skype"
rd /s /q "%APPDATA%\ViberPC"
rd /s /q "%APPDATA%\WhatsApp"
rd /s /q "%APPDATA%\Signal"

echo ✅ Всі дані видалені.
pause
goto main_menu

)

:: Проверка обновлений (в начале)
call :check_update

echo 🔍 Отримана версія: "!REMOTE_VER!"
echo 🔍 Локальна версія: "!VERSION!"
pause

:: Заголовок окна
title Універсальне очищення ПК

:: Проверка запуска от имени администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Запустіть файл від імені адміністратора!
    pause
    exit
)

:: Создание резервной папки
set "STAMP=%COMPUTERNAME%%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%%TIME:~0,2%-%TIME:~6,2%"
set "STAMP=%STAMP: =0%"
set "BACKUP_ROOT=%~dp0Backup%STAMP%"
mkdir "!BACKUP_ROOT!" >nul 2>&1

:: Главное меню (пока заглушка)
echo === Головне меню ===
pause

:main_menu
cls
echo ==================================================
echo         УНІВЕРСАЛЬНЕ ОЧИЩЕННЯ ПК [v!VERSION!]
echo    Користувач: %USERNAME%   ПК: %COMPUTERNAME%
echo ==================================================
echo.
echo Виберіть дію:
echo 1. Очистити браузери
echo 2. Очистити месенджери
echo 3. Вимкнути автозапуск усіх програм
echo 4. Відновити з резервної копії
echo 5. Очистити історію Провідника та Швидкого доступу
echo 6. Цифровий відбілювач
echo 7. Видалити тимчасові файли
echo 8. Перевірити шкідливі процеси
echo 9. Режим холодного видалення 💣
echo 0. Вийти з програми
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

:: === Блок обновления ===
:check_update
set "REPO_BASE=https://raw.githubusercontent.com/sane4ekgs/clenup_sanhez/main"
set "TMPV=%TEMP%\version.txt"
set "TMPB=%TEMP%\clenup.bat"

echo ==================================================
echo (ℹ️) Получаю версию с:
echo      !REPO_BASE!/.version.txt
echo --------------------------------------------------
echo 👉 Загружаю версию...

curl -s -L -o "%~dp0version.txt" "https://raw.githubusercontent.com/sane4ekgs/clenup_sanhez/main/.version.txt"
curl -L -o "!TMPV!" "!REPO_BASE!/.version.txt"

type "!TMPV!"
pause

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

    :: Устанавливаем флаг, чтобы при перезапуске обновления не было
    echo updated > "%TEMP%\sanchez_updated.flag"

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
del /f /q "%APPDATA%\Microsoft\Windows\Recent\*" >nul 2>&1
del /f /q "%APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\*" >nul 2>&1
del /f /q "%APPDATA%\Microsoft\Windows\Recent\CustomDestinations\*" >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths" /f >nul 2>&1
echo ✅ Історія швидкого доступу очищена!
pause
goto main_menu

:deep_trace_wipe
cls
echo === 🧼 ОЧИЩЕННЯ USB / ЗАПУСКІВ / СЛІДІВ ===

echo ⚠️ Сліди підключень та запусків будуть видалені.
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

:: 🔌 Очищення історії підключених USB-дисків і флешок
reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\USBSTOR" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2" /f >nul 2>&1

:: 🧠 Видалення історії запуску програм
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /f >nul 2>&1

:: 🧾 Очищення TypedPaths ("Цей комп'ютер" → шлях вручну)
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths" /f >nul 2>&1

:: 🕓 Очищення історії активності
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ActivityHistory" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps" /f >nul 2>&1

:: 🗂️ Видалення Recent Items та thumbcache
del /f /q "%APPDATA%\Microsoft\Windows\Recent\*" >nul 2>&1
del /f /q "%APPDATA%\Microsoft\Windows\Recent Items\*" >nul 2>&1
del /f /q "%APPDATA%\Microsoft\Windows\Explorer\thumbcache*" >nul 2>&1

:: Повертаємо провідник
start explorer.exe

echo ✅ Сліди запусків, USB, історії очищено.
pause
goto main_menu

:clear_temp_files
cls
echo ==== ОЧИСТКА ТИМЧАСОВИХ ФАЙЛІВ ====
:: Очищення кешу та тимчасових файлів Windows
rd /s /q "%TEMP%" >nul 2>&1
mkdir "%TEMP%" >nul 2>&1
cleanmgr /sagerun:1 >nul 2>&1
echo ✅ Тимчасові файли очищені!
pause
goto main_menu

