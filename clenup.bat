@echo off
chcp 65001 >nul
color 0A

:: Включаем расширение переменных
setlocal enabledelayedexpansion

:: Версия скрипта
call :set_version

:: Проверка обновлений
call :check_update

title Універсальне очищення ПК

echo ==================================================
echo                ВАС ВІТАЄ SANCHEZ                  
echo ==================================================
timeout /t 2 >nul

:: Запуск от администратора
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
echo 6. Видалити журнал дій Windows
echo 7. Видалити тимчасові файли
echo 8. Перевірка шкідливих процесів
echo 9. Режим холодного видалення 💣
echo 0. Вихід
echo.
set /p msel=Ваш вибір:
exit /b

:set_version
set "VERSION=2.2"
goto :eof

:check_update
set "REPO_BASE=https://github.com/sane4ekgs/clenup_sanchez/raw/refs/heads/main"
set "TMPV=%TEMP%\remote_version.txt"
set "TMPB=%TEMP%\latest_clenup.bat"

echo ==================================================
echo (ℹ️) Получаю версию с:
echo      !REPO_BASE!/.version.txt
echo --------------------------------------------------
curl -s -L -o "!TMPV!" "https://github.com/sane4ekgs/clenup_sanchez/raw/refs/heads/main/.version.txt" >nul 2>&1
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
curl -s -L -o "!TMPB!" "https://github.com/sane4ekgs/clenup_sanchez/raw/refs/heads/main/clenup.bat" >nul 2>&1
if exist "!TMPB!" (
    echo 🔁 Заменяю текущий скрипт...
    copy /Y "!TMPB!" "%~f0" >nul
    del "!TMPB!"
    echo ✅ Обновление завершено! Перезапуск...
    timeout /t 2 >nul
    start "" "%~f0"
    exit
) else (
    echo ❌ Ошибка при загрузке с !REPO_BASE!/clenup.bat
)
goto :eof



if "!choice!"=="1" goto browser_select
if "!choice!"=="2" goto messenger_select
if "!choice!"=="3" goto disable_all_startup
if "!choice!"=="4" goto restore_menu
if "!choice!"=="5" goto clear_quick_access
if "!choice!"=="6" goto clear_activity_history
if "!choice!"=="7" goto clear_temp_files
if "!choice!"=="8" goto CheckThreats_Debug
if "!choice!"=="9" goto total_wipe
if "!choice!"=="0" exit

echo ❌ Невірний вибір.
pause


:clear_quick_access
cls
echo ==== ОЧИСТКА БИСТРОГО ДОСТУПУ ====
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

:clear_activity_history
cls
echo ==== ОЧИСТКА ЖУРНАЛУ ДІЙ WINDOWS ====
:: Закриваємо процеси, які можуть блокувати видалення
taskkill /IM explorer.exe /F >nul 2>&1
taskkill /IM RuntimeBroker.exe /F >nul 2>&1

:: Очищення журналу дій користувача (без видалення системних)
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ActivityHistory" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps" /f >nul 2>&1

:: Перезапускаємо explorer.exe
start explorer.exe

echo ✅ Журнал очищено без ризику для системи!
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
taskkill /F /IM chrome.exe >nul 2>&1
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
taskkill /F /IM chrome.exe >nul 2>&1
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
set "DST=!BACKUP_ROOT!\Telegram"
echo ==== TELEGRAM ====
echo 1. Кеш
echo 2. Повне очищення
echo 0. Назад
set /p tg=Ваш вибір: 
taskkill /IM telegram.exe /F >nul 2>&1

if "!tg!"=="1" (
    if exist "!SRC!\tdata\cache" (
        mkdir "!DST!\Cache" >nul
        xcopy /E /I /Y "!SRC!\tdata\cache" "!DST!\Cache" >nul
        rd /s /q "!SRC!\tdata\cache"
        echo Кеш Telegram очищено, копія збережена.
    ) else (echo Кеш не знайдено.)
)
if "!tg!"=="2" (
    if exist "!SRC!" (
        xcopy /E /I /Y "!SRC!" "!DST!" >nul
        rd /s /q "!SRC!"
        echo Telegram очищено повністю, копія збережена.
    ) else (echo Дані Telegram не знайдено.)
)
if "!tg!"=="0" goto messenger_select
pause
goto messenger_select

