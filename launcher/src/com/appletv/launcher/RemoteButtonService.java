package com.appletv.launcher;

import android.accessibilityservice.AccessibilityService;
import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.provider.Settings;
import android.util.Log;
import android.view.KeyEvent;
import android.view.accessibility.AccessibilityEvent;

public class RemoteButtonService extends AccessibilityService {
    private static final String TAG = "RemoteButtonService";

    // Dedicated keycodes for TCL remote app buttons:
    private static final int KEYCODE_TCL_NETFLIX = 4062;
    private static final int KEYCODE_TCL_YOUTUBE = 4065;
    private static final int KEYCODE_TCL_PRIMEVIDEO = 4099;
    private static final int KEYCODE_TCL_DISNEY = 4141;

    // Dedicated keycodes for TCL remote settings / menu:
    private static final int KEYCODE_TCL_QUICK_MENU = 4020;
    private static final int KEYCODE_TCL_SET = 4077;

    // Dedicated keycodes for TCL remote Home / Channel / Dashboard buttons:
    private static final int KEYCODE_TCL_DASHBOARD = 4137;
    private static final int KEYCODE_TCL_TVPLUS = 4158;
    private static final int KEYCODE_TCL_ALL_APP = 4082;
    private static final int KEYCODE_TCL_GUARD = 4140;
    private static final int KEYCODE_TCL_WATCHLIST = 4138;
    private static final int KEYCODE_TCL_USER_CENTER = 4139;

    private String currentPackage = "";

    @Override
    public void onAccessibilityEvent(AccessibilityEvent event) {
        if (event != null && event.getEventType() == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            CharSequence pkg = event.getPackageName();
            if (pkg != null) {
                currentPackage = pkg.toString();
            }
        }
    }

    @Override
    public void onInterrupt() {
        // No interrupt action required
    }

    @Override
    protected boolean onKeyEvent(KeyEvent event) {
        int keyCode = event.getKeyCode();
        int action = event.getAction();

        Log.i(TAG, "onKeyEvent: action=" + action + ", keyCode=" + keyCode + " (" + KeyEvent.keyCodeToString(keyCode) + ")");

        if (action == KeyEvent.ACTION_DOWN) {
            if (isNetflixKey(keyCode)) {
                launchPackage("com.netflix.ninja");
                return true;
            } else if (isYouTubeKey(keyCode)) {
                launchPackage("com.google.android.youtube.tv");
                return true;
            } else if (isPrimeVideoKey(keyCode)) {
                launchPackage("com.amazon.amazonvideo.livingroom");
                return true;
            } else if (isDisneyKey(keyCode)) {
                launchPackage("in.startv.hotstar");
                return true;
            } else if (isSettingsKey(keyCode)) {
                handleSettingsKey();
                return true;
            } else if (isTclHomeKey(keyCode)) {
                handleTclHomeKey();
                return true;
            }
        } else if (action == KeyEvent.ACTION_UP) {
            if (isNetflixKey(keyCode) || isYouTubeKey(keyCode) || isPrimeVideoKey(keyCode) || isDisneyKey(keyCode) || isSettingsKey(keyCode) || isTclHomeKey(keyCode)) {
                return true;
            }
        }

        return super.onKeyEvent(event);
    }

    private boolean isNetflixKey(int keyCode) {
        return keyCode == KEYCODE_TCL_NETFLIX
            || keyCode == KeyEvent.KEYCODE_BUTTON_3
            || keyCode == KeyEvent.KEYCODE_BUTTON_12
            || keyCode == 289  // KEYCODE_VIDEO_APP_1
            || keyCode == 297  // KEYCODE_FEATURED_APP_1
            || keyCode == 591;
    }

    private boolean isYouTubeKey(int keyCode) {
        return keyCode == KEYCODE_TCL_YOUTUBE
            || keyCode == KeyEvent.KEYCODE_BUTTON_2
            || keyCode == 290  // KEYCODE_VIDEO_APP_2
            || keyCode == 298  // KEYCODE_FEATURED_APP_2
            || keyCode == 593;
    }

