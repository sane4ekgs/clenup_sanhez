@echo off
chcp 65001 >nul
color 0A
setlocal enabledelayedexpansion

:: Пропуск повторного обновления после замены файла
if exist "%TEMP%\sanchez_updated.flag" (
    del "%TEMP%\sanchez_updated.flag"
    goto main_menu
)

:: Устанавливаем локальную версию из файла
set "VERFILE=%~dp0version.txt"
if exist "!VERFILE!" (
    set /p VERSION=<"!VERFILE!"
) else (
    set "VERSION=UNKNOWN"
)

:: Проверка обновлений (в начале)
call :check_update >nul 2>&1


::echo 🔍 Отримана версія: "!REMOTE_VER!"
::echo 🔍 Локальна версія: "!VERSION!"
::pause

:: Заголовок окна
title Універсальне очищення ПК

:: Проверка запуска от имени администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Запустіть файл від імені адміністратора!
    pause
    exit
)

:: Генерация имени резервной папки (ПК + дата/время)
set "STAMP=%COMPUTERNAME%_%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%_%TIME:~0,2%-%TIME:~3,2%-%TIME:~6,2%"
set "STAMP=%STAMP: =0%"
set "BACKUP_ROOT=%~dp0Backup\%STAMP%"
mkdir "%BACKUP_ROOT%" >nul 2>&1


:: Главное меню 
:main_menu
cls
echo ==================================================
echo           🧹 УНІВЕРСАЛЬНЕ ОЧИЩЕННЯ ПК 🧹
echo                  SANCHEZ [v%VERSION%]
echo ==================================================
echo    👤 Користувач: %USERNAME%   🖥 ПК: %COMPUTERNAME%
echo ==================================================
echo.
echo Виберіть дію:
echo 1. 🌐 Очистити браузери
echo 2. 💬 Очистити месенджери
echo 3. 🚫 Вимкнути автозапуск браузерів та месенджерів
echo 4. 🗂 Відновити з резервної копії
echo 5. 🧹 Очистити історію Провідника та Швидкого доступу
echo 6. 🧼 Видалення usb-запусків та слідів
echo 7. 🗑 Видалити тимчасові файли
echo 8. 🛡 Перевірити шкідливі процеси
echo 9. 💣 Режим холодного видалення
echo 0. ❌ Вийти з програми
echo.
set /p choice=Ваш вибір:

if "!choice!"=="1" goto browser_select
if "!choice!"=="2" goto messenger_select
if "!choice!"=="3" goto disable_startup_messengers_browsers
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



:: ----------- Google Chrome -----------

:chrome_full
cls
echo 🗑️ Повне очищення Chrome...
echo Чи бажаєте зберегти резервну копію перед видаленням? (1 - Так, 2 - Ні)
choice /c 12 /n
if errorlevel 2 goto chrome_full_delete_nobackup
if errorlevel 1 goto chrome_full_delete_withbackup

:chrome_full_delete_withbackup
taskkill /IM chrome.exe /F >nul 2>&1
timeout /t 2 /nobreak >nul

setlocal enabledelayedexpansion
set "SRC=%LOCALAPPDATA%\Google\Chrome\User Data"
set "DST=%~dp0Backup\Chrome\Full_%DATE:/=-%_%TIME::=-%"
set "DST=!DST: =_!"

if exist "!SRC!" (
    mkdir "!DST!" >nul 2>&1
    xcopy /E /I /Y "!SRC!" "!DST!" >nul
    rd /s /q "!SRC!"
    echo ✅ Всі дані Chrome видалені з резервною копією!
) else (
    echo ❌ Дані Chrome не знайдено.
)

endlocal
pause
goto browser_chrome

:chrome_full_delete_nobackup
taskkill /IM chrome.exe /F >nul 2>&1
timeout /t 2 /nobreak >nul

set "SRC=%LOCALAPPDATA%\Google\Chrome\User Data"

if exist "%SRC%" (
    rd /s /q "%SRC%"
    echo ✅ Всі дані Chrome видалені без резервної копії!
) else (
    echo ❌ Дані Chrome не знайдено.
)

pause
goto browser_chrome

:: ----------- Microsoft Edge -----------

