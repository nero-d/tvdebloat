$ErrorActionPreference = "Stop"

Write-Host "=== Apple TV Launcher Build & Install Script ===" -ForegroundColor Cyan

$JAVA = "C:\Users\sanik\tv_tools\jdk\jdk-17.0.12+7\bin\java.exe"
$JAVAC = "C:\Users\sanik\tv_tools\jdk\jdk-17.0.12+7\bin\javac.exe"
$JAR = "C:\Users\sanik\tv_tools\jdk\jdk-17.0.12+7\bin\jar.exe"
$BUILD_TOOLS = "C:\Users\sanik\tv_tools\android-sdk\build-tools\33.0.2"
$AAPT2 = "$BUILD_TOOLS\aapt2.exe"
$ZIPALIGN = "$BUILD_TOOLS\zipalign.exe"
$D8_JAR = "$BUILD_TOOLS\lib\d8.jar"
$APKSIGNER_JAR = "$BUILD_TOOLS\lib\apksigner.jar"
$PLATFORM = "C:\Users\sanik\tv_tools\android-sdk\platforms\android-33\android.jar"
$KEYSTORE = "C:\Users\sanik\tv_tools\debug.keystore"
$BASE = "C:\Users\sanik\tv_debloat\launcher"

# Clean build directory
Write-Host "[1/7] Cleaning build directory..." -ForegroundColor Yellow
Remove-Item -Path "$BASE\build\gen" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$BASE\build\classes" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$BASE\build\res.zip" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$BASE\build\*.apk" -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "$BASE\build\gen" -Force | Out-Null
New-Item -ItemType Directory -Path "$BASE\build\classes" -Force | Out-Null

# Compile resources with aapt2
Write-Host "[2/7] Compiling resources..." -ForegroundColor Yellow
& $AAPT2 compile --dir "$BASE\res" -o "$BASE\build\res.zip"
if ($LASTEXITCODE -ne 0) { throw "aapt2 compile failed" }

# Link resources with aapt2
Write-Host "[3/7] Linking resources..." -ForegroundColor Yellow
& $AAPT2 link -I $PLATFORM `
    --manifest "$BASE\AndroidManifest.xml" `
    --min-sdk-version 28 --target-sdk-version 33 --version-code 2 --version-name "1.1" `
    -o "$BASE\build\app_unaligned.apk" `
    --java "$BASE\build\gen" `
    "$BASE\build\res.zip"
if ($LASTEXITCODE -ne 0) { throw "aapt2 link failed" }

# Compile Java source files
Write-Host "[4/7] Compiling Java code..." -ForegroundColor Yellow
$javaFiles = (Get-ChildItem -Path "$BASE\src", "$BASE\build\gen" -Recurse -Filter "*.java").FullName
& $JAVAC -encoding UTF-8 -cp $PLATFORM -d "$BASE\build\classes" $javaFiles
if ($LASTEXITCODE -ne 0) { throw "javac failed" }

# Convert to DEX with D8
Write-Host "[5/7] Converting bytecode to Dalvik Executable (classes.dex)..." -ForegroundColor Yellow
$classFiles = (Get-ChildItem -Path "$BASE\build\classes" -Recurse -Filter "*.class").FullName
& $JAVA -cp $D8_JAR com.android.tools.r8.D8 --release --min-api 28 --output "$BASE\build" $classFiles
if ($LASTEXITCODE -ne 0) { throw "d8 failed" }

# Add classes.dex into unaligned apk
Push-Location "$BASE\build"
& $JAR -uf "app_unaligned.apk" "classes.dex"
Pop-Location

# Zipalign
Write-Host "[6/7] Aligning and signing APK..." -ForegroundColor Yellow
Remove-Item -Path "$BASE\build\appletv_launcher.apk" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$BASE\build\appletv_launcher_signed.apk" -Force -ErrorAction SilentlyContinue
& $ZIPALIGN -v -p 4 "$BASE\build\app_unaligned.apk" "$BASE\build\appletv_launcher.apk"
if ($LASTEXITCODE -ne 0) { throw "zipalign failed" }

# Sign APK
& $JAVA -jar $APKSIGNER_JAR sign --ks $KEYSTORE --ks-pass pass:android --ks-key-alias androiddebugkey --key-pass pass:android --out "$BASE\build\appletv_launcher_signed.apk" "$BASE\build\appletv_launcher.apk"
if ($LASTEXITCODE -ne 0) { throw "apksigner failed" }

Write-Host "Build successful: $BASE\build\appletv_launcher_signed.apk" -ForegroundColor Green

# Install on TV
Write-Host "[7/7] Installing to TV over ADB..." -ForegroundColor Yellow
adb connect 192.168.1.128:5555
Start-Sleep -Milliseconds 500
adb -s 192.168.1.128:5555 push "$BASE\build\appletv_launcher_signed.apk" /data/local/tmp/appletv_launcher.apk
adb -s 192.168.1.128:5555 shell pm install -r /data/local/tmp/appletv_launcher.apk
adb -s 192.168.1.128:5555 shell pm grant com.appletv.launcher android.permission.ACCESS_FINE_LOCATION
adb -s 192.168.1.128:5555 shell pm grant com.appletv.launcher android.permission.WRITE_SECURE_SETTINGS
adb -s 192.168.1.128:5555 shell settings put secure screensaver_components com.google.android.apps.tv.dreamx/com.google.android.apps.tv.dreamx.service.Backdrop
adb -s 192.168.1.128:5555 shell settings put secure screensaver_default_component com.google.android.apps.tv.dreamx/com.google.android.apps.tv.dreamx.service.Backdrop
adb -s 192.168.1.128:5555 shell settings put secure screensaver_enabled 1
adb -s 192.168.1.128:5555 shell settings put secure screensaver_activate_on_sleep 1
adb -s 192.168.1.128:5555 shell settings put secure screensaver_activate_on_dock 1
adb -s 192.168.1.128:5555 shell settings put system screen_off_timeout 300000
adb -s 192.168.1.128:5555 shell "cmd package set-home-activity com.appletv.launcher/.MainActivity"
adb -s 192.168.1.128:5555 shell settings put secure enabled_accessibility_services com.appletv.launcher/com.appletv.launcher.RemoteButtonService
adb -s 192.168.1.128:5555 shell settings put secure accessibility_enabled 1
$currentFocus = adb -s 192.168.1.128:5555 shell "dumpsys activity activities | grep mResumedActivity"
if ($currentFocus -match "com.appletv.launcher") {
    adb -s 192.168.1.128:5555 shell am force-stop com.appletv.launcher
    adb -s 192.168.1.128:5555 shell am start -n com.appletv.launcher/.MainActivity
    Start-Sleep -Milliseconds 500
    adb -s 192.168.1.128:5555 shell settings delete secure enabled_accessibility_services
    adb -s 192.168.1.128:5555 shell settings put secure enabled_accessibility_services com.appletv.launcher/com.appletv.launcher.RemoteButtonService
    adb -s 192.168.1.128:5555 shell settings put secure accessibility_enabled 1
    Write-Host "Apple TV Launcher successfully installed and launched!" -ForegroundColor Green
} else {
    Write-Host "Apple TV Launcher successfully installed in background without interrupting active playback!" -ForegroundColor Green
}
