# The Prompt

Paste this into Claude Code (or another coding assistant with shell access) on a computer that is
on the same Wi-Fi as the TV. Works on Android TV / Google TV sets (Xiaomi, TCL, Hisense, Sony,
OnePlus, Realme, Nvidia Shield and most others running Android 9 through Android 14). It will not
work on Samsung Tizen, LG webOS or Fire TV.

Before you start, on the TV: Settings → Device Preferences → About → press OK on "Build" 7 times,
then go back → Developer options → turn on USB debugging (and Network/ADB debugging if your TV
shows it). Keep the TV on. Some boxes cut power to their USB port while USB debugging is on, so a
USB speaker or drive plugged into it goes dead until you switch debugging off again. A USB Ethernet
adapter on that port can drop the same way, so plan to do the whole session in one sitting.

---

I want to debloat my Android TV and replace its launcher with a clean, lightweight Apple TV 4K style
home screen. My TV model is: <MODEL NAME HERE>. Work on the real device, step by step, and verify
everything you do with screenshots pulled from the TV. Ask me before anything that depends on my preferences.

### Connect
- Find the TV on my network (hostname, ARP table, or ask me for the IP) and connect over ADB on port 5555.
  If the TV is in another home, I'll give you its Tailscale address instead: use that, don't scan my local network.
- If the stock adb binary fails with "No route to host" on macOS even though the port is open, that is
  macOS Local Network privacy blocking adb. Don't debug it: use the Python `adb-shell` package in a venv
  as the ADB client instead. If its file push hangs on larger files, transfer files as base64 chunks
  through the shell and verify the md5.
- If your own commands can't reach the TV at all while it answers from an ordinary terminal (a sandbox that
  blocks the local network), ask me to run a local TCP relay in a terminal and leave it running.
- If port 5555 stays closed, the TV may only offer Wireless debugging (Google TV sets often do): look for
  `_adb-tls-connect._tcp` with `dns-sd -B` or `adb mdns services`, ask me for the code and port under
  Developer options > Wireless debugging > Pair device with pairing code, then `adb pair`, `adb connect`
  and `adb tcpip 5555`. Android switches Wireless debugging off whenever Wi-Fi drops.
- Tell me when the "Allow USB debugging?" prompt will appear on the TV so I can accept it.
- If `adb install` hangs on Android 14 it is waiting for an on-screen confirmation; push the APK and run
  `pm install -r` over the shell instead.

### Back up first
- Save the full package list, disabled-package list, getprop output and all Android settings tables
  (`global`, `secure`, `system`) to a backup folder before changing anything.
- Write a one-click restore script (`restore.bat` / `restore.ps1`) that re-enables every package you disable,
  re-enables the stock launcher, restores default home activity, and reverts private DNS.
- Ask me what is plugged into the TV's USB ports, and ask separately whether the TV's network comes
  through a USB Ethernet adapter: some devices cut their power while USB debugging is on, so warn me,
  and remind me to switch debugging off once done.
- When you finish, guide me to close network ADB: switch USB debugging and Wireless debugging off on the TV,
  revoke USB debugging authorizations, and reboot.

### Debloat
- List installed packages and sort them into:
  1. Manufacturer telemetry/analytics (`com.tcl.usercenter`, `com.tcl.useragreement`, `com.google.android.feedback`, etc.)
  2. Manufacturer content and ad services (PatchWall, waterfall overseas ad streams, `channelplus`, partner customizers)
  3. Background services and duplicates (cleaners, memory killers, redundant screen share agents)
  4. Preloaded apps and retail demo mode apps (`esticker`, `hotelmenu`, preloaded bloatware)
  5. Active streaming apps
- Disable unwanted packages using `pm disable-user --user 0 <package>`, never uninstall system packages.
  Run `pm` commands one per shell call (chained commands may silently stop after the first).
- Never disable load-bearing core services: TV hardware tuners (`com.tcl.tv`, `com.tcl.tvinput`),
  remote control and Bluetooth pairing (`com.android.bluetooth`, `com.tcl.autopair`), on-screen keyboards,
  Google Play Store and Play Services, or Android system essentials (`com.android.systemui`, `com.android.settings`).
- Before disabling the stock launcher (`com.google.android.apps.tv.launcherx`), check for setup wizards
  (`com.google.android.tungsten.setupwraith`). Check `dumpsys wifi | grep -o 'cname=[^ ]*'`: a Wi-Fi network
  saved during first setup belongs to setupwraith, and Android deletes that network the moment setupwraith is
  disabled. If it does, ask me to forget the network and re-join it in Settings first.
- Disable in small batches and screenshot between them. After the last batch, reboot once and verify with
  `pm list packages -d` to detect firmware that auto-restores packages on boot.
- Offer AdGuard Private DNS resolver (`dns.adguard-dns.com` via `settings put global private_dns_specifier`
  and `settings put global private_dns_mode hostname`). Explain that it blocks telemetry and web banner ads,
  note that it does not block YouTube in-stream video ads, and document the undo command.

### Native Apple TV 4K Launcher System
Build a clean, high-performance native Android TV launcher (Java, AndroidX, API 26+) with zero memory leaks
(the TV typically has ~1 GB RAM, so avoid heavy WebViews, heavy background polling, or video decoding loops):