:edge_full
cls
echo 🗑️ Повне очищення Edge...
echo Чи бажаєте зберегти резервну копію перед видаленням? (1 - Так, 2 - Ні)
choice /c 12 /n
if errorlevel 2 goto edge_full_delete_nobackup
if errorlevel 1 goto edge_full_delete_withbackup

:edge_full_delete_withbackup
taskkill /IM msedge.exe /F >nul 2>&1
timeout /t 2 /nobreak >nul

setlocal enabledelayedexpansion
set "SRC=%LOCALAPPDATA%\Microsoft\Edge\User Data"
set "DST=%~dp0Backup\Edge\Full_%DATE:/=-%_%TIME::=-%"
set "DST=!DST: =_!"

if exist "!SRC!" (
    mkdir "!DST!" >nul 2>&1
    xcopy /E /I /Y "!SRC!" "!DST!" >nul
    rd /s /q "!SRC!"
    echo ✅ Всі дані Edge видалені з резервною копією!
) else (
    echo ❌ Дані Edge не знайдено.
)

endlocal
pause
goto browser_edge

:edge_full_delete_nobackup
taskkill /IM msedge.exe /F >nul 2>&1
timeout /t 2 /nobreak >nul

set "SRC=%LOCALAPPDATA%\Microsoft\Edge\User Data"

if exist "%SRC%" (
    rd /s /q "%SRC%"
    echo ✅ Всі дані Edge видалені без резервної копії!
) else (
    echo ❌ Дані Edge не знайдено.
)

pause
goto browser_edge

:: ----------- Mozilla Firefox -----------

:firefox_full
cls
echo 🗑️ Повне очищення Firefox...
echo Чи бажаєте зберегти резервну копію перед видаленням? (1 - Так, 2 - Ні)
choice /c 12 /n
if errorlevel 2 goto firefox_full_delete_nobackup
if errorlevel 1 goto firefox_full_delete_withbackup

:firefox_full_delete_withbackup
taskkill /IM firefox.exe /F >nul 2>&1
timeout /t 2 /nobreak >nul

setlocal enabledelayedexpansion
set "SRC=%APPDATA%\Mozilla\Firefox"
set "DST=%~dp0Backup\Firefox\Full_%DATE:/=-%_%TIME::=-%"
set "DST=!DST: =_!"

if exist "!SRC!" (
    mkdir "!DST!" >nul 2>&1
    xcopy /E /I /Y "!SRC!" "!DST!" >nul
    rd /s /q "!SRC!"
    echo ✅ Всі дані Firefox видалені з резервною копією!
) else (
    echo ❌ Дані Firefox не знайдено.
)

endlocal
pause
goto browser_firefox

:firefox_full_delete_nobackup
taskkill /IM firefox.exe /F >nul 2>&1
timeout /t 2 /nobreak >nul

set "SRC=%APPDATA%\Mozilla\Firefox"

if exist "%SRC%" (
    rd /s /q "%SRC%"
    echo ✅ Всі дані Firefox видалені без резервної копії!
) else (
    echo ❌ Дані Firefox не знайдено.
)

pause
goto browser_firefox

:: ----------- Opera -----------

:opera_full
cls
echo 🗑️ Повне очищення Opera...
echo Чи бажаєте зберегти резервну копію перед видаленням? (1 - Так, 2 - Ні)
choice /c 12 /n
if errorlevel 2 goto opera_full_delete_nobackup
if errorlevel 1 goto opera_full_delete_withbackup

:opera_full_delete_withbackup
taskkill /IM opera.exe /F >nul 2>&1
timeout /t 2 /nobreak >nul

setlocal enabledelayedexpansion
set "SRC=%APPDATA%\Opera Software"
set "DST=%~dp0Backup\Opera\Full_%DATE:/=-%_%TIME::=-%"
set "DST=!DST: =_!"

if exist "!SRC!" (
    mkdir "!DST!" >nul 2>&1
    xcopy /E /I /Y "!SRC!" "!DST!" >nul
    rd /s /q "!SRC!"
    echo ✅ Всі дані Opera видалені з резервною копією!
) else (
    echo ❌ Дані Opera не знайдено.
)

endlocal
pause
goto browser_opera

:opera_full_delete_nobackup
taskkill /IM opera.exe /F >nul 2>&1
timeout /t 2 /nobreak >nul

set "SRC=%APPDATA%\Opera Software"

