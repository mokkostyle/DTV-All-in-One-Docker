@echo off
echo Initializing environment...

:: 必要なディレクトリの作成
if not exist "conf\edcb" mkdir "conf\edcb"
if not exist "conf\mirakurun" mkdir "conf\mirakurun"
if not exist "conf\konomitv" mkdir "conf\konomitv"
if not exist "conf\scan_result" mkdir "conf\scan_result"
if not exist "dist\var\local\edcb\Setting" mkdir "dist\var\local\edcb\Setting"
if not exist "dist\scan_result" mkdir "dist\scan_result"
if not exist "data\edcb\EpgData" mkdir "data\edcb\EpgData"
if not exist "data\edcb\LogoData" mkdir "data\edcb\LogoData"
if not exist "data\mirakurun" mkdir "data\mirakurun"
if not exist "data\konomitv" mkdir "data\konomitv"
if not exist "logs\konomitv" mkdir "logs\konomitv"

:: 空ファイルの生成
:: Windowsでは 'type nul >' で空ファイルが作成できます。既に存在する場合は何もしません。
if not exist "conf\konomitv\config.yaml" type nul > "conf\konomitv\config.yaml"
if not exist "conf\edcb\EpgTimerSrv.ini" type nul > "conf\edcb\EpgTimerSrv.ini"
if not exist "conf\edcb\BonDriver_mirakc(LinuxMirakc).ChSet4.txt" type nul > "conf\edcb\BonDriver_mirakc(LinuxMirakc).ChSet4.txt"
if not exist "conf\edcb\ChSet5.txt" type nul > "conf\edcb\ChSet5.txt"
if not exist "conf\edcb\HttpPublic.ini" type nul > "conf\edcb\HttpPublic.ini"
if not exist "conf\mirakurun\channels.yml" type nul > "conf\mirakurun\channels.yml"
if not exist "conf\mirakurun\tuners.yml" type nul > "conf\mirakurun\tuners.yml"
if not exist "conf\mirakurun\server.yml" type nul > "conf\mirakurun\server.yml"

echo Starting Docker Compose...

:: Docker Compose の実行
docker compose up -d --build

pause