:m_discord
cls
set "SRC=%APPDATA%\discord"
set "DST=!BACKUP_ROOT!\Discord"
echo ==== DISCORD ====
echo 1. Кеш
echo 2. Повне очищення
echo 0. Назад
set /p dc=Ваш вибір: 
taskkill /IM discord.exe /F >nul 2>&1

if "!dc!"=="1" (
    if exist "!SRC!\Cache" (
        mkdir "!DST!\Cache" >nul
        xcopy /E /I /Y "!SRC!\Cache" "!DST!\Cache" >nul
        rd /s /q "!SRC!\Cache"
        echo Кеш Discord очищено.
    ) else (echo Кеш не знайдено.)
)
if "!dc!"=="2" (
    if exist "!SRC!" (
        xcopy /E /I /Y "!SRC!" "!DST!" >nul
        rd /s /q "!SRC!"
        echo Discord очищено повністю.
    ) else (echo Дані Discord не знайдено.)
)
if "!dc!"=="0" goto messenger_select
pause
goto messenger_select

:m_skype
cls
set "SRC=%APPDATA%\Skype"
set "DST=!BACKUP_ROOT!\Skype"
echo ==== SKYPE ====
echo 1. Кеш
echo 2. Повне очищення
echo 0. Назад
set /p sk=Ваш вибір: 
taskkill /IM skype.exe /F >nul 2>&1

if "!sk!"=="1" (
    if exist "!SRC!\My Skype Received Files" (
        mkdir "!DST!\Files" >nul
        xcopy /E /I /Y "!SRC!\My Skype Received Files" "!DST!\Files" >nul
        rd /s /q "!SRC!\My Skype Received Files"
        echo Кеш очищено.
    ) else (echo Кеш не знайдено.)
)
if "!sk!"=="2" (
    if exist "!SRC!" (
        xcopy /E /I /Y "!SRC!" "!DST!" >nul
        rd /s /q "!SRC!"
        echo Skype очищено повністю.
    ) else (echo Дані Skype не знайдено.)
)
if "!sk!"=="0" goto messenger_select
pause
goto messenger_select

:m_viber
cls
set "SRC=%APPDATA%\ViberPC"
set "DST=!BACKUP_ROOT!\Viber"
echo ==== VIBER ====
echo 1. Кеш
echo 2. Повне очищення
echo 0. Назад
set /p vb=Ваш вибір: 
taskkill /IM Viber.exe /F >nul 2>&1

if "!vb!"=="1" (
    if exist "!SRC!\cache" (
        mkdir "!DST!\Cache" >nul
        xcopy /E /I /Y "!SRC!\cache" "!DST!\Cache" >nul
        rd /s /q "!SRC!\cache"
        echo ✅ Кеш Viber очищено, копія збережена.
    ) else (echo Кеш не знайдено.)
)
if "!vb!"=="2" (
    if exist "!SRC!" (
        xcopy /E /I /Y "!SRC!" "!DST!" >nul
        rd /s /q "!SRC!"
        echo ✅ Viber очищено повністю.
    ) else (echo Дані не знайдено.)
)
if "!vb!"=="0" goto messenger_select
pause
goto messenger_select

:m_whatsapp
cls
set "SRC=%APPDATA%\WhatsApp"
set "DST=!BACKUP_ROOT!\WhatsApp"
echo ==== WHATSAPP ====
echo 1. Кеш
echo 2. Повне очищення
echo 0. Назад
set /p wa=Ваш вибір: 
taskkill /IM WhatsApp.exe /F >nul 2>&1

if "!wa!"=="1" (
    if exist "!SRC!\Cache" (
        mkdir "!DST!\Cache" >nul
        xcopy /E /I /Y "!SRC!\Cache" "!DST!\Cache" >nul
        rd /s /q "!SRC!\Cache"
        echo ✅ Кеш WhatsApp очищено, копія збережена.
    ) else (echo Кеш не знайдено.)
)
if "!wa!"=="2" (
    if exist "!SRC!" (
        xcopy /E /I /Y "!SRC!" "!DST!" >nul
        rd /s /q "!SRC!"
        echo ✅ WhatsApp очищено повністю.
    ) else (echo Дані не знайдено.)
)
if "!wa!"=="0" goto messenger_select
pause
goto messenger_select