if exist "%SRC%" (
    rd /s /q "%SRC%"
    echo ✅ Всі дані Opera видалені без резервної копії!
) else (
    echo ❌ Дані Opera не знайдено.
)

pause
goto browser_opera

:: ----------- Brave -----------

:brave_full
cls
echo 🗑️ Повне очищення Brave...
echo Чи бажаєте зберегти резервну копію перед видаленням? (1 - Так, 2 - Ні)
choice /c 12 /n
if errorlevel 2 goto brave_full_delete_nobackup
if errorlevel 1 goto brave_full_delete_withbackup

:brave_full_delete_withbackup
taskkill /IM brave.exe /F >nul 2>&1
timeout /t 2 /nobreak >nul

setlocal enabledelayedexpansion
set "SRC=%LOCALAPPDATA%\BraveSoftware\Brave-Browser"
set "DST=%~dp0Backup\Brave\Full_%DATE:/=-%_%TIME::=-%"
set "DST=!DST: =_!"

if exist "!SRC!" (
    mkdir "!DST!" >nul 2>&1
    xcopy /E /I /Y "!SRC!" "!DST!" >nul
    rd /s /q "!SRC!"
    echo ✅ Всі дані Brave видалені з резервною копією!
) else (
    echo ❌ Дані Brave не знайдено.
)

endlocal
pause
goto browser_brave

:brave_full_delete_nobackup
taskkill /IM brave.exe /F >nul 2>&1
timeout /t 2 /nobreak >nul

set "SRC=%LOCALAPPDATA%\BraveSoftware\Brave-Browser"

if exist "%SRC%" (
    rd /s /q "%SRC%"
    echo ✅ Всі дані Brave видалені без резервної копії!
) else (
    echo ❌ Дані Brave не знайдено.
)

pause
goto browser_brave




:: ----------- Меню месенджерів -----------

:messenger_select
cls
echo ================================
echo       ВИБІР МЕСЕНДЖЕРА
echo ================================
echo 1. Telegram
echo 2. Viber
echo 3. WhatsApp
echo 4. Signal
echo 0. Назад
set /p m=Ваш вибір: 

if "%m%"=="1" goto messenger_telegram
if "%m%"=="2" goto messenger_viber
if "%m%"=="3" goto messenger_whatsapp
if "%m%"=="4" goto messenger_signal
if "%m%"=="0" goto main_menu

echo ❌ Невірний вибір.
pause
goto messenger_select

:: ===== Telegram =====

:messenger_telegram
cls
echo ==== TELEGRAM ====
echo 1. Очистити кеш
echo 2. Повне очищення даних
echo 0. Назад
set /p tg=Ваш вибір: 

if "%tg%"=="0" goto messenger_select
taskkill /IM telegram.exe /F >nul 2>&1
taskkill /IM Telegram.exe /F >nul 2>&1

:: Путь к обычной версии
set "DIR1=%APPDATA%\Telegram Desktop"
:: Путь к версии из Microsoft Store (WindowsApps)
set "DIR2=%LOCALAPPDATA%\Packages\TelegramMessengerLLP.TelegramDesktop_qkzqz4x7x4xgm\LocalCache\Roaming\Telegram Desktop"

if "%tg%"=="1" (
    call :backup_and_delete "%DIR1%\tdata\cache" "Telegram" "Cache"
    call :backup_and_delete "%DIR2%\tdata\cache" "Telegram_MS" "Cache"
    goto messenger_select
)

if "%tg%"=="2" (
    call :backup_and_delete "%DIR1%" "Telegram" "Full"
    call :backup_and_delete "%DIR2%" "Telegram_MS" "Full"
    goto messenger_select
)

echo ❌ Невірний вибір.
pause
goto messenger_telegram

:: ===== Viber =====

:messenger_viber
cls
echo ==== VIBER ====
echo 1. Очистити кеш
echo 2. Повне очищення даних
echo 0. Назад
set /p vb=Ваш вибір: 

if "%vb%"=="0" goto messenger_select
taskkill /IM Viber.exe /F >nul 2>&1

set "DIR1=%APPDATA%\ViberPC"
set "DIR2=%LOCALAPPDATA%\Packages\ViberPC.Viber_*\LocalCache"

if "%vb%"=="1" (
    call :backup_and_delete "%DIR1%\Cache" "Viber" "Cache"
    call :backup_and_delete "%DIR2%\Cache" "Viber_MS" "Cache"
    goto messenger_select
)

