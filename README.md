# Android TV Apple TV 4K Debloat & Launcher System

Clean, lightweight Apple TV 4K interface and debloating solution for Android TV (TCL Smart TV, Android 11).

> [!TIP]
> **Looking for the AI Assistant Prompt?** Check out [`PROMPT.md`](file:///C:/Users/sanik/tv_debloat/PROMPT.md) for the complete, step-by-step instructions to recreate, customize, debloat, and verify this setup on any Android TV or Google TV box using an AI coding assistant.

---

## 📺 Device Summary
- **Device Model**: TCL Smart TV (`G07_4K_GB_NF` / `G07`)
- **Android OS Version**: Android 11 (API level 30, build `RP1A.200622.001`)
- **Connected ADB Endpoint**: `192.168.1.128:5555`

---

## 🗂️ Backup Summary
Full device state and properties were backed up before applying changes into the [`backup/`](file:///C:/Users/sanik/tv_debloat/backup/) directory:
- [`packages_all.txt`](file:///C:/Users/sanik/tv_debloat/backup/packages_all.txt): Complete manifest of all installed packages
- [`packages_disabled.txt`](file:///C:/Users/sanik/tv_debloat/backup/packages_disabled.txt): Initial list of disabled packages
- [`packages_enabled.txt`](file:///C:/Users/sanik/tv_debloat/backup/packages_enabled.txt): Initial list of enabled packages
- [`getprop.txt`](file:///C:/Users/sanik/tv_debloat/backup/getprop.txt): Complete hardware, build, and system properties
- [`settings_global.txt`](file:///C:/Users/sanik/tv_debloat/backup/settings_global.txt): Android global settings table
- [`settings_secure.txt`](file:///C:/Users/sanik/tv_debloat/backup/settings_secure.txt): Android secure settings table
- [`settings_system.txt`](file:///C:/Users/sanik/tv_debloat/backup/settings_system.txt): Android system settings table

---

## 🧹 Debloat Breakdown

All bloatware was disabled using `pm disable-user --user 0 <package>` (never uninstalled, ensuring 100% reversible safety):

### 1. Manufacturer Telemetry & Analytics
- `com.tcl.usercenter`: TCL user profile tracking & cloud sync
- `com.tcl.useragreement`: TCL policy tracking & analytical agreement prompts
- `com.google.android.feedback`: Google crash/usage reporting daemon

### 2. Manufacturer Content & Ad Services
- `com.tcl.waterfall.overseas`: TCL recommendation rows & sponsored ad stream
- `com.tcl.channelplus`: TCL Channel promoted video content
- `com.tcl.tclchannel.overlay`: TCL Channel overlay integration
- `android.autoinstalls.config.google.gtvpai`: Google TV Partner auto-installer & promotional app injector
- `com.tcl.partnercustomizer`: OEM commercial customization agent

### 3. Background Services & Duplicates
- `com.tcl.guard`: TCL Security Guard / cleaner background service
- `com.tcl.MultiScreenInteraction_TV`: TCL duplicate screen sharing agent
- `com.tcl.dashboard`: TCL duplicate dashboard overlay
- `com.tcl.messagebox`: TCL broadcast push notification dialogs
- `com.tcl.suspension`: TCL floating suspension window
- `com.tcl.tv.tclhome_passive`: Passive IoT smart home background listener
- `com.google.android.apps.nbu.smartconnect.tv`: Nearby Share / Smart Connect background agent

### 4. Preloaded Apps & Demos
- `com.tcl.esticker`: Retail shop demo mode banner
- `com.tcl.hotelmenu`: Hospitality / hotel mode interface
- `com.tcl.notereminder`: TCL note reminder sticky app
- `com.tcl.browser`: TCL stock browser
- `com.tcl.initsetup`: First boot setup wizard
- `com.android.printspooler`: Print spooler service
- `com.google.android.play.games`: Play Games background framework

### 5. Unselected Features & Voice Services (User-Specified)
- Voice Assistants: `com.google.android.katniss`, `com.tcl.assistant`, `com.google.android.tv.assistant`, `com.tcl.smartalexa`
- Screen Mirroring: `com.tcl.miracast`
- Firmware Updates: `com.tcl.ttvs` (TCL OTA update daemon)
- Preloaded Streaming: `com.sonyliv`, `au.com.stan.and`, `tv.wuaki.apptv`, `com.google.android.videos`, `com.google.android.youtube.tvmusic`

### 6. Stock Launcher & Setup Wizard Takeover Prevention
- `com.google.android.apps.tv.launcherx`: Stock Google TV Launcher disabled
- `com.google.android.tungsten.setupwraith`: Google TV Setup Wizard disabled (old setup Wi-Fi networks safely cleaned first to prevent Wi-Fi dropping)

### 7. Kept Intact (Load-Bearing Core Services)
- Active user streaming apps: **Netflix**, **Prime Video**, **JioHotstar**, **YouTube**, **Airtel Xstream TV**, **Stremio**, **Cricfy TV**
- Google Cast / Chromecast built-in: `com.google.android.apps.mediashell`
- TV Hardware & Tuner: `com.tcl.tv`, `com.tcl.tvinput`, `com.android.providers.tv`, `com.tcl.system.server`, `com.tvos`
- Remote Control & Bluetooth: `com.android.bluetooth`, `com.tcl.autopair`, `com.google.android.tv.remote.service`, `com.tcl.keyhelp`, `com.tcl.micmanager`
- Keyboards: `com.android.inputdevices`, `com.google.android.inputmethod.latin`, `com.tcl.inputmethod.international`
- Google Play Store & Services: `com.android.vending`, `com.google.android.gms`, `com.google.android.gsf`

---

## 🛡️ Ad-Blocking Private DNS

AdGuard Private DNS resolver has been configured system-wide:
```bash
adb shell settings put global private_dns_specifier dns.adguard-dns.com
adb shell settings put global private_dns_mode hostname
```
> [!NOTE]
> Private DNS blocks system and in-app tracker domains, telemetry, and web banner ads. It **does not block YouTube in-video ads**, as YouTube serves ads directly from the same media CDN streams as the video content.

### Undo Private DNS
To revert back to default automatic network DNS at any time:
```bash
adb shell settings put global private_dns_mode opportunistic
adb shell settings delete global private_dns_specifier
```

---

## 🍏 Apple TV 4K Launcher Design & Features

- **Aesthetic**: Pure pitch-black OLED background (`#000000`) with dynamic theme wallpaper switching support.
- **Typography**: Clean, open-license typography using the Outfit font family (`Outfit-Light` and `Outfit-Regular`).
- **Clock & Greeting**: Dynamic greeting ("Good Morning", "Good Afternoon", "Good Evening, Nero and Sanu!"), large thin clock, and date pinned top left.
- **Top Bar Frosted Pills**: Pinned top right:
  - **Live Weather**: Displays live temperature and conditions (e.g. `28° Clear`).
  - **Inputs Pill**: Pressing Inputs (or remote `TV_INPUT` button) reveals a glass dropdown listing HDMI 1, HDMI 2, HDMI 3 (PlayStation 5), AV Input, and Live TV / Cable, switching directly via Android's TV Input Framework (`content://android.media.tv/passthrough/`).
  - **Controls (Control Center)**: Frosted glass slide-out quick-settings panel giving one-click access to Wi-Fi settings, Display/Picture settings, System settings, Screensaver trigger, and Theme Wallpaper switching.
- **Frosted Glass Floating Dock**: Translucent rounded dock band sharing the exact frosted glass material (`@color/pill_bg` `#24FFFFFF` and 1dp stroke `#3AFFFFFF`) as the top-bar pills, holding the 4 prioritized apps with generous 28dp spacing:
  1. **Netflix** (`com.netflix.ninja`)
  2. **Prime Video** (`com.amazon.amazonvideo.livingroom`)
  3. **JioHotstar** (`in.startv.hotstar`)
  4. **YouTube** (`com.google.android.youtube.tv`)
- **Focused App Title & Metadata Taglines**:
  - Focusing any app on the top Dock dynamically displays its large clean title (44sp `Outfit-Light`) paired with a refined category tagline (13sp `Outfit-Regular`, `#B0FFFFFF`) positioned directly above the dock band:
    - **Netflix**: *"Popular Series • Sci-Fi • 4K HDR"*
    - **Prime Video**: *"Included with Prime • Award-Winning Originals & Movies"*
    - **JioHotstar**: *"Live Cricket • Blockbuster Movies • Hotstar Specials"*
    - **YouTube**: *"Stream Endless 4K HDR Video • Music & Creators"*
    - **Airtel Xstream**: *"Live TV Channels • Web Series & Movies"*
    - **Zee5**: *"Blockbusters • TV Shows & Exclusive Originals"*
    - **Apple TV**: *"Apple Originals • Award-Winning 4K HDR Films"*
    - **Stremio**: *"Stream Movies, TV Series & Addons in 4K"*
  - Transitions with a smooth 180ms horizontal slide and alpha crossfade on navigation, paired with the full-screen dynamic ambient color bloom over the wallpaper.
  - Automatically fades out when scrolling down into the Favorites carousel and 4-column "ALL APPS" grid, preserving pure readability for your app library.
- **Favorite Series Shelf & Deep Links**:
  - Horizontal carousel positioned directly below the Dock band featuring quick-launch cards for favorite TV series:
    - **Seinfeld** (*Jerry's Apartment 5A* • Netflix)
    - **The Big Bang Theory** (*Apartment 4A* • Netflix)
    - **Friends** (*Central Perk* • Netflix)
    - **Brooklyn Nine-Nine** (*99th Precinct Bullpen* • Netflix)
    - **Modern Family** (*Dunphy Living Room* • Hotstar)
    - **Game of Thrones** (*Great Hall of the Red Keep* • Hotstar)
  - **Empty Iconic Room Aesthetic**: All backdrops feature pure architecture and interior sets with **zero people or characters**.
  - **Universal Hero Crossfades**: Highlighting any series card smoothly transitions its backdrop into the hero area across **all themes**.
  - **Optical Parallax Counter-Pan**: D-pad navigation between adjacent cards applies an authentic optical parallax pan (`-20dp` to `+20dp`) to the backdrop for tangible cinematic depth.
  - **Instant Deep-Linking**: Clicking a card opens directly into Leanback playback using native URI routing (`com.netflix.ninja` leanback intent with playback extra, Hotstar browsable intent).
- **Themes & Wallpaper Engine**:
  - Switch wallpapers on the fly via Control Center or broadcast intent:
    - `hero`: Dynamic Top Shelf cinematic backdrops
    - `got`: Game of Thrones — *The Wall • Westeros*
    - `sonoma`: Apple macOS Sonoma Aerial Horizon
    - `mojave`: Apple macOS Mojave Night Dunes
    - `black`: Pure OLED Pitch Black (`#000000`)
  - Intent command: `adb shell am broadcast -a com.appletv.launcher.SET_WALLPAPER --es wallpaper "<theme>"`
- **Dynamic Ambient Glow**: Displays a full-background radial bloom with smooth 220ms crossfade, sampled from the focused app's banner (e.g. Netflix Red `#E50914`, Prime Video Cyan `#00A8E1`, JioHotstar Blue `#1F80E0`, YouTube Red `#FF0000`).
- **Rounded App Tiles & Selection Pill**: All app cards, banners, and fallback icons in both the dock and the 4-column grid are uniformly clipped to smooth `18dp` rounded corners (`RoundedCardView` and `RoundedImageView`), perfectly matching the curvature and stroke of the springing glass selection pill.
- **Single Spring Glass Highlight**: Translucent glass card highlight that animates and springs from tile to tile with an OvershootInterpolator.
- **Deterministic D-Pad Navigation**:
  - Horizontal Left/Right stops strictly at boundaries.
  - Pressing Down from dock moves to the Favorites shelf; Down from Favorites scrolls into the 4-column "ALL APPS" grid.
  - Up from row 0 of grid returns to the exact favorite tile; Up from Favorites returns to the Dock.
  - Up from dock navigates to top bar pills without escaping boundaries.
  - Remembers last focused tile and returns cleanly on Back button.
- **Apple TV-Style App Reordering (All Apps Grid)**:
  - **Enter Reorder Mode**: Long-press **OK / Select** or press the **Menu / Options** button on any app tile in the 4-column grid.
  - **Visual Jiggle & Floating HUD**: The selected app card elevates to 1.10x scale with an authentic tvOS continuous wobble animation, while a frosted glass pill (*"Moving [App Name] • Use D-Pad • OK Done"*) slides in at the top center.
  - **Intuitive Movement**: Use D-Pad **Left**, **Right**, **Up**, and **Down** to swap the app across columns or rows with zero view recreation.
  - **Save & Exit**: Press **OK** or **Back** to finish; the new order is immediately persisted to `SharedPreferences` and preserved across TV reboots. Newly installed apps automatically append to the end.
- **Dedicated Remote Shortcut Buttons (TCL RC813 Remote)**:
  - **Netflix**, **Prime Video**, and **YouTube** hardware shortcut buttons on the physical remote are mapped directly to launch their respective apps.
  - Features dual-layer interception: native foreground dispatch inside [`MainActivity.java`](file:///C:/Users/sanik/tv_debloat/launcher/src/com/appletv/launcher/MainActivity.java) and system-wide background routing via [`RemoteButtonService.java`](file:///C:/Users/sanik/tv_debloat/launcher/src/com/appletv/launcher/RemoteButtonService.java) (`AccessibilityService`), ensuring the buttons work from anywhere on the TV.
- **Ultra-Lightweight**: No blur rendering, no video decoding threads, no polling loop, zero memory leak risk for the TV's 1 GB RAM.

---

## 🔧 How to Customize

### 1. Changing the Dock Apps & Order
Edit [`MainActivity.java`](file:///C:/Users/sanik/tv_debloat/launcher/src/com/appletv/launcher/MainActivity.java#L84-L90):
```java
private static final String[] DOCK_PACKAGES = {
    "com.netflix.ninja",                     // 1st Dock App
    "com.amazon.amazonvideo.livingroom",     // 2nd Dock App
    "in.startv.hotstar",                     // 3rd Dock App
    "com.google.android.youtube.tv"          // 4th Dock App
};
```
Then run [`build_and_install.bat`](file:///C:/Users/sanik/tv_debloat/scripts/build_and_install.bat) or [`build_and_install.ps1`](file:///C:/Users/sanik/tv_debloat/scripts/build_and_install.ps1).

### 2. Changing the Wallpaper
To replace the pitch-black background with a custom wallpaper or gradient:
1. Place your wallpaper image (e.g. `wallpaper.jpg`) into `res/drawable/`
2. In [`activity_main.xml`](file:///C:/Users/sanik/tv_debloat/launcher/res/layout/activity_main.xml#L7), change:
   ```xml
   android:background="@color/pitch_black"
   ```
   to:
   ```xml
   android:background="@drawable/wallpaper"
   ```
3. Run [`build_and_install.bat`](file:///C:/Users/sanik/tv_debloat/scripts/build_and_install.bat).

### 3. Re-Enabling Any Individual App
To re-enable any disabled package individually over ADB:
```bash
adb shell pm enable <package.name>
```
For example, to restore Google Assistant:
```bash
adb shell pm enable com.google.android.katniss
adb shell pm enable com.google.android.tv.assistant
```
To re-enable the stock launcher:
```bash
adb shell pm enable com.google.android.apps.tv.launcherx
adb shell cmd package set-home-activity com.google.android.apps.tv.launcherx/.MainActivity
```

### 4. Personalizing the Greeting Name
In [`MainActivity.java`](file:///C:/Users/sanik/tv_debloat/launcher/src/com/appletv/launcher/MainActivity.java#L85):
```java
private static final String USER_NAME = "Nero and Sanu";
```
Change `"Sanik"` to any name you prefer, then run [`build_and_install.bat`](file:///C:/Users/sanik/tv_debloat/scripts/build_and_install.bat).

---

## 🔄 Restoration
To restore the TV completely back to factory stock settings, run:
- **Windows Batch**: Double-click [`restore.bat`](file:///C:/Users/sanik/tv_debloat/scripts/restore.bat)
- **PowerShell**:
  ```powershell
  powershell -ExecutionPolicy Bypass -File C:\Users\sanik\tv_debloat\scripts\restore.ps1
  ```
The restoration script:
1. Re-enables all disabled system packages
2. Re-enables the stock Google TV launcher
3. Reverts Private DNS back to opportunistic mode
4. Restores default home activity to `com.google.android.apps.tv.launcherx/.MainActivity`
5. Takes a verification screenshot of the restored screen

---

## 🔒 Closing Network ADB & Security Recommendation

> [!CAUTION]
> Leaving port 5555 open over Wi-Fi exposes a plaintext ADB debugging interface to any device connected to your local network. Once you are satisfied with the setup, secure your TV by doing the following:

1. On your TV remote, go to **Settings** > **Device Preferences** > **Developer options**.
2. Turn **OFF** the toggle for **Network debugging** / **Wireless debugging**.
3. Turn **OFF** the toggle for **USB debugging**.
4. Select **Revoke USB debugging authorizations** and confirm **OK**.
5. Restart the TV.
6. Verify from your PC that port 5555 is closed:
   ```powershell
   Test-NetConnection -Port 5555 -ComputerName 192.168.1.128
   ```
   Or:
   ```bash
   nc -vz 192.168.1.128 5555
   ```
   *(The connection should fail or time out, confirming the port is closed)*.