:m_signal
cls
set "SRC=%APPDATA%\Signal"
set "DST=!BACKUP_ROOT!\Signal"
echo ==== SIGNAL ====
echo 1. Кеш
echo 2. Повне очищення
echo 0. Назад
set /p sg=Ваш вибір: 
taskkill /IM signal.exe /F >nul 2>&1

if "!sg!"=="1" (
    if exist "!SRC!\Cache" (
        mkdir "!DST!\Cache" >nul
        xcopy /E /I /Y "!SRC!\Cache" "!DST!\Cache" >nul
        rd /s /q "!SRC!\Cache"
        echo ✅ Кеш Signal очищено.
    ) else (echo Кеш не знайдено.)
)
if "!sg!"=="2" (
    if exist "!SRC!" (
        xcopy /E /I /Y "!SRC!" "!DST!" >nul
        rd /s /q "!SRC!"
        echo ✅ Signal очищено повністю.
    ) else (echo Дані Signal не знайдено.)
)
if "!sg!"=="0" goto messenger_select
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

:: Видалення всіх програм з автозапуску
for /f "tokens=1" %%A in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" ^| findstr /i "\\"') do (
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v %%A /f >nul 2>&1
)

echo ✅ Усі програми видалено з автозапуску!
pause
goto main_menu

:restore_menu
cls
echo ==================================================
echo            відновлення з резервної копії          
echo ==================================================
echo 1. Відновити браузери
echo 2. Відновити месенджери
echo 3. Видалити одну резервну копію
echo 4. Видалити ВСІ резервні копії
echo 0. Назад
set /p restore_choice=Ваш вибір: 

if "%restore_choice%"=="1" goto restore_browsers
if "%restore_choice%"=="2" goto restore_messengers
if "%restore_choice%"=="3" goto set_list
if "%restore_choice%"=="4" goto delete_all_backups
if "%restore_choice%"=="0" goto main_menu
echo ❌ Невірний вибір. Спробуйте ще раз.
pause
goto restore_menu

:set_list
cls
echo ==== ВИДАЛЕННЯ РЕЗЕРВНОЇ КОПІЇ ====

if not exist "%~dp0Backup" (
    echo ❌ Папка резервних копій не знайдена!
    pause
    goto restore_menu
)

echo 📂 Доступні резервні копії:
setlocal enabledelayedexpansion
set i=0
for /f "delims=" %%D in ('dir /b /ad "%~dp0\Backup"') do (
    set /a i+=1
    set "backup[!i!]=%%D"
    echo !i!. %%D
)

echo 0. Назад
set /p num=Введіть номер копії для видалення: 

if "%num%"=="0" goto restore_menu

:: Читаем имя копии прямо из сохранённой переменной
set "SELECTED_BACKUP="
if defined backup[%num%] (
    set "SELECTED_BACKUP=!backup[%num%]!"
)

:: Проверяем, распозналась ли копия
echo 🔍 Перевірка: %SELECTED_BACKUP%
if not defined SELECTED_BACKUP (
    echo ❌ Невірний номер. Спробуйте ще раз.
    pause
    goto set_list
)

:: Удаление копии
echo 🗑️ Видалення: %SELECTED_BACKUP%
rd /s /q "%~dp0Backup\%SELECTED_BACKUP%" 2>nul
if exist "%~dp0Backup\%SELECTED_BACKUP%" (
    echo ❌ Помилка: не вдалося видалити!
) else (
    echo ✅ Видалено успішно!
)

endlocal
pause
goto restore_menu

:restore_browsers
cls
echo ==== ВІДНОВЛЕННЯ БРАУЗЕРІВ ====

:: Вывод списка браузеров
echo 📂 Доступні браузери:
set i=0
setlocal enabledelayedexpansion
for /d %%B in ("%~dp0Backup\*") do (
    if exist "%%B\*" (
        set /a i+=1
        set "browser[!i!]=%%~nxB"
        echo !i!. %%~nxB
    )
)

echo 0. Назад
set /p browser_num=Введіть номер браузера: 

if "%browser_num%"=="0" goto restore_menu

set "SELECTED_BROWSER="
if defined browser[%browser_num%] (
    set "SELECTED_BROWSER=!browser[%browser_num%]!"
)