if "%vb%"=="2" (
    call :backup_and_delete "%DIR1%" "Viber" "Full"
    call :backup_and_delete "%DIR2%" "Viber_MS" "Full"
    goto messenger_select
)

echo ❌ Невірний вибір.
pause
goto messenger_viber

:: ===== WhatsApp =====

:messenger_whatsapp
cls
echo ==== WHATSAPP ====
echo 1. Очистити кеш
echo 2. Повне очищення даних
echo 0. Назад
set /p wa=Ваш вибір: 

if "%wa%"=="0" goto messenger_select
taskkill /IM WhatsApp.exe /F >nul 2>&1

set "DIR1=%APPDATA%\WhatsApp"
set "DIR2=%LOCALAPPDATA%\Packages\5319275A.WhatsAppDesktop_cv1g1gvanyjgm\LocalCache\Roaming\WhatsApp"

if "%wa%"=="1" (
    call :backup_and_delete "%DIR1%\Cache" "WhatsApp" "Cache"
    call :backup_and_delete "%DIR2%\Cache" "WhatsApp_MS" "Cache"
    goto messenger_select
)

if "%wa%"=="2" (
    call :backup_and_delete "%DIR1%" "WhatsApp" "Full"
    call :backup_and_delete "%DIR2%" "WhatsApp_MS" "Full"
    goto messenger_select
)

echo ❌ Невірний вибір.
pause
goto messenger_whatsapp

:: ===== Signal =====

:messenger_signal
cls
echo ==== SIGNAL ====
echo 1. Очистити кеш
echo 2. Повне очищення даних
echo 0. Назад
set /p sg=Ваш вибір: 

if "%sg%"=="0" goto messenger_select
taskkill /IM Signal.exe /F >nul 2>&1

set "DIR1=%APPDATA%\Signal"
set "DIR2=%LOCALAPPDATA%\Packages\SignalSignal_*\LocalCache\Roaming\Signal"

if "%sg%"=="1" (
    call :backup_and_delete "%DIR1%\Cache" "Signal" "Cache"
    call :backup_and_delete "%DIR2%\Cache" "Signal_MS" "Cache"
    goto messenger_select
)

if "%sg%"=="2" (
    call :backup_and_delete "%DIR1%" "Signal" "Full"
    call :backup_and_delete "%DIR2%" "Signal_MS" "Full"
    goto messenger_select
)

echo ❌ Невірний вибір.
pause
goto messenger_signal


:: ===== Универсальная функция резервного копирования и удаления =====

:backup_and_delete
REM %1 - папка для очистки
REM %2 - имя месенджера (для папки Backup)
REM %3 - тип очистки (Cache или Full)

setlocal enabledelayedexpansion
set "TARGET=%~1"
set "APP=%~2"
set "TYPE=%~3"

if not exist "!TARGET!" (
    echo ⚠️ Папка не знайдена: !TARGET!
    endlocal
    goto :eof
)

set "BACKUP_DIR=%~dp0Backup\%APP%\%TYPE%_%DATE:/=-%_%TIME::=-%"
set "BACKUP_DIR=!BACKUP_DIR: =_!"
mkdir "!BACKUP_DIR!" >nul 2>&1

echo 🔄 Копіюю дані з !TARGET! до резервної копії...
xcopy /E /I /Y "!TARGET!" "!BACKUP_DIR!" >nul

echo 🗑️ Видаляю !TYPE! для !APP!...
rd /s /q "!TARGET!"

echo ✅ Очищення !APP! типу !TYPE! завершено.
endlocal
goto :eof



::Вимкнення автозапуску браузерів та месенджерів

:disable_startup_messengers_browsers
cls
echo ══════════════════════════════════════════════════════════
echo    🔧 Вимкнення автозапуску браузерів та месенджерів...
echo ══════════════════════════════════════════════════════════

setlocal enabledelayedexpansion

:: Список exe імен без розширення
set apps=chrome msedge firefox opera brave telegram viber whatsapp signal discord skype

:: 1. Видалення з автозапуску в реєстрі
for %%A in (%apps%) do (
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "%%A" /f >nul 2>&1
    reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "%%A" /f >nul 2>&1
)

