# TV Debloat Restoration Script
# Re-enables all debloated packages and reverts system settings
param (
    [string]$DeviceIp = "192.168.1.128:5555"
)

Write-Host "Connecting to TV at $DeviceIp..." -ForegroundColor Cyan
adb connect $DeviceIp

# All packages disabled during the debloat process
$debloatedPackages = @(
    # Category 1: Telemetry & Analytics
    "com.tcl.usercenter",
    "com.tcl.useragreement",
    "com.google.android.feedback",

    # Category 2: Ad and Recommendation Services
    "com.tcl.waterfall.overseas",
    "com.tcl.channelplus",
    "com.tcl.tclchannel.overlay",
    "android.autoinstalls.config.google.gtvpai",
    "com.tcl.partnercustomizer",

    # Category 3: Background Services & Cleaners
    "com.tcl.guard",
    "com.tcl.MultiScreenInteraction_TV",
    "com.tcl.dashboard",
    "com.tcl.messagebox",
    "com.tcl.suspension",
    "com.tcl.tv.tclhome_passive",
    "com.google.android.apps.nbu.smartconnect.tv",

    # Category 4: Preloaded Apps
    "com.tcl.esticker",
    "com.tcl.hotelmenu",
    "com.tcl.notereminder",
    "com.tcl.browser",
    "com.tcl.initsetup",
    "com.android.printspooler",
    "com.google.android.play.games",

    # Category 5: Optional Voice / Cast / Update / Preloaded Streaming Services
    "com.google.android.katniss",
    "com.google.android.tv.assistant",
    "com.tcl.assistant",
    "com.tcl.smartalexa",
    "com.tcl.miracast",
    "com.tcl.ttvs",
    "com.sonyliv",
    "au.com.stan.and",
    "tv.wuaki.apptv",
    "com.google.android.videos",
    "com.google.android.youtube.tvmusic",

    # Setup Wizard & Stock Launcher
    "com.google.android.tungsten.setupwraith",
    "com.google.android.apps.tv.launcherx"
)

Write-Host "Re-enabling all debloated packages..." -ForegroundColor Yellow
foreach ($pkg in $debloatedPackages) {
    Write-Host "Enabling $pkg..."
    adb shell pm enable $pkg
}

Write-Host "Restoring default Private DNS setting..." -ForegroundColor Yellow
adb shell settings put global private_dns_mode opportunistic
adb shell settings delete global private_dns_specifier

# Reset default home to stock launcher
Write-Host "Resetting default launcher to stock launcherx..." -ForegroundColor Yellow
adb shell "cmd package set-home-activity com.google.android.apps.tv.launcherx/.MainActivity"
adb shell am start -n com.google.android.apps.tv.launcherx/.MainActivity

Write-Host "Restoration complete! Capturing TV status..." -ForegroundColor Green
adb shell screencap -p /sdcard/screenshot_restored.png
adb pull /sdcard/screenshot_restored.png C:\Users\sanik\tv_debloat\screenshots\screenshot_restored.png
Write-Host "Screenshot saved to C:\Users\sanik\tv_debloat\screenshots\screenshot_restored.png"