echo 🔍 Перевірка браузера: %SELECTED_BROWSER%
if not defined SELECTED_BROWSER (
    echo ❌ Невірний номер. Спробуйте ще раз.
    pause
    goto restore_browsers
)

:: Вывод списка дат для выбранного браузера
cls
echo 📂 Доступні резервні копії %SELECTED_BROWSER%:
set j=0
for /d %%D in ("%~dp0Backup\%SELECTED_BROWSER%\*") do (
    set /a j+=1
    set "backup[!j!]=%%~nxD"
    echo !j!. %%~nxD
)

echo 0. Назад
set /p backup_num=Введіть номер резервної копії: 

if "%backup_num%"=="0" goto restore_browsers

set "SELECTED_BACKUP="
if defined backup[%backup_num%] (
    set "SELECTED_BACKUP=!backup[%backup_num%]!"
)

echo 🔍 Перевірка резерву: %SELECTED_BACKUP%
if not defined SELECTED_BACKUP (
    echo ❌ Невірний номер. Спробуйте ще раз.
    pause
    goto restore_browsers
)

:: Восстановление копии
echo 🛠️ Відновлення %SELECTED_BROWSER% з %SELECTED_BACKUP%
xcopy /E /I /Y "%~dp0Backup\%SELECTED_BROWSER%\%SELECTED_BACKUP%\*" "%LOCALAPPDATA%\%SELECTED_BROWSER%" >nul

echo ✅ Відновлено успішно!
endlocal
pause
goto restore_menu

:restore_messengers
cls
echo ==== ВІДНОВЛЕННЯ МЕСЕНДЖЕРІВ ====

:: Вывод списка мессенджеров
echo 📂 Доступні месенджери:
set i=0
setlocal enabledelayedexpansion
for /d %%M in ("%~dp0Backup\*") do (
    if exist "%%M\*" (
        set /a i+=1
        set "messenger[!i!]=%%~nxM"
        echo !i!. %%~nxM
    )
)

echo 0. Назад
set /p messenger_num=Введіть номер месенджера: 

if "%messenger_num%"=="0" goto restore_menu

set "SELECTED_MESSENGER="
if defined messenger[%messenger_num%] (
    set "SELECTED_MESSENGER=!messenger[%messenger_num%]!"
)

echo 🔍 Перевірка месенджера: %SELECTED_MESSENGER%
if not defined SELECTED_MESSENGER (
    echo ❌ Невірний номер. Спробуйте ще раз.
    pause
    goto restore_messengers
)

:: Вывод списка дат для выбранного мессенджера
cls
echo 📂 Доступні резервні копії %SELECTED_MESSENGER%:
set j=0
for /d %%D in ("%~dp0Backup\%SELECTED_MESSENGER%\*") do (
    set /a j+=1
    set "backup[!j!]=%%~nxD"
    echo !j!. %%~nxD
)

echo 0. Назад
set /p backup_num=Введіть номер резервної копії: 

if "%backup_num%"=="0" goto restore_messengers

set "SELECTED_BACKUP="
if defined backup[%backup_num%] (
    set "SELECTED_BACKUP=!backup[%backup_num%]!"
)

echo 🔍 Перевірка резерву: %SELECTED_BACKUP%
if not defined SELECTED_BACKUP (
    echo ❌ Невірний номер. Спробуйте ще раз.
    pause
    goto restore_messengers
)

:: Восстановление копии
echo 🛠️ Відновлення %SELECTED_MESSENGER% з %SELECTED_BACKUP%
xcopy /E /I /Y "%~dp0Backup\%SELECTED_MESSENGER%\%SELECTED_BACKUP%\*" "%APPDATA%\%SELECTED_MESSENGER%" >nul

echo ✅ Відновлено успішно!
endlocal
pause
goto restore_menu

:delete_all_backups
cls
echo 🗑️ Видалення ВСІХ резервних копій...

if exist "%~dp0Backup" (
    rd /s /q "%~dp0Backup"
    echo ✅ Усі резервні копії видалені!
) else (
    echo ❌ Папка резервних копій не знайдена.
)

pause
goto restore_menu

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
echo Усі дані будуть видалені негайно без резерву чи підтвердження!
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