    private boolean isPrimeVideoKey(int keyCode) {
        return keyCode == KEYCODE_TCL_PRIMEVIDEO
            || keyCode == KeyEvent.KEYCODE_BUTTON_4
            || keyCode == KeyEvent.KEYCODE_BUTTON_5
            || keyCode == 291  // KEYCODE_VIDEO_APP_3
            || keyCode == 299  // KEYCODE_FEATURED_APP_3
            || keyCode == 752;
    }

    private boolean isDisneyKey(int keyCode) {
        return keyCode == KEYCODE_TCL_DISNEY
            || keyCode == 292  // KEYCODE_VIDEO_APP_4
            || keyCode == 300; // KEYCODE_FEATURED_APP_4
    }

    private boolean isSettingsKey(int keyCode) {
        return keyCode == KEYCODE_TCL_SET
            || keyCode == KEYCODE_TCL_QUICK_MENU
            || keyCode == KeyEvent.KEYCODE_SETTINGS
            || keyCode == 312; // KEYCODE_QUICK_OPTIONS
    }

    private boolean isTclHomeKey(int keyCode) {
        return keyCode == KEYCODE_TCL_DASHBOARD
            || keyCode == KEYCODE_TCL_TVPLUS
            || keyCode == KEYCODE_TCL_ALL_APP
            || keyCode == KEYCODE_TCL_GUARD
            || keyCode == KEYCODE_TCL_WATCHLIST
            || keyCode == KEYCODE_TCL_USER_CENTER
            || keyCode == 284; // KEYCODE_ALL_APPS
    }

    private void handleTclHomeKey() {
        Log.i(TAG, "handleTclHomeKey: cycling wallpaper, currentPackage=" + currentPackage);
        try {
            // Send broadcast to active launcher
            Intent broadcast = new Intent("com.appletv.launcher.CYCLE_WALLPAPER");
            broadcast.setPackage(getPackageName());
            sendBroadcast(broadcast);
        } catch (Exception e) {
            Log.e(TAG, "Error sending CYCLE_WALLPAPER broadcast", e);
        }

        // If launcher is not currently in the foreground, bring it to front
        if (!"com.appletv.launcher".equals(currentPackage) && !currentPackage.isEmpty()) {
            try {
                Intent homeIntent = new Intent(Intent.ACTION_MAIN);
                homeIntent.setComponent(new ComponentName(this, MainActivity.class));
                homeIntent.setAction("com.appletv.launcher.CYCLE_WALLPAPER");
                homeIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED);
                startActivity(homeIntent);
            } catch (Exception e) {
                Log.e(TAG, "Error launching MainActivity for wallpaper cycle", e);
            }
        }
    }

    private void handleSettingsKey() {
        if ("com.tcl.settings".equals(currentPackage) || "com.android.tv.settings".equals(currentPackage)) {
            performGlobalAction(GLOBAL_ACTION_BACK);
            Log.i(TAG, "Settings toggle: dismissed settings via BACK");
        } else {
            launchTvSettings();
        }
    }

    private void launchTvSettings() {
        try {
            Intent intent = new Intent();
            intent.setComponent(new ComponentName("com.tcl.settings", "com.tcl.settings.MainActivity"));
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
            Log.i(TAG, "Launched TV Settings (com.tcl.settings)");
        } catch (Exception e) {
            try {
                Intent fallback = new Intent(Settings.ACTION_SETTINGS);
                fallback.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(fallback);
                Log.i(TAG, "Launched fallback Settings");
            } catch (Exception ex) {
                Log.e(TAG, "Error launching settings", ex);
            }
        }
    }

    private void launchPackage(String packageName) {
        try {
            PackageManager pm = getPackageManager();
            Intent intent = pm.getLeanbackLaunchIntentForPackage(packageName);
            if (intent == null) {
                intent = pm.getLaunchIntentForPackage(packageName);
            }
            if (intent != null) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED);
                startActivity(intent);
                Log.i(TAG, "Launched app: " + packageName);
            } else {
                Log.w(TAG, "App not found or no launch intent: " + packageName);
            }
        } catch (Exception e) {
            Log.e(TAG, "Error launching app: " + packageName, e);
        }
    }
}