1. **Visual Style & Material**:
   - Default deep pitch-black OLED background (`#000000`) with dynamic theme switcher support.
   - Elegant typography using the open-license Outfit font (`Outfit-Light` for headers/clock, `Outfit-Regular` for subtitles).
   - Pinned Top-Left: Dynamic time-aware greeting ("Good Morning / Good Afternoon / Good Evening, Nero and Sanu!"),
     large thin clock (`HH:mm`), and date formatted with thin separator lines.
   - Pinned Top-Right: Frosted glass pill status HUD buttons (`@color/pill_bg` `#24FFFFFF` with 1dp border `#3AFFFFFF`):
     - **Live Weather Pill**: e.g., "28° Clear" with current temperature and condition.
     - **Inputs Pill**: Clickable dropdown modal listing HDMI 1, HDMI 2, HDMI 3 (PS5), AV, and Live TV,
       switching seamlessly via Android TV Input Framework (`content://android.media.tv/passthrough/`).
     - **Controls / Control Center Pill**: Frosted glass slide-out quick-settings overlay providing one-click
       toggles for Wi-Fi settings, Display & Picture settings, Android TV system settings, Screensaver trigger,
       and Theme Wallpaper switching.

2. **Frosted Glass Floating Dock**:
   - Translucent rounded floating dock band holding the 4-6 prioritized primary apps (e.g. Netflix, Prime Video, JioHotstar, YouTube).
   - Generous 28dp spacing and smooth 18dp rounded tile corners (`RoundedCardView`).
   - Dynamic Focused Header: Moving focus across dock apps dynamically crossfades a large clean title (44sp)
     and categorized subtitle tagline (e.g., *"Popular Series • Sci-Fi • 4K HDR"*), paired with a full-screen
     subtle dynamic ambient color bloom sampled from each app's branding.
   - Dynamic headers automatically slide and fade out when navigating downward away from the Dock.

3. **Favorite Series Shelf & Deep Links**:
   - A dedicated horizontal carousel placed directly beneath the Dock band for favorite TV series
     (e.g., *Seinfeld*, *The Big Bang Theory*, *Friends*, *Brooklyn Nine-Nine*, *Modern Family*, *Game of Thrones*).
   - Backdrops must follow the **empty iconic room** aesthetic — high-resolution, authentic empty set photography
     with **zero characters or people** (Jerry's Apartment 5A, Sheldon's Apartment 4A, Central Perk cafe, 99th Precinct bullpen, Dunphy living room, Red Keep throne room).
   - **Universal Hero Backdrop Display**: Highlighting any series card smoothly crossfades its 4K empty room backdrop
     into the upper hero area across **all** themes.
   - **Dock Theme Preservation**: When moving back up to the Dock, non-hero themes seamlessly restore their
     original wallpaper (e.g. *The Wall • Westeros*, *Sonoma*, *Mojave*, or *Pitch Black*), while hero theme
     restores the app's dynamic backdrop.
   - **Optical Parallax Counter-Pan**: As focus moves left/right between favorite series tiles, apply a smooth
     counter-pan (`-20dp` to `+20dp`) to the 4K backdrop alongside atmospheric glow.
   - **Zero-Lag Preloading**: Preload all series drawables into memory (`RGB_565`) during init to ensure 60fps instant transitions.
   - **Direct Playback Deep-Linking**: Clicking a series card launches directly into the show or episode via Leanback
     intents (`com.netflix.ninja` direct playback intent with source extra, Hotstar browsable intent, or fallback leanback launch).

4. **All Apps Grid & tvOS Wobble Reordering**:
   - 4-column balanced grid displaying all installed leanback-enabled TV applications.
   - **Reorder Mode**: Long-press **OK / Select** or press **Menu / Options** on any grid tile to enter reorder mode.
     The selected tile elevates to 1.10x scale with continuous tvOS jiggle/wobble animation, accompanied by a top
     frosted HUD pill explaining D-pad movement. Swapping tiles updates the layout immediately and persists
     the custom app ordering to `SharedPreferences`.

5. **Hardware Remote Key Interception**:
   - Dedicated hardware buttons on TV remotes (Netflix, Prime Video, YouTube, Inputs) must be routed to their
     proper actions.
   - Implement dual-layer handling: foreground `onKeyDown` interception in `MainActivity` and system-wide
     background routing via a lightweight `AccessibilityService` (`RemoteButtonService`).

6. **Deterministic D-Pad Navigation**:
   - Left/Right stops strictly at carousel boundaries.
   - Down from dock moves cleanly to the Favorites shelf; Down from Favorites moves into Row 0 of All Apps.
   - Up from Row 0 of All Apps returns to the exact previously focused Favorites card; Up from Favorites returns to the Dock.
   - Up from Dock enters the top bar pills without falling out of bounds.

### Verify
- After every installation or UI update, inject remote key events over ADB (`adb shell input keyevent ...`),
  capture screenshots (`adb shell screencap -p /sdcard/shot.png && adb pull /sdcard/shot.png`), and inspect the PNG.
- Confirm visual alignments, text baseline contrast, font rendering, and transition smoothness.
- Check `dumpsys window | grep mCurrentFocus` to verify active activity and focus state.
- Ensure the TV boots directly into the new launcher and retains all settings across restarts.

### Deliverables
- Fully working native Android TV launcher source code and assets.
- Standalone build & install script (`build_and_install.ps1` / `.bat`) using command-line SDK tools without Gradle dependencies.
- One-click restore script (`restore.ps1` / `.bat`) that reverts debloating, restores stock launcher, and resets DNS.
- Comprehensive `README.md` documenting architecture, backups, debloated packages, theme customization, and ADB hardening.