:: 2. Видалення ярликів з shell:startup (Current user)
set "STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
for %%A in (%apps%) do (
    del /f /q "%STARTUP_DIR%\%%A.lnk" >nul 2>&1
)

:: 3. Видалення з Task Scheduler
for %%A in (%apps%) do (
    for /f "delims=" %%T in ('schtasks /query /fo LIST /v ^| findstr /i "TaskName:"') do (
        echo %%T | findstr /i "%%A" >nul && (
            set "taskname=%%T"
            set "taskname=!taskname:~9!"
            schtasks /delete /tn "!taskname!" /f >nul 2>&1
        )
    )
)

echo ✅ Автозапуск браузерів та месенджерів очищено.
endlocal
pause
goto main_menu


:: ----------- МЕНЮ ВІДНОВЛЕННЯ -----------

:restore_menu
cls
echo ================================
echo    Відновлення з резервної копії
echo ================================
setlocal enabledelayedexpansion

set "i=0"
for /f "delims=" %%A in ('dir /b /ad "%~dp0Backup"') do (
    set /a i+=1
    set "app_!i!=%%A"
    echo !i!. %%A
)

if !i! equ 0 (
    echo ❌ Немає резервних копій.
    pause
    endlocal
    goto main_menu
)

echo 0. Назад
echo ================================
set /p sel=Виберіть програму: 
if "%sel%"=="0" endlocal & goto main_menu

for /f "delims=0123456789" %%Z in ("%sel%") do (
    echo ❌ Невірний номер.
    pause
    endlocal
    goto restore_menu
)

if %sel% GTR !i! (
    echo ❌ Невірний номер.
    pause
    endlocal
    goto restore_menu
)

set "RESTORE_APP=!app_%sel%!"
endlocal & set "RESTORE_APP=%RESTORE_APP%"
goto restore_select_type

:restore_select_type
cls
setlocal enabledelayedexpansion
set "APP_FOLDER=%~dp0Backup\%RESTORE_APP%"

set "j=0"
for /f "delims=" %%B in ('dir /b /ad "%APP_FOLDER%"') do (
    set /a j+=1
    set "type_!j!=%%B"
    echo !j!. %%B
)

if !j! equ 0 (
    echo ❌ Не знайдено резервних копій для %RESTORE_APP%.
    pause
    endlocal
    goto restore_menu
)

echo 0. Назад
echo ================================
set /p typeSel=Виберіть тип копії (Full, History, Cache...): 
if "%typeSel%"=="0" endlocal & goto restore_menu

for /f "delims=0123456789" %%Z in ("%typeSel%") do (
    echo ❌ Невірний номер.
    pause
    endlocal
    goto restore_select_type
)

if %typeSel% GTR !j! (
    echo ❌ Невірний номер.
    pause
    endlocal
    goto restore_select_type
)

set "RESTORE_TYPE=!type_%typeSel%!"
endlocal & set "RESTORE_TYPE=%RESTORE_TYPE%"
goto restore_select_date

:restore_select_date
cls
setlocal enabledelayedexpansion
set "TYPE_FOLDER=%~dp0Backup\%RESTORE_APP%\%RESTORE_TYPE%"

if not exist "!TYPE_FOLDER!" (
    echo ❌ Копії типу %RESTORE_TYPE% не знайдено.
    pause
    endlocal
    goto restore_select_type
)

set k=0
for /f "delims=" %%D in ('dir /b /ad "!TYPE_FOLDER!"') do (
    set /a k+=1
    set "date_!k!=%%D"
    echo !k!. %%D
)

if !k! equ 0 (
    echo ❌ Немає дат резервних копій.
    pause
    endlocal
    goto restore_select_type
)

echo 0. Назад
set /p datenum=Введіть номер дати: 
if "%datenum%"=="0" (
    endlocal
    goto restore_select_type
)

for /f "delims=0123456789" %%Z in ("%datenum%") do (
    echo ❌ Невірний номер.
    pause
    endlocal
    goto restore_select_date
)

if %datenum% GTR !k! (
    echo ❌ Невірний номер.
    pause
    endlocal
    goto restore_select_date
)

set "RESTORE_DATE=!date_%datenum%!"
endlocal & (
    set "RESTORE_DATE=%RESTORE_DATE%"
    set "RESTORE_PATH=%~dp0Backup\%RESTORE_APP%\%RESTORE_TYPE%\%RESTORE_DATE%"
)
goto confirm_restore

:confirm_restore
cls
echo Ви обрали:
echo 📦 Додаток: %RESTORE_APP%
echo 🗂️ Тип копії: %RESTORE_TYPE%
echo 📅 Дата: %RESTORE_DATE%
echo.
echo Це перезапише поточні дані. Продовжити? (Y/N)
choice /c YN /n >nul
if errorlevel 2 goto restore_menu

call :restore_backup "%RESTORE_PATH%" "%RESTORE_APP%"
goto restore_menu

:restore_backup
REM %1 - шлях до резервної копії
REM %2 - назва програми

setlocal
set "SRC=%~1"
set "APP=%~2"

:: Прописываем пути
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
    echo ❌ Невідома програма: %APP%
    pause
    endlocal
    goto :eof
)

echo 🔒 Завершення процесу %APP%.exe
taskkill /F /IM "%APP%.exe" >nul 2>&1

if exist "%DST%" (
    echo 🧹 Видалення старих даних...
    rd /s /q "%DST%"
)

echo ♻️ Відновлення з %SRC%
xcopy /E /I /Y "%SRC%" "%DST%" >nul

echo ✅ Відновлення %APP% завершено.
pause
endlocal
goto :eof



::ОЧИСТКА ШВИДКОГО ДОСТУПУ

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


::ОЧИЩЕННЯ USB / ЗАПУСКІВ / СЛІДІВ

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

::ВИДАЛЕННЯ ТИМЧАСОВИХ ФАЙЛІВ

:clear_temp_files
cls
echo ==== ВИДАЛЕННЯ ТИМЧАСОВИХ ФАЙЛІВ ====
:: Очищення кешу та тимчасових файлів Windows
rd /s /q "%TEMP%" >nul 2>&1
mkdir "%TEMP%" >nul 2>&1
cleanmgr /sagerun:1 >nul 2>&1
echo ✅ Тимчасові файли очищені!
pause
goto main_menu

:: ----------- ПЕРЕВІРКА ПІДОЗРІЛИХ ПРОЦЕСІВ -----------

:CheckThreats_Debug
cls
echo Перевірка процесів на підозрілі ключові слова...

setlocal enabledelayedexpansion
set "KEYWORDS=keylogger cheat cheater hack hacker virus trojan miner mine"
set "OUTLOG=%~dp0CheckThreats.log"
del "!OUTLOG!" >nul 2>&1

set "found=false"

for /f "tokens=2 delims=," %%P in ('tasklist /fo csv /nh') do (
    set "proc=%%~P"
    set "proc=!proc:"=!"
    for %%K in (!KEYWORDS!) do (
        echo !proc! | findstr /i "%%K" >nul
        if !errorlevel! == 0 (
            echo Підозрілий процес: !proc! (ключове слово: %%K)
            echo Підозрілий процес: !proc! (ключове слово: %%K) >> "!OUTLOG!"
            set "found=true"
        )
    )
)

if "!found!"=="false" (
    echo ✅ Підозрілих процесів не виявлено.
) else (
    echo.
    echo 🔍 Результати також збережено у: "!OUTLOG!"
)

endlocal
pause
goto main_menu



:: ----------- ХОЛОДНЕ ВИДАЛЕННЯ -----------

:total_wipe
cls
echo ==========================================================
echo     🧨 Увага! Тотальне видалення даних браузерів і месенджерів!
echo ==========================================================
echo Це призведе до повної втрати даних без можливості відновлення.
echo Продовжити?
echo 1. Так
echo 2. Ні
set /p choice=Ваш вибір (1/2): 

if "%choice%"=="2" goto main_menu
if "%choice%" NEQ "1" (
    echo ❌ Невірний вибір.
    pause
    goto total_wipe
)

echo.
echo 🔪 Завершення процесів...
taskkill /F /IM chrome.exe /IM msedge.exe /IM firefox.exe /IM opera.exe /IM brave.exe ^
    /IM telegram.exe /IM discord.exe /IM skype.exe /IM Viber.exe /IM WhatsApp.exe /IM Signal.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo 🧹 Видалення папок...
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

echo.
echo ✅ Всі дані браузерів та месенджерів були безповоротно видалені.
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
::pause

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
        ::pause
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
