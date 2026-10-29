package com.appletv.launcher;

import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.animation.ValueAnimator;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.media.AudioAttributes;
import android.media.SoundPool;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.provider.Settings;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.DecelerateInterpolator;
import android.view.animation.OvershootInterpolator;
import android.widget.FrameLayout;
import android.widget.GridLayout;
import android.widget.HorizontalScrollView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import java.net.InetAddress;
import java.net.Inet4Address;
import java.net.NetworkInterface;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

public class MainActivity extends Activity {

    // Views
    private static class GlassioIconPair {
        final int unfocusedResId;
        final int focusedResId;
        GlassioIconPair(int unfocusedResId, int focusedResId) {
            this.unfocusedResId = unfocusedResId;
            this.focusedResId = focusedResId;
        }
    }

    private static final Map<String, GlassioIconPair> GLASSIO_ICONS = new HashMap<>();
    static {
        GLASSIO_ICONS.put("com.netflix.ninja", new GlassioIconPair(R.drawable.glassio_netflix_white, R.drawable.glassio_netflix_color));
        GLASSIO_ICONS.put("com.amazon.amazonvideo.livingroom", new GlassioIconPair(R.drawable.glassio_prime_white, R.drawable.glassio_prime_color));
        GLASSIO_ICONS.put("in.startv.hotstar", new GlassioIconPair(R.drawable.glassio_hotstar_white, R.drawable.glassio_hotstar_color));
        GLASSIO_ICONS.put("com.google.android.youtube.tv", new GlassioIconPair(R.drawable.glassio_youtube_white, R.drawable.glassio_youtube_color));
        GLASSIO_ICONS.put("com.apple.atve.androidtv.appletv", new GlassioIconPair(R.drawable.glassio_appletv_white, R.drawable.glassio_appletv_color));
        GLASSIO_ICONS.put("com.apple.atve.tcl.appletv", new GlassioIconPair(R.drawable.glassio_appletv_white, R.drawable.glassio_appletv_color));
        GLASSIO_ICONS.put("com.stremio.one", new GlassioIconPair(R.drawable.glassio_stremio_white, R.drawable.glassio_stremio_color));
        GLASSIO_ICONS.put("com.cricfytv.sports", new GlassioIconPair(R.drawable.glassio_cricfy_white, R.drawable.glassio_cricfy_color));
        GLASSIO_ICONS.put("tv.airtel.xstream.tvapp", new GlassioIconPair(R.drawable.glassio_xstream_white, R.drawable.glassio_xstream_color));
        GLASSIO_ICONS.put("com.sonyliv", new GlassioIconPair(R.drawable.glassio_sonyliv_white, R.drawable.glassio_sonyliv_color));
        GLASSIO_ICONS.put("com.fancode.tv", new GlassioIconPair(R.drawable.glassio_fancode_white, R.drawable.glassio_fancode_color));
        GLASSIO_ICONS.put("com.graymatrix.did", new GlassioIconPair(R.drawable.glassio_zee5_white, R.drawable.glassio_zee5_color));
        GLASSIO_ICONS.put("org.videolan.vlc", new GlassioIconPair(R.drawable.glassio_vlc_white, R.drawable.glassio_vlc_color));
        GLASSIO_ICONS.put("pl.solidexplorer2", new GlassioIconPair(R.drawable.glassio_solidexplorer_white, R.drawable.glassio_solidexplorer_color));
        GLASSIO_ICONS.put("com.android.vending", new GlassioIconPair(R.drawable.glassio_playstore_white, R.drawable.glassio_playstore_color));
        GLASSIO_ICONS.put("com.esaba.downloader", new GlassioIconPair(R.drawable.glassio_downloader_white, R.drawable.glassio_downloader_color));
        GLASSIO_ICONS.put("com.yablio.sendfilestotv", new GlassioIconPair(R.drawable.glassio_sftv_white, R.drawable.glassio_sftv_color));
        GLASSIO_ICONS.put("com.tcl.tv", new GlassioIconPair(R.drawable.glassio_tcltv_white, R.drawable.glassio_tcltv_color));
        GLASSIO_ICONS.put("com.neilturner.aerialviews", new GlassioIconPair(R.drawable.glassio_aerialviews_white, R.drawable.glassio_aerialviews_color));
        GLASSIO_ICONS.put("com.codingbuffalo.aerialdream", new GlassioIconPair(R.drawable.glassio_aerialviews_white, R.drawable.glassio_aerialviews_color));
    }

    private FrameLayout rootView;
    private View ambientGlowView;
    private View ambientGlowViewBack;
    private TextView tvFocusedTitle;
    private ScrollView mainScrollView;
    private LinearLayout dockRow;
    private FrameLayout dockContainer;
    private HorizontalScrollView dockScrollView;
    private TextView ccWallSeinfeld, ccWallFriends, ccWallBigBang, ccWallB99, ccWallModernFamily;
    private FrameLayout launchZoomContainer;
    private View vLaunchGlow;
    private ImageView ivLaunchZoomIcon;
    private HorizontalScrollView favoritesScrollView;
    private LinearLayout favoritesRow;
    private GridLayout appsGrid;
    private View glassHighlight;
    private View topBar;
    private TextView tvFavoritesHeader;
    private final Handler keyHandler = new Handler(Looper.getMainLooper());
    private TextView tvGreeting;
    private TextView tvClock;
    private TextView tvAmPm;
    private TextView tvDate;
    private TextView btnWeather;
    private TextView btnInputs;
    private TextView btnControlCenter;
    private View controlCenterScrim;
    private LinearLayout controlCenterPanel;
    private TextView ccWallMojave, ccWallSonoma, ccWallGot, ccWallHero;
    private TextView ccBtnScreensaver, ccBtnSleepTimer, ccBtnSleepNow;
    private TextView ccToggleSound, ccToggleGlow;
    private TextView ccTvNetworkInfo, ccBtnWifi, ccBtnSettings;
    private boolean isControlCenterOpen = false;
    private View lastViewBeforeControlCenter = null;
    private int sleepTimerMinutes = 0;
    private final Handler sleepTimerHandler = new Handler(Looper.getMainLooper());
    private Runnable sleepTimerRunnable;
    private boolean isSoundEffectsEnabled = true;
    private boolean isAmbientGlowEnabled = true;
    private LinearLayout inputsDropdown;
    private TextView optHdmi1, optHdmi2, optHdmi3, optAv, optLiveTv;
    private LinearLayout hudReorder;
    private TextView tvReorderPrompt;
    private LinearLayout hudWallpaper;
    private TextView tvWallpaperPrompt;
    private final Handler hudHandler = new Handler(Looper.getMainLooper());
    private long lastCycleTime = 0;

    // Screensaver Idle Timer (3 minutes on Home screen)
    private static final long SCREENSAVER_IDLE_TIMEOUT_MS = 180000;
    private final Handler idleHandler = new Handler(Looper.getMainLooper());
    private final Runnable screensaverRunnable = new Runnable() {
        @Override
        public void run() {
            startAerialScreensaver();
        }
    };

    private void resetIdleTimer() {
        if (idleHandler != null) {
            idleHandler.removeCallbacks(screensaverRunnable);
            idleHandler.postDelayed(screensaverRunnable, SCREENSAVER_IDLE_TIMEOUT_MS);
        }
    }

    private ImageView ivWallpaper;
    private View wallpaperVignette;
    private ImageView ivHeroBackdrop;
    private ImageView ivHeroBackdropBack;
    private int currentHeroRes = 0;

    // 3D Optical Parallax Layer Transforms (GPU RenderThread - 0 MB extra RAM)
    private static final float PARALLAX_SCALE = 1.045f;
    private float currentParallaxX = 0f;

    // Pre-decoded GPU-ready Hero Backdrops Cache (RGB_565 saves 50% RAM & eliminates UI thread decode latency)
    private static final Map<Integer, Bitmap> HERO_BITMAP_CACHE = new HashMap<>();

    private static final Map<String, Integer> HERO_DRAWABLES = new HashMap<>();
    static {
        HERO_DRAWABLES.put("com.netflix.ninja", R.drawable.hero_netflix);
        HERO_DRAWABLES.put("com.amazon.amazonvideo.livingroom", R.drawable.hero_prime);
        HERO_DRAWABLES.put("in.startv.hotstar", R.drawable.hero_hotstar);
        HERO_DRAWABLES.put("com.google.android.youtube.tv", R.drawable.hero_youtube);
    }

    // Focused App Header & Tagline Description
    private LinearLayout heroMetadataLayout;
    private TextView tvHeroTagline;

    private static final Map<String, String> APP_TAGLINES = new HashMap<>();
    static {
        APP_TAGLINES.put("com.netflix.ninja", "Seinfeld \u2022 9 Seasons \u2022 The Show About Nothing \u2022 4K HDR");
        APP_TAGLINES.put("com.amazon.amazonvideo.livingroom", "The Big Bang Theory \u2022 12 Seasons \u2022 Included with Prime");
        APP_TAGLINES.put("in.startv.hotstar", "Live Cricket \u2022 Blockbuster Movies \u2022 Hotstar Specials");
        APP_TAGLINES.put("com.google.android.youtube.tv", "Stream Endless 4K HDR Video \u2022 Music & Creators");
        APP_TAGLINES.put("com.apple.atve.androidtv.appletv", "Apple Originals \u2022 Award-Winning 4K HDR Films");
        APP_TAGLINES.put("com.apple.atve.tcl.appletv", "Apple Originals \u2022 Award-Winning 4K HDR Films");
        APP_TAGLINES.put("tv.airtel.xstream.tvapp", "Live TV Channels \u2022 Web Series & Movies");
        APP_TAGLINES.put("com.graymatrix.did", "Blockbusters \u2022 TV Shows & Exclusive Originals");
        APP_TAGLINES.put("com.cricfytv.sports", "Live Sports \u2022 Cricket & Football Highlights");
        APP_TAGLINES.put("com.stremio.one", "Stream Movies, TV Series & Addons in 4K");
        APP_TAGLINES.put("com.android.vending", "Discover Android TV Apps & Games");
        APP_TAGLINES.put("com.neilturner.aerialviews", "Cinematic 4K Aerial Video Screensaver");
        APP_TAGLINES.put("com.codingbuffalo.aerialdream", "Apple TV Aerial Screensavers for Android");
        APP_TAGLINES.put("com.mxtech.videoplayer.television", "Hardware Accelerated 4K Video Player");
        APP_TAGLINES.put("com.instantbits.cast.receiver", "Cast Videos & Streams from Phone to TV");
        APP_TAGLINES.put("com.esaba.downloader", "Browse & Download Files to TV Storage");
        APP_TAGLINES.put("com.yablio.sendfilestotv", "Fast File Transfer over Local Wi-Fi");
        APP_TAGLINES.put("com.tcl.gallery", "View Photos & Home Videos in 4K");
        APP_TAGLINES.put("com.tcl.ui_mediaCenter", "Local USB & Network Media Player");
        APP_TAGLINES.put("com.tcl.tv", "Live Channels, HDMI & AV Inputs");
        APP_TAGLINES.put("com.tcl.t_solo", "Listen Alone \u2022 Screen Off Audio Mode");
    }

    // Wallpaper & Customization
    private static final String KEY_WALLPAPER = "active_wallpaper";
    private BroadcastReceiver wallpaperReceiver;

    // Reorder Mode State
    private boolean isReorderMode = false;
    private int reorderActiveIndex = -1;
    private ObjectAnimator currentWobbleAnimator = null;
    private View currentWobbleTile = null;
    private static final String PREF_NAME = "appletv_launcher_prefs";
    private static final String KEY_GRID_ORDER = "grid_app_order";

    // Authentic Apple TV Sound System
    private SoundPool soundPool;
    private int soundNavigateId = 0;
    private int soundClickId = 0;
    private int soundBackId = 0;
    private boolean isUserNavigating = false;

    private void initSoundEffects() {
        try {
            AudioAttributes audioAttributes = new AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ASSISTANCE_SONIFICATION)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build();
            soundPool = new SoundPool.Builder()
                .setMaxStreams(4)
                .setAudioAttributes(audioAttributes)
                .build();

            soundNavigateId = soundPool.load(this, R.raw.sound_navigate, 1);
            soundClickId = soundPool.load(this, R.raw.sound_click, 1);
            soundBackId = soundPool.load(this, R.raw.sound_back, 1);
        } catch (Exception e) {
            android.util.Log.e("AppleTV", "Failed to init SoundPool", e);
        }
    }

    private void playSoundNavigate() {
        if (!isSoundEffectsEnabled) return;
        if (soundPool != null && soundNavigateId != 0) {
            soundPool.play(soundNavigateId, 0.45f, 0.45f, 1, 0, 1.0f);
        }
    }

    private void playSoundClick() {
        if (!isSoundEffectsEnabled) return;
        if (soundPool != null && soundClickId != 0) {
            soundPool.play(soundClickId, 0.55f, 0.55f, 1, 0, 1.0f);
        }
    }

    private void playSoundBack() {
        if (!isSoundEffectsEnabled) return;
        if (soundPool != null && soundBackId != 0) {
            soundPool.play(soundBackId, 0.50f, 0.50f, 1, 0, 1.0f);
        }
    }

    // State
    private View lastFocusedDockView = null;
    private View lastFocusedView = null;
    private long lastNavTime = 0;
    private final Handler timeHandler = new Handler(Looper.getMainLooper());
    private final Runnable timeRunnable = new Runnable() {
        @Override
        public void run() {
            updateClockAndGreeting();
            timeHandler.postDelayed(this, 15000);
        }
    };

    // Personalized username for top-left greeting
    private static final String USER_NAME = "Nero and Sanu";

    // The 4 apps picked by user in exact order:
    private static final String[] DOCK_PACKAGES = {
        "com.netflix.ninja",                     // 1. Netflix
        "com.amazon.amazonvideo.livingroom",     // 2. Prime Video
        "in.startv.hotstar",                     // 3. JioHotstar
        "com.google.android.youtube.tv",          // 4. YouTube
        "com.apple.atve.androidtv.appletv",
        "com.stremio.one",
        "com.cricfytv.sports",
        "tv.airtel.xstream.tvapp",
        "com.sonyliv",
        "com.fancode.tv",
        "com.graymatrix.did",
        "org.videolan.vlc",
        "pl.solidexplorer2"
    };

    // Brand accent colors for ambient glow
    private static final Map<String, Integer> BRAND_COLORS = new HashMap<>();
    static {
        BRAND_COLORS.put("com.netflix.ninja", Color.parseColor("#E50914"));
        BRAND_COLORS.put("com.amazon.amazonvideo.livingroom", Color.parseColor("#00A8E1"));
        BRAND_COLORS.put("in.startv.hotstar", Color.parseColor("#1F80E0"));
        BRAND_COLORS.put("com.google.android.youtube.tv", Color.parseColor("#FF0000"));
        BRAND_COLORS.put("com.apple.atve.androidtv.appletv", Color.parseColor("#99AAB5"));
        BRAND_COLORS.put("com.apple.atve.tcl.appletv", Color.parseColor("#99AAB5"));
        BRAND_COLORS.put("com.android.vending", Color.parseColor("#01875F"));
        BRAND_COLORS.put("com.tcl.tv", Color.parseColor("#FF375F"));
        BRAND_COLORS.put("com.codingbuffalo.aerialdream", Color.parseColor("#007AFF"));
        BRAND_COLORS.put("com.neilturner.aerialviews", Color.parseColor("#5E5CE6"));
        BRAND_COLORS.put("com.adguard.android", Color.parseColor("#68BC71"));
        BRAND_COLORS.put("com.stremio.one", Color.parseColor("#7C5295"));
        BRAND_COLORS.put("com.cricfytv.sports", Color.parseColor("#FF6D00"));
        BRAND_COLORS.put("tv.airtel.xstream.tvapp", Color.parseColor("#ED1C24"));
        BRAND_COLORS.put("com.instantbits.cast.receiver", Color.parseColor("#FF9500"));
        BRAND_COLORS.put("com.mxtech.videoplayer.television", Color.parseColor("#2196F3"));
        BRAND_COLORS.put("com.graymatrix.did", Color.parseColor("#8A2BE2"));
        BRAND_COLORS.put("com.yablio.sendfilestotv", Color.parseColor("#0A84FF"));
        BRAND_COLORS.put("com.esaba.downloader", Color.parseColor("#FF9F0A"));
        BRAND_COLORS.put("com.tcl.t_solo", Color.parseColor("#BF5AF2"));
        BRAND_COLORS.put("com.tcl.gallery", Color.parseColor("#30D158"));
        BRAND_COLORS.put("com.tcl.ui_mediaCenter", Color.parseColor("#0A84FF"));
    }

    private static class AppItem {
        String packageName;
        String activityName;
        String label;
        Drawable banner;
        Drawable icon;
        int accentColor;
    }

    private static class SeriesItem {
        final String title;
        final String subtitle;
        final String badge;
        final String packageName;
        final String deepLinkUri;
        final int posterResId;
        final int accentColor;

        SeriesItem(String title, String subtitle, String badge, String packageName, String deepLinkUri, int posterResId, int accentColor) {
            this.title = title;
            this.subtitle = subtitle;
            this.badge = badge;
            this.packageName = packageName;
            this.deepLinkUri = deepLinkUri;
            this.posterResId = posterResId;
            this.accentColor = accentColor;
        }
    }

    private final List<AppItem> dockApps = new ArrayList<>();
    private final List<AppItem> gridApps = new ArrayList<>();
    private final List<SeriesItem> favoriteSeries = new ArrayList<>();
    private final List<View> dockTileViews = new ArrayList<>();
    private final List<View> favoritesTileViews = new ArrayList<>();
    private final List<View> gridTileViews = new ArrayList<>();
    private View lastFocusedFavoritesView = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().getDecorView().setLayoutDirection(View.LAYOUT_DIRECTION_LTR);
        setContentView(R.layout.activity_main);

        initSoundEffects();
        preloadHeroDrawables();
        bindViews();
        setupTopBar();
        setupInputsDropdown();
        setupControlCenter();
        loadApplications();
        updateWifiStatus();

        String savedWallpaper = getSharedPreferences(PREF_NAME, MODE_PRIVATE).getString(KEY_WALLPAPER, "got");
        applyWallpaper(savedWallpaper);

        wallpaperReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                if (intent == null) return;
                if ("com.appletv.launcher.CYCLE_WALLPAPER".equals(intent.getAction())) {
                    cycleWallpaper();
                } else if ("com.appletv.launcher.START_SCREENSAVER".equals(intent.getAction())) {
                    startAerialScreensaver();
                } else if ("com.appletv.launcher.OPEN_CONTROL_CENTER".equals(intent.getAction())) {
                    openControlCenter();
                } else if ("com.appletv.launcher.CLOSE_CONTROL_CENTER".equals(intent.getAction())) {
                    closeControlCenter();
                } else {
                    String theme = intent.getStringExtra("wallpaper");
                    if (theme != null) {
                        setWallpaperTheme(theme);
                        String name = "Mojave Sand Dunes";
                        if ("sonoma".equalsIgnoreCase(theme)) name = "Sonoma Horizon";
                        else if ("got".equalsIgnoreCase(theme)) name = "The Wall \u2022 Westeros";
                        else if ("hero".equalsIgnoreCase(theme)) name = "Dynamic Hero Backdrops";
                        else if ("black".equalsIgnoreCase(theme)) name = "Pitch Black OLED";
                        showWallpaperHud(name);
                    }
                }
            }
        };
        IntentFilter wallpaperFilter = new IntentFilter();
        wallpaperFilter.addAction("com.appletv.launcher.SET_WALLPAPER");
        wallpaperFilter.addAction("com.appletv.launcher.CYCLE_WALLPAPER");
        wallpaperFilter.addAction("com.appletv.launcher.START_SCREENSAVER");
        wallpaperFilter.addAction("com.appletv.launcher.OPEN_CONTROL_CENTER");
        wallpaperFilter.addAction("com.appletv.launcher.CLOSE_CONTROL_CENTER");
        registerReceiver(wallpaperReceiver, wallpaperFilter);

        if (!dockApps.isEmpty()) {
            setAmbientGlow(dockApps.get(0).accentColor);
        }

        // Initial focus on the first dock tile (Netflix)
        rootView.post(new Runnable() {
            @Override
            public void run() {
                if (!dockTileViews.isEmpty()) {
                    dockTileViews.get(0).requestFocus();
                }
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        updateClockAndGreeting();
        updateWifiStatus();
        refreshWeather(false);
        timeHandler.post(timeRunnable);
        ensureAccessibilityService();
        resetIdleTimer();
    }

    private void ensureAccessibilityService() {
        try {
            String enabledServices = Settings.Secure.getString(getContentResolver(), Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES);
            String myService = getPackageName() + "/" + RemoteButtonService.class.getName();
            if (enabledServices == null || !enabledServices.contains(myService)) {
                String newServices = (enabledServices == null || enabledServices.isEmpty()) ? myService : enabledServices + ":" + myService;
                Settings.Secure.putString(getContentResolver(), Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES, newServices);
                Settings.Secure.putInt(getContentResolver(), Settings.Secure.ACCESSIBILITY_ENABLED, 1);
            }
        } catch (Exception ignored) {}
    }

    @Override
    protected void onPause() {
        super.onPause();
        timeHandler.removeCallbacks(timeRunnable);
        if (idleHandler != null) {
            idleHandler.removeCallbacks(screensaverRunnable);
        }
        if (isReorderMode) {
            exitReorderMode();
        }
        if (isControlCenterOpen) {
            closeControlCenter();
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        if (intent != null) {
            if ("com.appletv.launcher.CYCLE_WALLPAPER".equals(intent.getAction())) {
                cycleWallpaper();
            } else if ("com.appletv.launcher.START_SCREENSAVER".equals(intent.getAction())) {
                startAerialScreensaver();
            }
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        for (Bitmap bmp : HERO_BITMAP_CACHE.values()) {
            if (bmp != null && !bmp.isRecycled()) {
                bmp.recycle();
            }
        }
        HERO_BITMAP_CACHE.clear();
        if (soundPool != null) {
            try {
                soundPool.release();
            } catch (Exception ignored) {}
            soundPool = null;
        }
        if (wallpaperReceiver != null) {
            try {
                unregisterReceiver(wallpaperReceiver);
            } catch (Exception ignored) {}
        }
        if (hudHandler != null) {
            hudHandler.removeCallbacksAndMessages(null);
        }
        if (idleHandler != null) {
            idleHandler.removeCallbacksAndMessages(null);
        }
        if (sleepTimerHandler != null) {
            sleepTimerHandler.removeCallbacksAndMessages(null);
        }
    }

    private boolean isHeroTheme() {
        String current = getSharedPreferences(PREF_NAME, MODE_PRIVATE).getString(KEY_WALLPAPER, "got");
        return "hero".equalsIgnoreCase(current);
    }

    private void applyWallpaper(String theme) {
        rootView.setBackgroundColor(Color.parseColor("#050505"));
        if ("black".equalsIgnoreCase(theme)) {
            ivWallpaper.setImageDrawable(null);
            ivWallpaper.setVisibility(View.GONE);
            wallpaperVignette.setVisibility(View.GONE);
            hideHeroViews();
        } else if ("hero".equalsIgnoreCase(theme)) {
            ivWallpaper.setImageDrawable(null);
            ivWallpaper.setVisibility(View.GONE);
            wallpaperVignette.setVisibility(View.VISIBLE);
            showHeroViews();
            updateHeroForActiveFocus();
        } else if ("got".equalsIgnoreCase(theme)) {
            hideHeroViews();
            ivWallpaper.setVisibility(View.VISIBLE);
            ivWallpaper.setImageResource(R.drawable.wallpaper_got);
            wallpaperVignette.setVisibility(View.VISIBLE);
        } else if ("seinfeld".equalsIgnoreCase(theme)) {
            hideHeroViews();
            ivWallpaper.setVisibility(View.VISIBLE);
            ivWallpaper.setImageResource(R.drawable.hero_seinfeld);
            wallpaperVignette.setVisibility(View.VISIBLE);
        } else if ("friends".equalsIgnoreCase(theme)) {
            hideHeroViews();
            ivWallpaper.setVisibility(View.VISIBLE);
            ivWallpaper.setImageResource(R.drawable.hero_friends);
            wallpaperVignette.setVisibility(View.VISIBLE);
        } else if ("bigbang".equalsIgnoreCase(theme)) {
            hideHeroViews();
            ivWallpaper.setVisibility(View.VISIBLE);
            ivWallpaper.setImageResource(R.drawable.hero_bigbang);
            wallpaperVignette.setVisibility(View.VISIBLE);
        } else if ("b99".equalsIgnoreCase(theme)) {
            hideHeroViews();
            ivWallpaper.setVisibility(View.VISIBLE);
            ivWallpaper.setImageResource(R.drawable.hero_b99);
            wallpaperVignette.setVisibility(View.VISIBLE);
        } else if ("modernfamily".equalsIgnoreCase(theme)) {
            hideHeroViews();
            ivWallpaper.setVisibility(View.VISIBLE);
            ivWallpaper.setImageResource(R.drawable.hero_modernfamily);
            wallpaperVignette.setVisibility(View.VISIBLE);
        } else if ("sonoma".equalsIgnoreCase(theme)) {
            hideHeroViews();
            ivWallpaper.setVisibility(View.VISIBLE);
            ivWallpaper.setImageResource(R.drawable.wallpaper_sonoma);
            wallpaperVignette.setVisibility(View.VISIBLE);
        } else {
            // default mojave
            hideHeroViews();
            ivWallpaper.setVisibility(View.VISIBLE);
            ivWallpaper.setImageResource(R.drawable.wallpaper_mojave);
            wallpaperVignette.setVisibility(View.VISIBLE);
        }
    }

    private void hideHeroViews() {
        if (ivHeroBackdrop != null) {
            ivHeroBackdrop.animate().cancel();
            ivHeroBackdrop.setVisibility(View.GONE);
            ivHeroBackdrop.setImageDrawable(null);
            ivHeroBackdrop.setAlpha(0f);
        }
        if (ivHeroBackdropBack != null) {
            ivHeroBackdropBack.animate().cancel();
            ivHeroBackdropBack.setVisibility(View.GONE);
            ivHeroBackdropBack.setImageDrawable(null);
            ivHeroBackdropBack.setAlpha(0f);
        }
        currentHeroRes = 0;
    }

    private void showHeroViews() {
        if (ivHeroBackdrop != null) {
            ivHeroBackdrop.setVisibility(View.VISIBLE);
        }
        if (ivHeroBackdropBack != null) {
            ivHeroBackdropBack.setVisibility(View.VISIBLE);
        }
    }

    private void preloadHeroDrawables() {
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    android.graphics.BitmapFactory.Options opts = new android.graphics.BitmapFactory.Options();
                    opts.inPreferredConfig = Bitmap.Config.RGB_565;
                    opts.inDither = true;

                    int[] allBackdrops = new int[] {
                        R.drawable.hero_netflix,
                        R.drawable.hero_prime,
                        R.drawable.hero_hotstar,
                        R.drawable.hero_youtube,
                        R.drawable.series_seinfeld,
                        R.drawable.series_bigbang,
                        R.drawable.series_friends,
                        R.drawable.series_b99,
                        R.drawable.series_modernfamily,
                        R.drawable.series_got
                    };

                    for (final int resId : allBackdrops) {
                        if (!HERO_BITMAP_CACHE.containsKey(resId)) {
                            final Bitmap bmp = android.graphics.BitmapFactory.decodeResource(getResources(), resId, opts);
                            if (bmp != null) {
                                HERO_BITMAP_CACHE.put(resId, bmp);
                                runOnUiThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        if (currentHeroRes == resId && ivHeroBackdrop != null) {
                                            ivHeroBackdrop.setImageBitmap(bmp);
                                        }
                                    }
                                });
                            }
                        }
                    }
                } catch (Throwable t) {
                    android.util.Log.e("AppleTV", "Failed to preload hero drawables", t);
                }
            }
        }, "HeroPreloaderThread").start();
    }

    private void updateHeroForActiveFocus() {
        if (ivHeroBackdrop == null) return;
        AppItem activeApp = null;
        if (lastFocusedDockView != null) {
            int idx = dockTileViews.indexOf(lastFocusedDockView);
            if (idx >= 0 && idx < dockApps.size()) {
                activeApp = dockApps.get(idx);
            }
        }
        if (activeApp == null && !dockApps.isEmpty()) {
            activeApp = dockApps.get(0);
        }

        int targetRes = R.drawable.hero_netflix;
        if (activeApp != null) {
            Integer res = HERO_DRAWABLES.get(activeApp.packageName);
            if (res != null) targetRes = res;
        }

        boolean isGridFocused = (lastFocusedView != null && gridTileViews.contains(lastFocusedView));
        float targetAlpha = isGridFocused ? 0.18f : 1.0f;

        Bitmap preloaded = HERO_BITMAP_CACHE.get(targetRes);
        if (preloaded != null && !preloaded.isRecycled()) {
            ivHeroBackdrop.setImageBitmap(preloaded);
        } else {
            try {
                android.graphics.BitmapFactory.Options opts = new android.graphics.BitmapFactory.Options();
                opts.inPreferredConfig = Bitmap.Config.RGB_565;
                opts.inDither = true;
                Bitmap bmp = android.graphics.BitmapFactory.decodeResource(getResources(), targetRes, opts);
                if (bmp != null) {
                    HERO_BITMAP_CACHE.put(targetRes, bmp);
                    ivHeroBackdrop.setImageBitmap(bmp);
                } else {
                    ivHeroBackdrop.setImageResource(targetRes);
                }
            } catch (Throwable t) {
                ivHeroBackdrop.setImageResource(targetRes);
            }
        }
        ivHeroBackdrop.setAlpha(targetAlpha);
        ivHeroBackdrop.setScaleX(PARALLAX_SCALE);
        ivHeroBackdrop.setScaleY(PARALLAX_SCALE);
        ivHeroBackdrop.setTranslationX(currentParallaxX);
        currentHeroRes = targetRes;
    }

    private void transitionHeroBackdrop(int targetRes) {
        if (ivHeroBackdrop == null || ivHeroBackdropBack == null) return;

        ivHeroBackdrop.animate().cancel();
        ivHeroBackdropBack.animate().cancel();

        // 1. Capture outgoing layer: either currently visible hero backdrop or wallpaper
        Drawable currentDrawable = null;
        if (ivHeroBackdrop.getVisibility() == View.VISIBLE && ivHeroBackdrop.getAlpha() > 0.05f) {
            currentDrawable = ivHeroBackdrop.getDrawable();
        } else if (ivWallpaper != null && ivWallpaper.getVisibility() == View.VISIBLE && ivWallpaper.getAlpha() > 0.05f) {
            currentDrawable = ivWallpaper.getDrawable();
        }

        float startTx = (ivHeroBackdrop.getVisibility() == View.VISIBLE)
            ? ivHeroBackdrop.getTranslationX()
            : (ivWallpaper != null ? ivWallpaper.getTranslationX() : 0f);

        if (currentDrawable != null) {
            ivHeroBackdropBack.setImageDrawable(currentDrawable);
            ivHeroBackdropBack.setAlpha(1.0f);
            ivHeroBackdropBack.setVisibility(View.VISIBLE);
            ivHeroBackdropBack.setScaleX(PARALLAX_SCALE);
            ivHeroBackdropBack.setScaleY(PARALLAX_SCALE);
            ivHeroBackdropBack.setTranslationX(startTx);
            ivHeroBackdropBack.animate()
                .alpha(0.0f)
                .translationX(currentParallaxX)
                .setDuration(240)
                .setInterpolator(new DecelerateInterpolator())
                .withLayer()
                .withEndAction(new Runnable() {
                    @Override
                    public void run() {
                        if (ivHeroBackdropBack != null) {
                            ivHeroBackdropBack.setImageDrawable(null);
                            ivHeroBackdropBack.setVisibility(View.GONE);
                        }
                    }
                })
                .start();
        } else {
            ivHeroBackdropBack.setImageDrawable(null);
            ivHeroBackdropBack.setVisibility(View.GONE);
        }

        if (wallpaperVignette != null) {
            wallpaperVignette.setVisibility(View.VISIBLE);
        }

        if (ivWallpaper != null && ivWallpaper.getVisibility() == View.VISIBLE) {
            ivWallpaper.animate().cancel();
            ivWallpaper.animate().alpha(0.0f).setDuration(240).withEndAction(new Runnable() {
                @Override
                public void run() {
                    if (ivWallpaper != null && currentHeroRes != 0) {
                        ivWallpaper.setVisibility(View.GONE);
                    }
                }
            }).start();
        }

        // 2. Incoming layer
        Bitmap preloaded = HERO_BITMAP_CACHE.get(targetRes);
        if (preloaded != null && !preloaded.isRecycled()) {
            ivHeroBackdrop.setImageBitmap(preloaded);
        } else {
            try {
                android.graphics.BitmapFactory.Options opts = new android.graphics.BitmapFactory.Options();
                opts.inPreferredConfig = Bitmap.Config.RGB_565;
                opts.inDither = true;
                Bitmap bmp = android.graphics.BitmapFactory.decodeResource(getResources(), targetRes, opts);
                if (bmp != null) {
                    HERO_BITMAP_CACHE.put(targetRes, bmp);
                    ivHeroBackdrop.setImageBitmap(bmp);
                } else {
                    ivHeroBackdrop.setImageResource(targetRes);
                }
            } catch (Throwable t) {
                ivHeroBackdrop.setImageResource(targetRes);
            }
        }

        ivHeroBackdrop.setVisibility(View.VISIBLE);
        ivHeroBackdrop.setScaleX(PARALLAX_SCALE);
        ivHeroBackdrop.setScaleY(PARALLAX_SCALE);
        ivHeroBackdrop.setAlpha(0.0f);
        ivHeroBackdrop.setTranslationX(startTx);

        ivHeroBackdrop.animate()
            .alpha(1.0f)
            .translationX(currentParallaxX)
            .setDuration(240)
            .setInterpolator(new DecelerateInterpolator())
            .withLayer()
            .start();

        currentHeroRes = targetRes;
    }

    private void restoreOriginalWallpaperForDock() {
        if (isHeroTheme()) return; // Hero theme manages its own dock backdrops

        final String theme = getSharedPreferences(PREF_NAME, MODE_PRIVATE).getString(KEY_WALLPAPER, "got");

        if (currentHeroRes != 0 || (ivHeroBackdrop != null && ivHeroBackdrop.getVisibility() == View.VISIBLE && ivHeroBackdrop.getAlpha() > 0.05f)) {
            currentHeroRes = 0;

            Drawable heroDrawable = (ivHeroBackdrop != null) ? ivHeroBackdrop.getDrawable() : null;
            float heroTx = (ivHeroBackdrop != null) ? ivHeroBackdrop.getTranslationX() : currentParallaxX;

            if (heroDrawable != null && ivHeroBackdropBack != null) {
                ivHeroBackdropBack.animate().cancel();
                ivHeroBackdropBack.setImageDrawable(heroDrawable);
                ivHeroBackdropBack.setAlpha(ivHeroBackdrop.getAlpha() > 0f ? ivHeroBackdrop.getAlpha() : 1.0f);
                ivHeroBackdropBack.setVisibility(View.VISIBLE);
                ivHeroBackdropBack.setScaleX(PARALLAX_SCALE);
                ivHeroBackdropBack.setScaleY(PARALLAX_SCALE);
                ivHeroBackdropBack.setTranslationX(heroTx);
                ivHeroBackdropBack.animate()
                    .alpha(0.0f)
                    .translationX(currentParallaxX)
                    .setDuration(240)
                    .setInterpolator(new DecelerateInterpolator())
                    .withLayer()
                    .withEndAction(new Runnable() {
                        @Override
                        public void run() {
                            if (ivHeroBackdropBack != null) {
                                ivHeroBackdropBack.setImageDrawable(null);
                                ivHeroBackdropBack.setVisibility(View.GONE);
                            }
                        }
                    })
                    .start();
            }

            if (ivHeroBackdrop != null) {
                ivHeroBackdrop.animate().cancel();
                ivHeroBackdrop.setImageDrawable(null);
                ivHeroBackdrop.setVisibility(View.GONE);
                ivHeroBackdrop.setAlpha(0.0f);
            }

            if ("black".equalsIgnoreCase(theme)) {
                if (wallpaperVignette != null) wallpaperVignette.setVisibility(View.GONE);
                if (ivWallpaper != null) {
                    ivWallpaper.animate().cancel();
                    ivWallpaper.setImageDrawable(null);
                    ivWallpaper.setVisibility(View.GONE);
                }
            } else if (ivWallpaper != null) {
                int wpRes = R.drawable.wallpaper_mojave;
                if ("got".equalsIgnoreCase(theme)) wpRes = R.drawable.wallpaper_got;
                else if ("sonoma".equalsIgnoreCase(theme)) wpRes = R.drawable.wallpaper_sonoma;

                if (wallpaperVignette != null) wallpaperVignette.setVisibility(View.VISIBLE);
                ivWallpaper.animate().cancel();
                ivWallpaper.setImageResource(wpRes);
                ivWallpaper.setVisibility(View.VISIBLE);
                ivWallpaper.setScaleX(PARALLAX_SCALE);
                ivWallpaper.setScaleY(PARALLAX_SCALE);
                ivWallpaper.setAlpha(0.0f);
                ivWallpaper.setTranslationX(heroTx * 0.7f);
                ivWallpaper.animate()
                    .alpha(1.0f)
                    .translationX(currentParallaxX * 0.7f)
                    .setDuration(240)
                    .setInterpolator(new DecelerateInterpolator())
                    .withLayer()
                    .start();
            }
        } else {
            if (ivWallpaper != null && ivWallpaper.getVisibility() == View.VISIBLE) {
                ivWallpaper.animate()
                    .translationX(currentParallaxX * 0.7f)
                    .setDuration(260)
                    .setInterpolator(new DecelerateInterpolator())
                    .withLayer()
                    .start();
            }
        }
    }

    private void setWallpaperTheme(final String theme) {
        boolean wasHero = isHeroTheme();
        getSharedPreferences(PREF_NAME, MODE_PRIVATE)
            .edit()
            .putString(KEY_WALLPAPER, theme)
            .apply();

        View fadingOutView = wasHero ? ivHeroBackdrop : ivWallpaper;
        if (fadingOutView == null || fadingOutView.getVisibility() != View.VISIBLE) {
            fadingOutView = ivWallpaper;
        }

        fadingOutView.animate().cancel();
        fadingOutView.animate().alpha(0f).setDuration(180).withEndAction(new Runnable() {
            @Override
            public void run() {
                applyWallpaper(theme);
                View fadingInView = "hero".equalsIgnoreCase(theme) ? ivHeroBackdrop : ivWallpaper;
                if (fadingInView != null && fadingInView.getVisibility() == View.VISIBLE) {
                    fadingInView.setAlpha(0f);
                    fadingInView.animate().alpha(1f).setDuration(240).start();
                }
            }
        }).start();
    }

    private synchronized void cycleWallpaper() {
        long now = SystemClock.uptimeMillis();
        if (now - lastCycleTime < 350) {
            return; // debounce rapid triggers
        }
        lastCycleTime = now;

        String current = getSharedPreferences(PREF_NAME, MODE_PRIVATE).getString(KEY_WALLPAPER, "got");
        String next;
        String name;

        if ("mojave".equalsIgnoreCase(current)) {
            next = "sonoma";
            name = "Sonoma Horizon";
        } else if ("sonoma".equalsIgnoreCase(current)) {
            next = "got";
            name = "The Wall \u2022 Westeros";
        } else if ("got".equalsIgnoreCase(current)) {
            next = "hero";
            name = "Dynamic Hero Backdrops";
        } else if ("hero".equalsIgnoreCase(current)) {
            next = "black";
            name = "Pitch Black OLED";
        } else {
            next = "mojave";
            name = "Mojave Sand Dunes";
        }

        setWallpaperTheme(next);
        showWallpaperHud(name);
        playSoundClick();
    }

    private void showWallpaperHud(String wallpaperName) {
        if (hudWallpaper == null || tvWallpaperPrompt == null) return;
        tvWallpaperPrompt.setText("Wallpaper  \u2022  " + wallpaperName);

        hudHandler.removeCallbacks(hideHudRunnable);
        hudWallpaper.setVisibility(View.VISIBLE);
        hudWallpaper.animate().cancel();
        hudWallpaper.setAlpha(0f);
        hudWallpaper.setTranslationY(-12f);
        hudWallpaper.animate()
            .alpha(1f)
            .translationY(0f)
            .setDuration(220)
            .setInterpolator(new DecelerateInterpolator())
            .start();

        hudHandler.postDelayed(hideHudRunnable, 2400);
    }

    private void showWeatherHud(String detailText) {
        if (hudWallpaper == null || tvWallpaperPrompt == null) return;
        tvWallpaperPrompt.setText("Weather  \u2022  " + detailText);

        hudHandler.removeCallbacks(hideHudRunnable);
        hudWallpaper.setVisibility(View.VISIBLE);
        hudWallpaper.animate().cancel();
        hudWallpaper.setAlpha(0f);
        hudWallpaper.setTranslationY(-12f);
        hudWallpaper.animate()
            .alpha(1f)
            .translationY(0f)
            .setDuration(220)
            .setInterpolator(new DecelerateInterpolator())
            .start();

        hudHandler.postDelayed(hideHudRunnable, 3000);
    }

    private void refreshWeather(final boolean showHud) {
        WeatherService.fetchWeather(this, showHud, new WeatherService.WeatherCallback() {
            @Override
            public void onWeatherLoaded(final String pillText, final String detailText) {
                if (btnWeather != null) {
                    btnWeather.setText(pillText);
                }
                if (showHud) {
                    showWeatherHud(detailText);
                }
            }
        });
    }

    private final Runnable hideHudRunnable = new Runnable() {
        @Override
        public void run() {
            if (hudWallpaper != null && hudWallpaper.getVisibility() == View.VISIBLE) {
                hudWallpaper.animate()
                    .alpha(0f)
                    .translationY(-12f)
                    .setDuration(200)
                    .withEndAction(new Runnable() {
                        @Override
                        public void run() {
                            hudWallpaper.setVisibility(View.GONE);
                        }
                    })
                    .start();
            }
        }
    };

    private void startAerialScreensaver() {
        android.util.Log.i("AppleTV_Screensaver", "startScreensaver called");
        try {
            Intent intent = new Intent(Intent.ACTION_MAIN);
            intent.setClassName("com.android.systemui", "com.android.systemui.Somnambulator");
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
            android.util.Log.i("AppleTV_Screensaver", "Started Somnambulator screensaver successfully");
            return;
        } catch (Exception e) {
            android.util.Log.w("AppleTV_Screensaver", "Somnambulator launch failed: " + e.getMessage());
        }

        try {
            Class<?> smClass = Class.forName("android.os.ServiceManager");
            java.lang.reflect.Method getService = smClass.getMethod("getService", String.class);
            android.os.IBinder binder = (android.os.IBinder) getService.invoke(null, "dreams");
            if (binder != null) {
                Class<?> stubClass = Class.forName("android.service.dreams.IDreamManager$Stub");
                java.lang.reflect.Method asInterface = stubClass.getMethod("asInterface", android.os.IBinder.class);
                Object dreamManager = asInterface.invoke(null, binder);
                java.lang.reflect.Method dreamMethod = dreamManager.getClass().getMethod("dream");
                dreamMethod.invoke(dreamManager);
                return;
            }
        } catch (Exception ignored) {}
    }

    @Override
    public void onUserInteraction() {
        super.onUserInteraction();
        resetIdleTimer();
    }

    private void bindViews() {
        rootView = findViewById(R.id.rootView);
        ambientGlowView = findViewById(R.id.ambientGlowView);
        ambientGlowViewBack = findViewById(R.id.ambientGlowViewBack);
        tvFocusedTitle = findViewById(R.id.tvFocusedTitle);
        mainScrollView = findViewById(R.id.mainScrollView);
        dockRow = findViewById(R.id.dockRow);
        favoritesScrollView = findViewById(R.id.favoritesScrollView);
        favoritesRow = findViewById(R.id.favoritesRow);
        dockContainer = findViewById(R.id.dockContainer);
        dockScrollView = findViewById(R.id.dockScrollView);
        tvFavoritesHeader = findViewById(R.id.tvFavoritesHeader);
        ccWallSeinfeld = findViewById(R.id.ccWallSeinfeld);
        ccWallFriends = findViewById(R.id.ccWallFriends);
        ccWallBigBang = findViewById(R.id.ccWallBigBang);
        ccWallB99 = findViewById(R.id.ccWallB99);
        ccWallModernFamily = findViewById(R.id.ccWallModernFamily);
        launchZoomContainer = findViewById(R.id.launchZoomContainer);
        vLaunchGlow = findViewById(R.id.vLaunchGlow);
        ivLaunchZoomIcon = findViewById(R.id.ivLaunchZoomIcon);
        glassHighlight = findViewById(R.id.glassHighlight);
        topBar = findViewById(R.id.topBar);
        tvGreeting = findViewById(R.id.tvGreeting);
        tvClock = findViewById(R.id.tvClock);
        tvAmPm = findViewById(R.id.tvAmPm);
        tvDate = findViewById(R.id.tvDate);
        btnWeather = findViewById(R.id.btnWeather);
        btnInputs = findViewById(R.id.btnInputs);
        btnControlCenter = findViewById(R.id.btnControlCenter);
        controlCenterScrim = findViewById(R.id.controlCenterScrim);
        controlCenterPanel = findViewById(R.id.controlCenterPanel);
        ccWallMojave = findViewById(R.id.ccWallMojave);
        ccWallSonoma = findViewById(R.id.ccWallSonoma);
        ccWallGot = findViewById(R.id.ccWallGot);
        ccWallHero = findViewById(R.id.ccWallHero);
        ccBtnScreensaver = findViewById(R.id.ccBtnScreensaver);
        ccBtnSleepTimer = findViewById(R.id.ccBtnSleepTimer);
        ccBtnSleepNow = findViewById(R.id.ccBtnSleepNow);
        ccToggleSound = findViewById(R.id.ccToggleSound);
        ccToggleGlow = findViewById(R.id.ccToggleGlow);
        ccTvNetworkInfo = findViewById(R.id.ccTvNetworkInfo);
        ccBtnWifi = findViewById(R.id.ccBtnWifi);
        ccBtnSettings = findViewById(R.id.ccBtnSettings);
        inputsDropdown = findViewById(R.id.inputsDropdown);
        optHdmi1 = findViewById(R.id.optHdmi1);
        optHdmi2 = findViewById(R.id.optHdmi2);
        optHdmi3 = findViewById(R.id.optHdmi3);
        optAv = findViewById(R.id.optAv);
        optLiveTv = findViewById(R.id.optLiveTv);
        hudReorder = findViewById(R.id.hudReorder);
        tvReorderPrompt = findViewById(R.id.tvReorderPrompt);
        hudWallpaper = findViewById(R.id.hudWallpaper);
        tvWallpaperPrompt = findViewById(R.id.tvWallpaperPrompt);
        ivWallpaper = findViewById(R.id.ivWallpaper);
        wallpaperVignette = findViewById(R.id.wallpaperVignette);
        ivHeroBackdrop = findViewById(R.id.ivHeroBackdrop);
        ivHeroBackdropBack = findViewById(R.id.ivHeroBackdropBack);
        heroMetadataLayout = findViewById(R.id.heroMetadataLayout);
        tvHeroTagline = findViewById(R.id.tvHeroTagline);

        if (ivWallpaper != null) {
            ivWallpaper.setScaleX(PARALLAX_SCALE);
            ivWallpaper.setScaleY(PARALLAX_SCALE);
        }
        if (ivHeroBackdrop != null) {
            ivHeroBackdrop.setScaleX(PARALLAX_SCALE);
            ivHeroBackdrop.setScaleY(PARALLAX_SCALE);
        }
        if (ivHeroBackdropBack != null) {
            ivHeroBackdropBack.setScaleX(PARALLAX_SCALE);
            ivHeroBackdropBack.setScaleY(PARALLAX_SCALE);
        }
    }

    private void updateClockAndGreeting() {
        Calendar cal = Calendar.getInstance();
        int hour = cal.get(Calendar.HOUR_OF_DAY);

        String greeting;
        if (hour >= 4 && hour < 12) {
            greeting = "GOOD MORNING, " + USER_NAME.toUpperCase() + "!";
        } else if (hour >= 12 && hour < 17) {
            greeting = "GOOD AFTERNOON, " + USER_NAME.toUpperCase() + "!";
        } else {
            greeting = "GOOD EVENING, " + USER_NAME.toUpperCase() + "!";
        }
        tvGreeting.setText(greeting);

        SimpleDateFormat clockFormat = new SimpleDateFormat("h:mm", Locale.getDefault());
        tvClock.setText(clockFormat.format(new Date()));

        if (tvAmPm != null) {
            SimpleDateFormat ampmFormat = new SimpleDateFormat("a", Locale.getDefault());
            tvAmPm.setText(ampmFormat.format(new Date()).toUpperCase());
        }

        SimpleDateFormat dateFormat = new SimpleDateFormat("EEEE  d MMMM", Locale.getDefault());
        tvDate.setText(dateFormat.format(new Date()).toUpperCase());
    }

    private void updateWifiStatus() {
        String ssid = "Wi-Fi";
        try {
            ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
            NetworkInfo netInfo = cm.getActiveNetworkInfo();
            if (netInfo != null && netInfo.isConnected() && netInfo.getType() == ConnectivityManager.TYPE_WIFI) {
                String extra = netInfo.getExtraInfo();
                if (extra != null && !extra.isEmpty() && !extra.equals("<unknown ssid>")) {
                    ssid = extra.replace("\"", "");
                } else {
                    WifiManager wm = (WifiManager) getApplicationContext().getSystemService(Context.WIFI_SERVICE);
                    if (wm != null) {
                        WifiInfo winfo = wm.getConnectionInfo();
                        if (winfo != null) {
                            String s = winfo.getSSID();
                            if (s != null && !s.equals("<unknown ssid>") && !s.isEmpty()) {
                                ssid = s.replace("\"", "");
                            }
                        }
                    }
                }
            } else if (netInfo != null && netInfo.isConnected() && netInfo.getType() == ConnectivityManager.TYPE_ETHERNET) {
                ssid = "Ethernet";
            }
        } catch (Exception ignored) {}

        if (ssid.equals("Wi-Fi") || ssid.equals("<unknown ssid>") || ssid.isEmpty()) {
            ssid = "Airtel_VTP_B105"; // Active Wi-Fi network
        }
        if (ccTvNetworkInfo != null) {
            ccTvNetworkInfo.setText(getNetworkStatusText());
        }
    }

    private void setupTopBar() {
        if (btnWeather != null) {
            btnWeather.setSoundEffectsEnabled(false);
            String cachedPill = WeatherService.getCachedPillText(this);
            if (cachedPill != null && !cachedPill.isEmpty()) {
                btnWeather.setText(cachedPill);
            } else {
                btnWeather.setText("33\u00B0 Mostly Clear");
            }
            btnWeather.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    playSoundClick();
                    refreshWeather(true);
                }
            });
            btnWeather.setOnKeyListener(new View.OnKeyListener() {
                @Override
                public boolean onKey(View v, int keyCode, KeyEvent event) {
                    if (event.getAction() != KeyEvent.ACTION_DOWN) return false;
                    if (keyCode == KeyEvent.KEYCODE_DPAD_LEFT) return true; // Block left edge
                    if (keyCode == KeyEvent.KEYCODE_DPAD_RIGHT) {
                        btnInputs.requestFocus();
                        return true;
                    }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_DOWN) {
                        focusDockIndex(0);
                        return true;
                    }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_UP) return true;
                    return false;
                }
            });
        }

        btnInputs.setSoundEffectsEnabled(false);

        btnInputs.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                playSoundClick();
                toggleInputsDropdown();
            }
        });

        // 100% Deterministic D-Pad navigation for Top Bar pills
        btnInputs.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                if (event.getAction() != KeyEvent.ACTION_DOWN) return false;
                if (keyCode == KeyEvent.KEYCODE_DPAD_LEFT) {
                    if (btnWeather != null) {
                        btnWeather.requestFocus();
                        return true;
                    }
                    return true;
                }
                if (keyCode == KeyEvent.KEYCODE_DPAD_RIGHT) {
                    if (btnControlCenter != null) {
                        btnControlCenter.requestFocus();
                        return true;
                    }
                    return true;
                }
                if (keyCode == KeyEvent.KEYCODE_DPAD_DOWN) {
                    if (inputsDropdown.getVisibility() == View.VISIBLE) {
                        optHdmi1.requestFocus();
                        return true;
                    }
                    focusDockIndex(1);
                    return true;
                }
                if (keyCode == KeyEvent.KEYCODE_DPAD_UP) return true;
                return false;
            }
        });

        if (btnControlCenter != null) {
            btnControlCenter.setSoundEffectsEnabled(false);
            btnControlCenter.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    playSoundClick();
                    openControlCenter();
                }
            });
            btnControlCenter.setOnKeyListener(new View.OnKeyListener() {
                @Override
                public boolean onKey(View v, int keyCode, KeyEvent event) {
                    if (event.getAction() != KeyEvent.ACTION_DOWN) return false;
                    if (keyCode == KeyEvent.KEYCODE_DPAD_LEFT) {
                        btnInputs.requestFocus();
                        return true;
                    }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_RIGHT) {
                        openControlCenter();
                        return true;
                    }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_DOWN) {
                        focusDockIndex(2);
                        return true;
                    }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_UP) return true;
                    return false;
                }
            });
        }

        View.OnFocusChangeListener topBarFocus = new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if (hasFocus) {
                    lastFocusedView = v;
                    if (isUserNavigating) playSoundNavigate();
                    glassHighlight.setVisibility(View.INVISIBLE);
                    topBar.animate().alpha(1.0f).translationY(0f).setDuration(180).start();
                    resetParallax();
                }
            }
        };
        if (btnWeather != null) btnWeather.setOnFocusChangeListener(topBarFocus);
        btnInputs.setOnFocusChangeListener(topBarFocus);
        if (btnControlCenter != null) btnControlCenter.setOnFocusChangeListener(topBarFocus);

        // Hide topBar and dropdown smoothly when scrolling down into All Apps
        mainScrollView.setOnScrollChangeListener(new View.OnScrollChangeListener() {
            @Override
            public void onScrollChange(View v, int scrollX, int scrollY, int oldScrollX, int oldScrollY) {
                if (scrollY > 10) {
                    if (inputsDropdown != null && inputsDropdown.getVisibility() == View.VISIBLE) {
                        inputsDropdown.setVisibility(View.GONE);
                    }
                    if (topBar.getAlpha() > 0.05f) {
                        topBar.animate().alpha(0.0f).translationY(-50f).setDuration(180).start();
                    }
                    if (heroMetadataLayout != null && heroMetadataLayout.getAlpha() > 0.01f) {
                        heroMetadataLayout.animate().cancel();
                        heroMetadataLayout.animate().alpha(0.0f).setDuration(120).start();
                    }
                    if (isHeroTheme() && ivHeroBackdrop != null && ivHeroBackdrop.getAlpha() > 0.2f && (lastFocusedView == null || !favoritesTileViews.contains(lastFocusedView))) {
                        ivHeroBackdrop.animate().alpha(0.18f).setDuration(180).start();
                    }
                } else if (scrollY <= 5) {
                    if (lastFocusedView != null && (dockTileViews.contains(lastFocusedView) || lastFocusedView == btnWeather || lastFocusedView == btnInputs || lastFocusedView == btnControlCenter)) {
                        if (topBar.getAlpha() < 0.95f) {
                            topBar.animate().alpha(1.0f).translationY(0f).setDuration(220).start();
                        }
                        if (dockTileViews.contains(lastFocusedView)) {
                            if (heroMetadataLayout != null) {
                                heroMetadataLayout.animate().cancel();
                                heroMetadataLayout.animate().alpha(1.0f).translationY(0f).translationX(0f).setDuration(180).start();
                            }
                            if (isHeroTheme() && ivHeroBackdrop != null && ivHeroBackdrop.getAlpha() < 0.95f) {
                                ivHeroBackdrop.animate().alpha(1.0f).setDuration(200).start();
                            }
                        }
                    }
                }
            }
        });
    }

    private void focusDockIndex(int index) {
        if (lastFocusedDockView != null) {
            lastFocusedDockView.requestFocus();
        } else if (!dockTileViews.isEmpty()) {
            int t = Math.min(index, dockTileViews.size() - 1);
            dockTileViews.get(t).requestFocus();
        }
    }

    private void toggleInputsDropdown() {
        if (inputsDropdown.getVisibility() == View.VISIBLE) {
            inputsDropdown.setVisibility(View.GONE);
            btnInputs.requestFocus();
        } else {
            inputsDropdown.setVisibility(View.VISIBLE);
            optHdmi1.requestFocus();
        }
    }

    private void setupInputsDropdown() {
        TextView[] opts = new TextView[] { optHdmi1, optHdmi2, optHdmi3, optAv, optLiveTv };
        View.OnFocusChangeListener dropdownFocusListener = new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if (hasFocus && isUserNavigating) {
                    playSoundNavigate();
                }
            }
        };

        for (TextView opt : opts) {
            opt.setSoundEffectsEnabled(false);
            opt.setOnFocusChangeListener(dropdownFocusListener);
        }

        optHdmi1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                playSoundClick();
                launchTvInput("com.tcl.tvinput/.passthroughinput.TvPassThroughService/HW1413744128");
            }
        });
        optHdmi2.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                playSoundClick();
                launchTvInput("com.tcl.tvinput/.passthroughinput.TvPassThroughService/HW1413744384");
            }
        });
        optHdmi3.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                playSoundClick();
                launchTvInput("com.tcl.tvinput/.passthroughinput.TvPassThroughService/HW1413744640");
            }
        });
        optAv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                playSoundClick();
                launchTvInput("com.tcl.tvinput/.passthroughinput.TvPassThroughService/HW1413743104");
            }
        });
        optLiveTv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                playSoundClick();
                launchTvInput("com.tcl.tvinput/.TDTVInputService/HW1413742848");
            }
        });

        View.OnKeyListener dropdownKeyListener = new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                if (event.getAction() != KeyEvent.ACTION_DOWN) return false;

                if (keyCode == KeyEvent.KEYCODE_BACK) {
                    playSoundBack();
                    inputsDropdown.setVisibility(View.GONE);
                    btnInputs.requestFocus();
                    return true;
                } else if (keyCode == KeyEvent.KEYCODE_DPAD_UP && v == optHdmi1) {
                    btnInputs.requestFocus();
                    return true;
                } else if (keyCode == KeyEvent.KEYCODE_DPAD_DOWN && v == optLiveTv) {
                    return true; // Stop at bottom of dropdown
                }
                return false;
            }
        };

        optHdmi1.setOnKeyListener(dropdownKeyListener);
        optHdmi2.setOnKeyListener(dropdownKeyListener);
        optHdmi3.setOnKeyListener(dropdownKeyListener);
        optAv.setOnKeyListener(dropdownKeyListener);
        optLiveTv.setOnKeyListener(dropdownKeyListener);
    }

    private void launchTvInput(String inputId) {
        inputsDropdown.setVisibility(View.GONE);
        try {
            Uri uri = Uri.parse("content://android.media.tv/passthrough/" + Uri.encode(inputId));
            Intent intent = new Intent(Intent.ACTION_VIEW, uri);
            intent.setComponent(new ComponentName("com.tcl.tv", "com.tcl.tv.TVActivity"));
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
        } catch (Exception e) {
            try {
                Intent fallback = new Intent();
                fallback.setComponent(new ComponentName("com.tcl.tv", "com.tcl.tv.TVActivity"));
                fallback.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(fallback);
            } catch (Exception ignored) {}
        }
    }

    private void setupControlCenter() {
        if (controlCenterPanel == null) return;

        SharedPreferences sp = getSharedPreferences(PREF_NAME, MODE_PRIVATE);
        isSoundEffectsEnabled = sp.getBoolean("sound_effects_enabled", true);
        isAmbientGlowEnabled = sp.getBoolean("ambient_glow_enabled", true);

        if (controlCenterScrim != null) {
            controlCenterScrim.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    closeControlCenter();
                }
            });
        }

        View.OnFocusChangeListener ccFocus = new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if (hasFocus) {
                    playSoundNavigate();
                    v.animate().scaleX(1.03f).scaleY(1.03f).setDuration(120).start();
                } else {
                    v.animate().scaleX(1.0f).scaleY(1.0f).setDuration(120).start();
                }
            }
        };

        if (ccWallMojave != null) {
            ccWallMojave.setOnFocusChangeListener(ccFocus);
            ccWallMojave.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    playSoundClick();
                    setWallpaperTheme("mojave");
                    updateControlCenterWallpaperStates();
                    showWallpaperHud("Mojave Sand Dunes");
                }
            });
            ccWallMojave.setOnKeyListener(new View.OnKeyListener() {
                @Override
                public boolean onKey(View v, int keyCode, KeyEvent event) {
                    if (event.getAction() != KeyEvent.ACTION_DOWN) return false;
                    if (keyCode == KeyEvent.KEYCODE_DPAD_LEFT) { closeControlCenter(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_RIGHT) { if (ccWallSonoma != null) ccWallSonoma.requestFocus(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_DOWN) { if (ccWallGot != null) ccWallGot.requestFocus(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_UP) return true;
                    return false;
                }
            });
        }

        if (ccWallSonoma != null) {
            ccWallSonoma.setOnFocusChangeListener(ccFocus);
            ccWallSonoma.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    playSoundClick();
                    setWallpaperTheme("sonoma");
                    updateControlCenterWallpaperStates();
                    showWallpaperHud("Sonoma Horizon");
                }
            });
            ccWallSonoma.setOnKeyListener(new View.OnKeyListener() {
                @Override
                public boolean onKey(View v, int keyCode, KeyEvent event) {
                    if (event.getAction() != KeyEvent.ACTION_DOWN) return false;
                    if (keyCode == KeyEvent.KEYCODE_DPAD_LEFT) { if (ccWallMojave != null) ccWallMojave.requestFocus(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_RIGHT) return true;
                    if (keyCode == KeyEvent.KEYCODE_DPAD_DOWN) { if (ccWallHero != null) ccWallHero.requestFocus(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_UP) return true;
                    return false;
                }
            });
        }

        if (ccWallGot != null) {
            ccWallGot.setOnFocusChangeListener(ccFocus);
            ccWallGot.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    playSoundClick();
                    setWallpaperTheme("got");
                    updateControlCenterWallpaperStates();
                    showWallpaperHud("The Wall \u2022 Westeros");
                }
            });
            ccWallGot.setOnKeyListener(new View.OnKeyListener() {
                @Override
                public boolean onKey(View v, int keyCode, KeyEvent event) {
                    if (event.getAction() != KeyEvent.ACTION_DOWN) return false;
                    if (keyCode == KeyEvent.KEYCODE_DPAD_LEFT) { closeControlCenter(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_RIGHT) { if (ccWallHero != null) ccWallHero.requestFocus(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_DOWN) { if (ccBtnScreensaver != null) ccBtnScreensaver.requestFocus(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_UP) { if (ccWallMojave != null) ccWallMojave.requestFocus(); return true; }
                    return false;
                }
            });
        }

        if (ccWallHero != null) {
            ccWallHero.setOnFocusChangeListener(ccFocus);
            ccWallHero.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    playSoundClick();
                    setWallpaperTheme("hero");
                    updateControlCenterWallpaperStates();
                    showWallpaperHud("Dynamic Hero Backdrops");
                }
            });
            ccWallHero.setOnKeyListener(new View.OnKeyListener() {
                @Override
                public boolean onKey(View v, int keyCode, KeyEvent event) {
                    if (event.getAction() != KeyEvent.ACTION_DOWN) return false;
                    if (keyCode == KeyEvent.KEYCODE_DPAD_LEFT) { if (ccWallGot != null) ccWallGot.requestFocus(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_RIGHT) return true;
                    if (keyCode == KeyEvent.KEYCODE_DPAD_DOWN) { if (ccBtnSleepTimer != null) ccBtnSleepTimer.requestFocus(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_UP) { if (ccWallSonoma != null) ccWallSonoma.requestFocus(); return true; }
                    return false;
                }
            });
        }

        if (ccBtnScreensaver != null) {
            ccBtnScreensaver.setOnFocusChangeListener(ccFocus);
            ccBtnScreensaver.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    closeControlCenter();
                    startAerialScreensaver();
                }
            });
            ccBtnScreensaver.setOnKeyListener(new View.OnKeyListener() {
                @Override
                public boolean onKey(View v, int keyCode, KeyEvent event) {
                    if (event.getAction() != KeyEvent.ACTION_DOWN) return false;
                    if (keyCode == KeyEvent.KEYCODE_DPAD_LEFT) { closeControlCenter(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_RIGHT) { if (ccBtnSleepTimer != null) ccBtnSleepTimer.requestFocus(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_DOWN) { if (ccBtnSleepNow != null) ccBtnSleepNow.requestFocus(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_UP) { if (ccWallGot != null) ccWallGot.requestFocus(); return true; }
                    return false;
                }
            });
        }

        if (ccBtnSleepTimer != null) {
            ccBtnSleepTimer.setOnFocusChangeListener(ccFocus);
            ccBtnSleepTimer.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    cycleSleepTimer();
                }
            });
            ccBtnSleepTimer.setOnKeyListener(new View.OnKeyListener() {
                @Override
                public boolean onKey(View v, int keyCode, KeyEvent event) {
                    if (event.getAction() != KeyEvent.ACTION_DOWN) return false;
                    if (keyCode == KeyEvent.KEYCODE_DPAD_LEFT) { if (ccBtnScreensaver != null) ccBtnScreensaver.requestFocus(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_RIGHT) return true;
                    if (keyCode == KeyEvent.KEYCODE_DPAD_DOWN) { if (ccBtnSleepNow != null) ccBtnSleepNow.requestFocus(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_UP) { if (ccWallHero != null) ccWallHero.requestFocus(); return true; }
                    return false;
                }
            });
        }

        if (ccBtnSleepNow != null) {
            ccBtnSleepNow.setOnFocusChangeListener(ccFocus);
            ccBtnSleepNow.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    closeControlCenter();
                    putTvToSleep();
                }
            });
            ccBtnSleepNow.setOnKeyListener(new View.OnKeyListener() {
                @Override
                public boolean onKey(View v, int keyCode, KeyEvent event) {
                    if (event.getAction() != KeyEvent.ACTION_DOWN) return false;
                    if (keyCode == KeyEvent.KEYCODE_DPAD_LEFT) { closeControlCenter(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_RIGHT) return true;
                    if (keyCode == KeyEvent.KEYCODE_DPAD_DOWN) { if (ccToggleSound != null) ccToggleSound.requestFocus(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_UP) { if (ccBtnScreensaver != null) ccBtnScreensaver.requestFocus(); return true; }
                    return false;
                }
            });
        }

        if (ccToggleSound != null) {
            ccToggleSound.setOnFocusChangeListener(ccFocus);
            ccToggleSound.setText(isSoundEffectsEnabled ? "Sound: ON" : "Sound: OFF");
            ccToggleSound.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    isSoundEffectsEnabled = !isSoundEffectsEnabled;
                    getSharedPreferences(PREF_NAME, MODE_PRIVATE).edit().putBoolean("sound_effects_enabled", isSoundEffectsEnabled).apply();
                    ccToggleSound.setText(isSoundEffectsEnabled ? "Sound: ON" : "Sound: OFF");
                    if (isSoundEffectsEnabled) playSoundClick();
                    showWallpaperHud(isSoundEffectsEnabled ? "Navigation Audio: ON" : "Navigation Audio: OFF");
                }
            });
            ccToggleSound.setOnKeyListener(new View.OnKeyListener() {
                @Override
                public boolean onKey(View v, int keyCode, KeyEvent event) {
                    if (event.getAction() != KeyEvent.ACTION_DOWN) return false;
                    if (keyCode == KeyEvent.KEYCODE_DPAD_LEFT) { closeControlCenter(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_RIGHT) { if (ccToggleGlow != null) ccToggleGlow.requestFocus(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_DOWN) { if (ccBtnWifi != null) ccBtnWifi.requestFocus(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_UP) { if (ccBtnSleepNow != null) ccBtnSleepNow.requestFocus(); return true; }
                    return false;
                }
            });
        }

        if (ccToggleGlow != null) {
            ccToggleGlow.setOnFocusChangeListener(ccFocus);
            ccToggleGlow.setText(isAmbientGlowEnabled ? "Ambient: ON" : "Ambient: OFF");
            ccToggleGlow.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    isAmbientGlowEnabled = !isAmbientGlowEnabled;
                    getSharedPreferences(PREF_NAME, MODE_PRIVATE).edit().putBoolean("ambient_glow_enabled", isAmbientGlowEnabled).apply();
                    ccToggleGlow.setText(isAmbientGlowEnabled ? "Ambient: ON" : "Ambient: OFF");
                    if (!isAmbientGlowEnabled) {
                        if (ambientGlowView != null) ambientGlowView.animate().alpha(0.0f).setDuration(200).start();
                    } else {
                        currentGlowColor = 0;
                        if (dockRow != null && !dockApps.isEmpty()) {
                            setAmbientGlow(dockApps.get(0).accentColor);
                        }
                    }
                    playSoundClick();
                    showWallpaperHud(isAmbientGlowEnabled ? "Ambient Glow: ON" : "Ambient Glow: OFF");
                }
            });
            ccToggleGlow.setOnKeyListener(new View.OnKeyListener() {
                @Override
                public boolean onKey(View v, int keyCode, KeyEvent event) {
                    if (event.getAction() != KeyEvent.ACTION_DOWN) return false;
                    if (keyCode == KeyEvent.KEYCODE_DPAD_LEFT) { if (ccToggleSound != null) ccToggleSound.requestFocus(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_RIGHT) return true;
                    if (keyCode == KeyEvent.KEYCODE_DPAD_DOWN) { if (ccBtnSettings != null) ccBtnSettings.requestFocus(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_UP) { if (ccBtnSleepNow != null) ccBtnSleepNow.requestFocus(); return true; }
                    return false;
                }
            });
        }

        if (ccBtnWifi != null) {
            ccBtnWifi.setOnFocusChangeListener(ccFocus);
            ccBtnWifi.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    playSoundClick();
                    closeControlCenter();
                    try {
                        startActivity(new Intent(Settings.ACTION_WIFI_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));
                    } catch (Exception e) {
                        try {
                            startActivity(new Intent(Settings.ACTION_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));
                        } catch (Exception ignored) {}
                    }
                }
            });
            ccBtnWifi.setOnKeyListener(new View.OnKeyListener() {
                @Override
                public boolean onKey(View v, int keyCode, KeyEvent event) {
                    if (event.getAction() != KeyEvent.ACTION_DOWN) return false;
                    if (keyCode == KeyEvent.KEYCODE_DPAD_LEFT) { closeControlCenter(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_RIGHT) { if (ccBtnSettings != null) ccBtnSettings.requestFocus(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_DOWN) return true;
                    if (keyCode == KeyEvent.KEYCODE_DPAD_UP) { if (ccToggleSound != null) ccToggleSound.requestFocus(); return true; }
                    return false;
                }
            });
        }

        if (ccBtnSettings != null) {
            ccBtnSettings.setOnFocusChangeListener(ccFocus);
            ccBtnSettings.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    playSoundClick();
                    closeControlCenter();
                    launchTvSettings();
                }
            });
            ccBtnSettings.setOnKeyListener(new View.OnKeyListener() {
                @Override
                public boolean onKey(View v, int keyCode, KeyEvent event) {
                    if (event.getAction() != KeyEvent.ACTION_DOWN) return false;
                    if (keyCode == KeyEvent.KEYCODE_DPAD_LEFT) { if (ccBtnWifi != null) ccBtnWifi.requestFocus(); return true; }
                    if (keyCode == KeyEvent.KEYCODE_DPAD_RIGHT) return true;
                    if (keyCode == KeyEvent.KEYCODE_DPAD_DOWN) return true;
                    if (keyCode == KeyEvent.KEYCODE_DPAD_UP) { if (ccToggleGlow != null) ccToggleGlow.requestFocus(); return true; }
                    return false;
                }
            });
        }

        updateControlCenterWallpaperStates();
    }

    public void openControlCenter() {
        if (isControlCenterOpen || controlCenterPanel == null) return;
        isControlCenterOpen = true;
        lastViewBeforeControlCenter = getCurrentFocus();
        if (inputsDropdown != null && inputsDropdown.getVisibility() == View.VISIBLE) {
            inputsDropdown.setVisibility(View.GONE);
        }
        playSoundClick();

        if (ccTvNetworkInfo != null) {
            ccTvNetworkInfo.setText(getNetworkStatusText());
        }
        updateControlCenterWallpaperStates();

        if (controlCenterScrim != null) {
            controlCenterScrim.setVisibility(View.VISIBLE);
            controlCenterScrim.setAlpha(0.0f);
            controlCenterScrim.animate().alpha(1.0f).setDuration(220).start();
        }

        controlCenterPanel.setVisibility(View.VISIBLE);
        float widthPx = 380f * getResources().getDisplayMetrics().density;
        controlCenterPanel.setTranslationX(widthPx);
        controlCenterPanel.animate()
            .translationX(0f)
            .setDuration(280)
            .setInterpolator(new DecelerateInterpolator())
            .withEndAction(new Runnable() {
                @Override
                public void run() {
                    String theme = getSharedPreferences(PREF_NAME, MODE_PRIVATE).getString(KEY_WALLPAPER, "hero");
                    if ("mojave".equalsIgnoreCase(theme) && ccWallMojave != null) ccWallMojave.requestFocus();
                    else if ("sonoma".equalsIgnoreCase(theme) && ccWallSonoma != null) ccWallSonoma.requestFocus();
                    else if ("got".equalsIgnoreCase(theme) && ccWallGot != null) ccWallGot.requestFocus();
                    else if (ccWallHero != null) ccWallHero.requestFocus();
                    else if (ccWallMojave != null) ccWallMojave.requestFocus();
                }
            })
            .start();
    }

    public void closeControlCenter() {
        if (!isControlCenterOpen || controlCenterPanel == null) return;
        isControlCenterOpen = false;
        playSoundBack();

        if (controlCenterScrim != null) {
            controlCenterScrim.animate().alpha(0.0f).setDuration(180).start();
        }

        float widthPx = 380f * getResources().getDisplayMetrics().density;
        controlCenterPanel.animate()
            .translationX(widthPx)
            .setDuration(240)
            .setInterpolator(new AccelerateInterpolator())
            .withEndAction(new Runnable() {
                @Override
                public void run() {
                    controlCenterPanel.setVisibility(View.GONE);
                    if (controlCenterScrim != null) controlCenterScrim.setVisibility(View.GONE);
                    if (lastViewBeforeControlCenter != null && lastViewBeforeControlCenter.isShown()) {
                        lastViewBeforeControlCenter.requestFocus();
                    } else if (btnControlCenter != null) {
                        btnControlCenter.requestFocus();
                    }
                }
            })
            .start();
    }

    public void toggleControlCenter() {
        if (isControlCenterOpen) {
            closeControlCenter();
        } else {
            openControlCenter();
        }
    }

    private void updateControlCenterWallpaperStates() {
        String theme = getSharedPreferences(PREF_NAME, MODE_PRIVATE).getString(KEY_WALLPAPER, "hero");
        if (ccWallMojave != null) {
            boolean active = "mojave".equalsIgnoreCase(theme);
            ccWallMojave.setSelected(active);
            ccWallMojave.setText(active ? "\u25CF Mojave" : "Mojave");
        }
        if (ccWallSonoma != null) {
            boolean active = "sonoma".equalsIgnoreCase(theme);
            ccWallSonoma.setSelected(active);
            ccWallSonoma.setText(active ? "\u25CF Sonoma" : "Sonoma");
        }
        if (ccWallGot != null) {
            boolean active = "got".equalsIgnoreCase(theme);
            ccWallGot.setSelected(active);
            ccWallGot.setText(active ? "\u25CF Westeros" : "GoT Westeros");
        }
        if (ccWallHero != null) {
            boolean active = "hero".equalsIgnoreCase(theme);
            ccWallHero.setSelected(active);
            ccWallHero.setText(active ? "\u25CF Dynamic" : "Dynamic Hero");
        }
    }

    private void cycleSleepTimer() {
        playSoundClick();
        if (sleepTimerMinutes == 0) sleepTimerMinutes = 15;
        else if (sleepTimerMinutes == 15) sleepTimerMinutes = 30;
        else if (sleepTimerMinutes == 30) sleepTimerMinutes = 60;
        else if (sleepTimerMinutes == 60) sleepTimerMinutes = 90;
        else sleepTimerMinutes = 0;

        if (sleepTimerRunnable != null) {
            sleepTimerHandler.removeCallbacks(sleepTimerRunnable);
            sleepTimerRunnable = null;
        }

        if (ccBtnSleepTimer != null) {
            ccBtnSleepTimer.setText(sleepTimerMinutes > 0 ? "Timer: " + sleepTimerMinutes + "m" : "Timer: Off");
        }

        if (sleepTimerMinutes > 0) {
            showWallpaperHud("Sleep Timer: " + sleepTimerMinutes + " min");
            sleepTimerRunnable = new Runnable() {
                @Override
                public void run() {
                    putTvToSleep();
                }
            };
            sleepTimerHandler.postDelayed(sleepTimerRunnable, sleepTimerMinutes * 60 * 1000L);
        } else {
            showWallpaperHud("Sleep Timer: Off");
        }
    }

    private void putTvToSleep() {
        playSoundClick();
        showWallpaperHud("Entering Standby...");
        rootView.postDelayed(new Runnable() {
            @Override
            public void run() {
                try {
                    Runtime.getRuntime().exec("input keyevent 26");
                } catch (Exception e) {
                    startAerialScreensaver();
                }
            }
        }, 400);
    }

    private String getNetworkStatusText() {
        try {
            ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
            NetworkInfo active = (cm != null) ? cm.getActiveNetworkInfo() : null;
            if (active != null && active.isConnected()) {
                String type = (active.getType() == ConnectivityManager.TYPE_WIFI) ? "Wi-Fi" : "Ethernet";
                String ip = getLocalIpAddress();
                String ssid = "Airtel_VTP_B105";
                try {
                    WifiManager wm = (WifiManager) getApplicationContext().getSystemService(Context.WIFI_SERVICE);
                    if (wm != null) {
                        WifiInfo winfo = wm.getConnectionInfo();
                        if (winfo != null && winfo.getSSID() != null && !winfo.getSSID().equals("<unknown ssid>")) {
                            ssid = winfo.getSSID().replace("\"", "");
                        }
                    }
                } catch (Exception ignored) {}
                if (type.equals("Wi-Fi")) {
                    return "Connected \u2022 " + ssid + " (" + ip + ")";
                } else {
                    return "Ethernet Connected \u2022 " + ip;
                }
            }
        } catch (Exception ignored) {}
        return "Connected \u2022 Airtel_VTP_B105 (192.168.1.128)";
    }

    private String getLocalIpAddress() {
        try {
            for (Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces(); en.hasMoreElements(); ) {
                NetworkInterface intf = en.nextElement();
                for (Enumeration<InetAddress> enumIpAddr = intf.getInetAddresses(); enumIpAddr.hasMoreElements(); ) {
                    InetAddress inetAddress = enumIpAddr.nextElement();
                    if (!inetAddress.isLoopbackAddress() && inetAddress instanceof Inet4Address) {
                        return inetAddress.getHostAddress();
                    }
                }
            }
        } catch (Exception ignored) {}
        return "192.168.1.128";
    }

    private void loadApplications() {
        PackageManager pm = getPackageManager();
        dockApps.clear();
        gridApps.clear();
        Set<String> dockSet = new HashSet<>();

        // 1. Populate the 4 dock apps strictly in user preference order:
        // [0] Netflix, [1] Prime Video, [2] JioHotstar, [3] YouTube
        for (String pkg : DOCK_PACKAGES) {
            AppItem item = resolveAppItem(pm, pkg);
            if (item != null) {
                dockApps.add(item);
                dockSet.add(pkg);
            }
        }

        // 2. Query all remaining apps for 4-column grid:
        Intent leanbackIntent = new Intent(Intent.ACTION_MAIN);
        leanbackIntent.addCategory(Intent.CATEGORY_LEANBACK_LAUNCHER);
        List<ResolveInfo> activities = pm.queryIntentActivities(leanbackIntent, 0);

        Intent mainIntent = new Intent(Intent.ACTION_MAIN);
        mainIntent.addCategory(Intent.CATEGORY_LAUNCHER);
        List<ResolveInfo> standardActivities = pm.queryIntentActivities(mainIntent, 0);

        Set<String> addedGridPackages = new HashSet<>();
        List<ResolveInfo> combined = new ArrayList<>();
        if (activities != null) combined.addAll(activities);
        if (standardActivities != null) combined.addAll(standardActivities);

        List<AppItem> discoveredGridApps = new ArrayList<>();
        Map<String, AppItem> appMap = new HashMap<>();

        for (ResolveInfo ri : combined) {
            String pkg = ri.activityInfo.packageName;
            if (dockSet.contains(pkg)) continue;
            if (addedGridPackages.contains(pkg)) continue;
            if (pkg.equals(getPackageName())) continue;
            if (pkg.equals("com.google.android.apps.tv.launcherx")) continue;
            if (pkg.equals("com.android.tv.settings")) continue;
            if (pkg.equals("com.tcl.settings")) continue;
            if (pkg.equals("com.android.deskclock")) continue;
            if (pkg.equals("com.tcl.initsetup")) continue;
            if (pkg.equals("com.tcl.micmanager")) continue;
            if (pkg.startsWith("com.google.android.tungsten")) continue;
            if (pkg.equals("com.klevico.monet")) continue;

            addedGridPackages.add(pkg);
            AppItem item = createAppItem(pm, ri);
            discoveredGridApps.add(item);
            appMap.put(pkg, item);
        }

        // Apply saved custom order if present
        SharedPreferences prefs = getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE);
        String savedOrder = prefs.getString(KEY_GRID_ORDER, null);
        if (savedOrder != null && !savedOrder.trim().isEmpty()) {
            String[] pkgList = savedOrder.split(",");
            for (String p : pkgList) {
                String cleanPkg = p.trim();
                if (appMap.containsKey(cleanPkg)) {
                    gridApps.add(appMap.remove(cleanPkg));
                }
            }
            // Append any newly discovered apps not in saved list
            for (AppItem rem : discoveredGridApps) {
                if (appMap.containsKey(rem.packageName)) {
                    gridApps.add(rem);
                    appMap.remove(rem.packageName);
                }
            }
        } else {
            gridApps.addAll(discoveredGridApps);
        }

        buildDockViews();
        initFavoriteSeries();
        buildFavoritesViews();
        buildGridViews();
    }

    private AppItem resolveAppItem(PackageManager pm, String pkg) {
        try {
            // First try querying main intent for package
            Intent intent = new Intent(Intent.ACTION_MAIN);
            intent.setPackage(pkg);
            List<ResolveInfo> list = pm.queryIntentActivities(intent, 0);
            if (list != null && !list.isEmpty()) {
                return createAppItem(pm, list.get(0));
            }

            // Fallback to ApplicationInfo
            ApplicationInfo appInfo = pm.getApplicationInfo(pkg, 0);
            AppItem item = new AppItem();
            item.packageName = pkg;
            item.label = pm.getApplicationLabel(appInfo).toString();
            item.banner = appInfo.loadBanner(pm);
            item.icon = appInfo.loadIcon(pm);

            Drawable customBanner = getCustomBanner(pkg);
            if (customBanner != null) {
                item.banner = customBanner;
            }

            if (BRAND_COLORS.containsKey(pkg)) {
                item.accentColor = BRAND_COLORS.get(pkg);
            } else {
                item.accentColor = extractAccentColor(item.banner != null ? item.banner : item.icon);
            }
            return item;
        } catch (Exception e) {
            return null;
        }
    }

    private AppItem createAppItem(PackageManager pm, ResolveInfo ri) {
        AppItem item = new AppItem();
        item.packageName = ri.activityInfo.packageName;
        item.activityName = ri.activityInfo.name;
        item.label = ri.loadLabel(pm).toString();
        item.banner = ri.activityInfo.loadBanner(pm);
        item.icon = ri.activityInfo.loadIcon(pm);

        Drawable customBanner = getCustomBanner(item.packageName);
        if (customBanner != null) {
            item.banner = customBanner;
        }

        if (BRAND_COLORS.containsKey(item.packageName)) {
            item.accentColor = BRAND_COLORS.get(item.packageName);
        } else {
            item.accentColor = extractAccentColor(item.banner != null ? item.banner : item.icon);
        }
        return item;
    }

    private Drawable getCustomBanner(String packageName) {
        if ("com.apple.atve.androidtv.appletv".equals(packageName) || "com.apple.atve.tcl.appletv".equals(packageName)) {
            try { return getResources().getDrawable(R.drawable.banner_appletv, null); } catch (Exception ignored) {}
        } else if ("tv.airtel.xstream.tvapp".equals(packageName)) {
            try { return getResources().getDrawable(R.drawable.banner_xstream, null); } catch (Exception ignored) {}
        } else if ("com.graymatrix.did".equals(packageName)) {
            try { return getResources().getDrawable(R.drawable.banner_zee5, null); } catch (Exception ignored) {}
        } else if ("com.cricfytv.sports".equals(packageName)) {
            try { return getResources().getDrawable(R.drawable.banner_cricfy, null); } catch (Exception ignored) {}
        } else if ("com.neilturner.aerialviews".equals(packageName)) {
            try { return getResources().getDrawable(R.drawable.banner_aerialviews, null); } catch (Exception ignored) {}
        } else if ("com.codingbuffalo.aerialdream".equals(packageName)) {
            try { return getResources().getDrawable(R.drawable.banner_aerialdream, null); } catch (Exception ignored) {}
        } else if ("com.android.vending".equals(packageName)) {
            try { return getResources().getDrawable(R.drawable.banner_playstore, null); } catch (Exception ignored) {}
        } else if ("com.tcl.tv".equals(packageName)) {
            try { return getResources().getDrawable(R.drawable.banner_tcltv, null); } catch (Exception ignored) {}
        } else if ("com.tcl.t_solo".equals(packageName)) {
            try { return getResources().getDrawable(R.drawable.banner_tsolo, null); } catch (Exception ignored) {}
        } else if ("com.esaba.downloader".equals(packageName)) {
            try { return getResources().getDrawable(R.drawable.banner_downloader, null); } catch (Exception ignored) {}
        } else if ("com.tcl.gallery".equals(packageName)) {
            try { return getResources().getDrawable(R.drawable.banner_gallery, null); } catch (Exception ignored) {}
        } else if ("com.tcl.ui_mediaCenter".equals(packageName)) {
            try { return getResources().getDrawable(R.drawable.banner_mediaplayer, null); } catch (Exception ignored) {}
        } else if ("com.mxtech.videoplayer.television".equals(packageName)) {
            try { return getResources().getDrawable(R.drawable.banner_mxplayer, null); } catch (Exception ignored) {}
        } else if ("com.stremio.one".equals(packageName)) {
            try { return getResources().getDrawable(R.drawable.banner_stremio, null); } catch (Exception ignored) {}
        } else if ("com.yablio.sendfilestotv".equals(packageName)) {
            try { return getResources().getDrawable(R.drawable.banner_sftv, null); } catch (Exception ignored) {}
        } else if ("com.instantbits.cast.receiver".equals(packageName)) {
            try { return getResources().getDrawable(R.drawable.banner_wvc, null); } catch (Exception ignored) {}
        }
        return null;
    }

    private int extractAccentColor(Drawable drawable) {
        if (drawable == null) return Color.parseColor("#0A84FF");
        try {
            Bitmap bmp = null;
            if (drawable instanceof BitmapDrawable) {
                bmp = ((BitmapDrawable) drawable).getBitmap();
            } else {
                bmp = Bitmap.createBitmap(48, 48, Bitmap.Config.ARGB_8888);
                Canvas canvas = new Canvas(bmp);
                drawable.setBounds(0, 0, 48, 48);
                drawable.draw(canvas);
            }
            if (bmp != null) {
                long totalR = 0, totalG = 0, totalB = 0;
                int count = 0;
                int stepX = Math.max(1, bmp.getWidth() / 8);
                int stepY = Math.max(1, bmp.getHeight() / 8);
                for (int x = 0; x < bmp.getWidth(); x += stepX) {
                    for (int y = 0; y < bmp.getHeight(); y += stepY) {
                        int pixel = bmp.getPixel(x, y);
                        int alpha = Color.alpha(pixel);
                        if (alpha < 120) continue;
                        int r = Color.red(pixel);
                        int g = Color.green(pixel);
                        int b = Color.blue(pixel);
                        int brightness = (r + g + b) / 3;
                        if (brightness < 35 || brightness > 230) continue;
                        totalR += r;
                        totalG += g;
                        totalB += b;
                        count++;
                    }
                }
                if (count > 0) {
                    return Color.rgb((int)(totalR / count), (int)(totalG / count), (int)(totalB / count));
                }
            }
        } catch (Exception ignored) {}
        return Color.parseColor("#0A84FF");
    }

    private void buildDockViews() {
        dockRow.removeAllViews();
        dockTileViews.clear();

        LayoutInflater inflater = LayoutInflater.from(this);
        for (int i = 0; i < dockApps.size(); i++) {
            final int index = i;
            final AppItem app = dockApps.get(i);
            android.util.Log.e("DOCK_DEBUG", "Dock index " + i + ": " + app.packageName + " / " + app.label);
            View tile = inflater.inflate(R.layout.item_app_tile, dockRow, false);

            ImageView ivBanner = tile.findViewById(R.id.ivBanner);
            ImageView ivIconFallback = tile.findViewById(R.id.ivIconFallback);
            TextView tvLabel = tile.findViewById(R.id.tvLabel);

            tvLabel.setText(app.label);
            tvLabel.setAlpha(0.0f);
            if (app.banner != null) {
                ivBanner.setImageDrawable(app.banner);
                ivIconFallback.setVisibility(View.GONE);
            } else {
                ivBanner.setVisibility(View.GONE);
                ivIconFallback.setVisibility(View.VISIBLE);
                ivIconFallback.setImageDrawable(app.icon);
            }

            tile.setSoundEffectsEnabled(false);
            tile.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    playSoundClick();
                    launchApp(app);
                }
            });

            tile.setOnFocusChangeListener(new View.OnFocusChangeListener() {
                @Override
                public void onFocusChange(View v, boolean hasFocus) {
                    android.util.Log.e("FOCUS_TEST", "Tile index " + index + " (" + app.label + ") hasFocus=" + hasFocus);
                    if (hasFocus) {
                        lastFocusedDockView = v;
                        lastFocusedView = v;
                        onTileFocused(v, app, true);
                    } else {
                        onTileUnfocused(v);
                    }
                }
            });

            // 100% Deterministic D-Pad navigation for dock
            tile.setOnKeyListener(new View.OnKeyListener() {
                @Override
                public boolean onKey(View v, int keyCode, KeyEvent event) {
                    if (event.getAction() != KeyEvent.ACTION_DOWN) return false;
                    long now = android.os.SystemClock.uptimeMillis();
                    if (now - lastNavTime < 140) return true;

                    if (keyCode == KeyEvent.KEYCODE_DPAD_RIGHT) {
                        if (index + 1 < dockTileViews.size()) {
                            lastNavTime = now;
                            final View target = dockTileViews.get(index + 1);
                            v.post(new Runnable() {
                                @Override
                                public void run() {
                                    target.requestFocus();
                                }
                            });
                            return true;
                        }
                        return true; // Stop at right edge
                    } else if (keyCode == KeyEvent.KEYCODE_DPAD_LEFT) {
                        if (index - 1 >= 0) {
                            lastNavTime = now;
                            final View target = dockTileViews.get(index - 1);
                            v.post(new Runnable() {
                                @Override
                                public void run() {
                                    target.requestFocus();
                                }
                            });
                            return true;
                        }
                        return true; // Stop at left edge
                    } else if (keyCode == KeyEvent.KEYCODE_DPAD_UP) {
                        lastNavTime = now;
                        v.post(new Runnable() {
                            @Override
                            public void run() {
                                btnInputs.requestFocus();
                            }
                        });
                        return true;
                    } else if (keyCode == KeyEvent.KEYCODE_DPAD_DOWN) {
                        if (!favoritesTileViews.isEmpty()) {
                            lastNavTime = now;
                            if (heroMetadataLayout != null) {
                                heroMetadataLayout.animate().cancel();
                                heroMetadataLayout.animate().alpha(0.0f).setDuration(100).start();
                            }
                            int targetCol = Math.min(index, favoritesTileViews.size() - 1);
                            final View target = (lastFocusedFavoritesView != null && favoritesScrollView != null && favoritesScrollView.getScrollX() > 100)
                                ? lastFocusedFavoritesView
                                : favoritesTileViews.get(targetCol);
                            v.post(new Runnable() {
                                @Override
                                public void run() {
                                    target.requestFocus();
                                    centerSeriesInScrollView(target);
                                }
                            });
                            return true;
                        } else if (!gridTileViews.isEmpty()) {
                            lastNavTime = now;
                            int targetCol = Math.min(index, Math.min(3, gridTileViews.size() - 1));
                            final View target = gridTileViews.get(targetCol);
                            v.post(new Runnable() {
                                @Override
                                public void run() {
                                    target.requestFocus();
                                }
                            });
                            return true;
                        }
                        return true;
                    }
                    return false;
                }
            });

            dockRow.addView(tile);
            dockTileViews.add(tile);
        }

        for (int i = 0; i < dockRow.getChildCount(); i++) {
            View child = dockRow.getChildAt(i);
            TextView tv = child.findViewById(R.id.tvLabel);
            android.util.Log.e("DOCK_DEBUG", "dockRow ChildAt " + i + ": label=" + (tv != null ? tv.getText() : "null"));
        }
    }

    private void initFavoriteSeries() {
        favoriteSeries.clear();
        favoriteSeries.add(new SeriesItem(
            "Seinfeld",
            "9 Seasons \u2022 Netflix",
            "NETFLIX",
            "com.netflix.ninja",
            "http://www.netflix.com/watch/70153373",
            R.drawable.series_seinfeld,
            Color.parseColor("#E50914")
        ));
        favoriteSeries.add(new SeriesItem(
            "The Big Bang Theory",
            "12 Seasons \u2022 Netflix",
            "NETFLIX",
            "com.netflix.ninja",
            "http://www.netflix.com/watch/70143830",
            R.drawable.series_bigbang,
            Color.parseColor("#E50914")
        ));
        favoriteSeries.add(new SeriesItem(
            "Friends",
            "10 Seasons \u2022 Netflix",
            "NETFLIX",
            "com.netflix.ninja",
            "http://www.netflix.com/watch/70153404",
            R.drawable.series_friends,
            Color.parseColor("#E50914")
        ));
        favoriteSeries.add(new SeriesItem(
            "Brooklyn Nine-Nine",
            "8 Seasons \u2022 Netflix",
            "NETFLIX",
            "com.netflix.ninja",
            "http://www.netflix.com/watch/70281561",
            R.drawable.series_b99,
            Color.parseColor("#E50914")
        ));
        favoriteSeries.add(new SeriesItem(
            "Modern Family",
            "11 Seasons \u2022 Hotstar",
            "HOTSTAR",
            "in.startv.hotstar",
            "hotstar://in/shows/modern-family/1260014022",
            R.drawable.series_modernfamily,
            Color.parseColor("#007AFF")
        ));
        favoriteSeries.add(new SeriesItem(
            "Game of Thrones",
            "8 Seasons \u2022 Hotstar",
            "HOTSTAR",
            "in.startv.hotstar",
            "hotstar://in/shows/game-of-thrones/1260007886",
            R.drawable.series_got,
            Color.parseColor("#1565C0")
        ));
    }

    private void buildFavoritesViews() {
        if (favoritesRow == null) return;
        favoritesRow.removeAllViews();
        favoritesTileViews.clear();

        LayoutInflater inflater = LayoutInflater.from(this);
        for (int i = 0; i < favoriteSeries.size(); i++) {
            final int index = i;
            final SeriesItem item = favoriteSeries.get(i);
            final View tile = inflater.inflate(R.layout.item_series_tile, favoritesRow, false);

            ImageView ivPoster = tile.findViewById(R.id.ivPoster);
            TextView tvBadge = tile.findViewById(R.id.tvBadge);
            TextView tvSeriesTitle = tile.findViewById(R.id.tvSeriesTitle);
            TextView tvSeriesSubtitle = tile.findViewById(R.id.tvSeriesSubtitle);

            if (ivPoster != null) {
                ivPoster.setImageResource(item.posterResId);
            }
            if (tvBadge != null) {
                tvBadge.setText(item.badge);
                if ("HOTSTAR".equalsIgnoreCase(item.badge)) {
                    tvBadge.setTextColor(Color.parseColor("#40C4FF"));
                } else {
                    tvBadge.setTextColor(Color.parseColor("#FF5252"));
                }
            }
            if (tvSeriesTitle != null) {
                tvSeriesTitle.setText(item.title);
            }
            if (tvSeriesSubtitle != null) {
                tvSeriesSubtitle.setText(item.subtitle);
            }

            tile.setSoundEffectsEnabled(false);
            tile.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    launchSeries(item);
                }
            });

            tile.setOnFocusChangeListener(new View.OnFocusChangeListener() {
                @Override
                public void onFocusChange(View v, boolean hasFocus) {
                    if (hasFocus) {
                        lastFocusedFavoritesView = v;
                        lastFocusedView = v;
                        onSeriesFocused(v, item);
                    } else {
                        onSeriesUnfocused(v);
                    }
                }
            });

            // D-Pad navigation for favorites row
            tile.setOnKeyListener(new View.OnKeyListener() {
                @Override
                public boolean onKey(View v, int keyCode, KeyEvent event) {
                    if (event.getAction() != KeyEvent.ACTION_DOWN) return false;
                    long now = android.os.SystemClock.uptimeMillis();
                    if (now - lastNavTime < 140) return true;

                    if (keyCode == KeyEvent.KEYCODE_DPAD_RIGHT) {
                        if (index + 1 < favoritesTileViews.size()) {
                            lastNavTime = now;
                            final View target = favoritesTileViews.get(index + 1);
                            v.post(new Runnable() {
                                @Override
                                public void run() {
                                    target.requestFocus();
                                    centerSeriesInScrollView(target);
                                }
                            });
                            return true;
                        }
                        return true; // Stop at right edge
                    } else if (keyCode == KeyEvent.KEYCODE_DPAD_LEFT) {
                        if (index - 1 >= 0) {
                            lastNavTime = now;
                            final View target = favoritesTileViews.get(index - 1);
                            v.post(new Runnable() {
                                @Override
                                public void run() {
                                    target.requestFocus();
                                    centerSeriesInScrollView(target);
                                }
                            });
                            return true;
                        }
                        return true; // Stop at left edge
                    } else if (keyCode == KeyEvent.KEYCODE_DPAD_UP) {
                        lastNavTime = now;
                        // Hide hero metadata immediately so it NEVER overlaps or glitches over the dock
                        if (heroMetadataLayout != null) {
                            heroMetadataLayout.animate().cancel();
                            heroMetadataLayout.setAlpha(0.0f);
                        }
                        if (mainScrollView != null) {
                            mainScrollView.smoothScrollTo(0, 0);
                        }
                        // Return to dock
                        int dockCol = Math.min(index, dockTileViews.size() - 1);
                        final View target = (dockTileViews.size() > dockCol) ? dockTileViews.get(dockCol) : (lastFocusedDockView != null ? lastFocusedDockView : (dockTileViews.isEmpty() ? null : dockTileViews.get(0)));
                        if (target != null) {
                            v.post(new Runnable() {
                                @Override
                                public void run() {
                                    target.requestFocus();
                                }
                            });
                        }
                        return true;
                    } else if (keyCode == KeyEvent.KEYCODE_DPAD_DOWN) {
                        lastNavTime = now;
                        // Move to all apps grid
                        if (!gridTileViews.isEmpty()) {
                            int targetCol = Math.min(index, Math.min(3, gridTileViews.size() - 1));
                            final View target = gridTileViews.get(targetCol);
                            v.post(new Runnable() {
                                @Override
                                public void run() {
                                    target.requestFocus();
                                }
                            });
                        }
                        return true;
                    }
                    return false;
                }
            });

            favoritesRow.addView(tile);
            favoritesTileViews.add(tile);
        }
    }

    private void centerSeriesInScrollView(final View target) {
        if (favoritesScrollView == null || target == null) return;
        target.post(new Runnable() {
            @Override
            public void run() {
                int screenWidth = getResources().getDisplayMetrics().widthPixels;
                int targetCenter = target.getLeft() + (target.getWidth() / 2);
                int scrollX = targetCenter - (screenWidth / 2);
                favoritesScrollView.smoothScrollTo(Math.max(0, scrollX), 0);
            }
        });
    }

    private void onSeriesFocused(View tile, SeriesItem item) {
        if (isUserNavigating) {
            playSoundNavigate();
        }

        View card = tile.findViewById(R.id.cardContainer);
        if (card != null) {
            card.setPivotX(card.getWidth() / 2f);
            card.setPivotY(card.getHeight() / 2f);
            card.animate()
                .scaleX(1.10f)
                .scaleY(1.10f)
                .setDuration(180)
                .setInterpolator(new OvershootInterpolator(1.2f))
                .withLayer()
                .start();
            try {
                card.setElevation(20f);
            } catch (Throwable ignored) {}
        }

        View ring = tile.findViewById(R.id.vFocusRing);
        if (ring != null) {
            ring.animate().alpha(1.0f).setDuration(160).withLayer().start();
        }

        int favIndex = favoritesTileViews.indexOf(tile);
        if (favIndex >= 0) {
            applyParallaxForFavoritesIndex(favIndex, favoritesTileViews.size());
        }

        if (inputsDropdown != null && inputsDropdown.getVisibility() == View.VISIBLE) {
            inputsDropdown.setVisibility(View.GONE);
        }
        topBar.animate().alpha(0.0f).translationY(-50f).setDuration(180).withLayer().start();
        if (heroMetadataLayout != null) {
            heroMetadataLayout.animate().alpha(0.0f).setDuration(160).withLayer().start();
        } else if (tvFocusedTitle != null) {
            tvFocusedTitle.animate().alpha(0.0f).setDuration(160).withLayer().start();
        }

        // Show hero background on ALL themes!
        if (item.posterResId != currentHeroRes) {
            transitionHeroBackdrop(item.posterResId);
        } else if (ivHeroBackdrop != null) {
            ivHeroBackdrop.setVisibility(View.VISIBLE);
            ivHeroBackdrop.animate()
                .alpha(1.0f)
                .translationX(currentParallaxX)
                .setDuration(240)
                .setInterpolator(new DecelerateInterpolator())
                .withLayer()
                .start();
        }

        setAmbientGlow(item.accentColor);
    }

    private void onSeriesUnfocused(View tile) {
        View card = tile.findViewById(R.id.cardContainer);
        if (card != null) {
            card.animate()
                .scaleX(1.0f)
                .scaleY(1.0f)
                .setDuration(150)
                .setInterpolator(new DecelerateInterpolator())
                .withLayer()
                .start();
            try {
                card.setElevation(0f);
            } catch (Throwable ignored) {}
        }

        View ring = tile.findViewById(R.id.vFocusRing);
        if (ring != null) {
            ring.animate().alpha(0.0f).setDuration(140).withLayer().start();
        }
    }

    private void launchSeries(final SeriesItem item) {
        if (item == null) return;
        animateAppLaunch(getCurrentFocus(), new Runnable() {
            @Override
            public void run() {
                executeLaunchSeries(item);
            }
        }, item.accentColor);
    }

    private void launchSeriesDirect(SeriesItem item) {
        playSoundClick();
        try {
            if ("com.netflix.ninja".equals(item.packageName)) {
                // Direct Playback for Netflix on Android TV
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(Uri.parse(item.deepLinkUri));
                intent.putExtra("source", "30"); // Crucial extra: triggers immediate Leanback playback without returning to browse!
                intent.setPackage("com.netflix.ninja");
                intent.addCategory(Intent.CATEGORY_LEANBACK_LAUNCHER);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                startActivity(intent);
                return;
            } else if ("in.startv.hotstar".equals(item.packageName)) {
                // Direct Playback / Show launch for Hotstar on Android TV
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(Uri.parse(item.deepLinkUri));
                intent.setPackage("in.startv.hotstar");
                intent.addCategory(Intent.CATEGORY_DEFAULT);
                intent.addCategory(Intent.CATEGORY_BROWSABLE);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
                startActivity(intent);
                return;
            } else {
                Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(item.deepLinkUri));
                intent.setPackage(item.packageName);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
                return;
            }
        } catch (Exception e) {
            try {
                Intent fallback = getPackageManager().getLeanbackLaunchIntentForPackage(item.packageName);
                if (fallback == null) fallback = getPackageManager().getLaunchIntentForPackage(item.packageName);
                if (fallback != null) {
                    fallback.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    startActivity(fallback);
                }
            } catch (Exception ignored) {}
        }
    }

    private void bindTile(View tile, final AppItem app) {
        tile.setTag(app);
        ImageView ivBanner = tile.findViewById(R.id.ivBanner);
        ImageView ivIconFallback = tile.findViewById(R.id.ivIconFallback);
        ImageView ivIconUnfocused = tile.findViewById(R.id.ivIconUnfocused);
        ImageView ivIconFocused = tile.findViewById(R.id.ivIconFocused);
        TextView tvLabel = tile.findViewById(R.id.tvLabel);

        if (tvLabel != null) {
            tvLabel.setText(app.label);
            tvLabel.setVisibility(View.GONE);
        }

        boolean hasFocus = tile.hasFocus();
        GlassioIconPair pair = GLASSIO_ICONS.get(app.packageName);
        if (pair != null) {
            if (ivIconUnfocused != null) {
                ivIconUnfocused.setImageResource(pair.unfocusedResId);
                ivIconUnfocused.setVisibility(View.VISIBLE);
                ivIconUnfocused.setAlpha(hasFocus ? 0.0f : 1.0f);
            }
            if (ivIconFocused != null) {
                ivIconFocused.setImageResource(pair.focusedResId);
                ivIconFocused.setVisibility(View.VISIBLE);
                ivIconFocused.setAlpha(hasFocus ? 1.0f : 0.0f);
            }
            if (ivBanner != null) ivBanner.setVisibility(View.GONE);
            if (ivIconFallback != null) ivIconFallback.setVisibility(View.GONE);
        } else {
            if (ivIconUnfocused != null) ivIconUnfocused.setVisibility(View.GONE);
            if (ivIconFocused != null) ivIconFocused.setVisibility(View.GONE);
            if (app.banner != null) {
                if (ivBanner != null) {
                    ivBanner.setImageDrawable(app.banner);
                    ivBanner.setVisibility(View.VISIBLE);
                }
                if (ivIconFallback != null) ivIconFallback.setVisibility(View.GONE);
            } else {
                if (ivBanner != null) ivBanner.setVisibility(View.GONE);
                if (ivIconFallback != null) {
                    ivIconFallback.setImageDrawable(app.icon);
                    ivIconFallback.setVisibility(View.VISIBLE);
                }
            }
        }
    }

    private void saveGridAppOrder() {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < gridApps.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append(gridApps.get(i).packageName);
        }
        getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_GRID_ORDER, sb.toString())
            .apply();
    }

    private void buildGridViews() {
        if (appsGrid == null) return;
        appsGrid.removeAllViews();
        gridTileViews.clear();

        LayoutInflater inflater = LayoutInflater.from(this);
        for (int i = 0; i < gridApps.size(); i++) {
            final AppItem app = gridApps.get(i);
            final View tile = inflater.inflate(R.layout.item_app_tile, appsGrid, false);
            bindTile(tile, app);

            TextView tvLabel = tile.findViewById(R.id.tvLabel);
            tvLabel.setAlpha(0.0f);

            tile.setSoundEffectsEnabled(false);
            tile.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    playSoundClick();
                    if (isReorderMode) {
                        exitReorderMode();
                    } else {
                        AppItem clicked = (AppItem) v.getTag();
                        if (clicked != null) launchApp(clicked);
                    }
                }
            });

            tile.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    playSoundClick();
                    int idx = gridTileViews.indexOf(v);
                    if (idx >= 0) {
                        enterReorderMode(idx);
                        return true;
                    }
                    return false;
                }
            });

            tile.setOnFocusChangeListener(new View.OnFocusChangeListener() {
                @Override
                public void onFocusChange(View v, boolean hasFocus) {
                    AppItem current = (AppItem) v.getTag();
                    if (hasFocus) {
                        lastFocusedView = v;
                        if (current != null) {
                            onTileFocused(v, current, false);
                        }
                    } else {
                        onTileUnfocused(v);
                    }
                }
            });

            // 100% Deterministic 4-column navigation & Reordering
            tile.setOnKeyListener(new View.OnKeyListener() {
                @Override
                public boolean onKey(View v, int keyCode, KeyEvent event) {
                    if (event.getAction() != KeyEvent.ACTION_DOWN) return false;
                    long now = android.os.SystemClock.uptimeMillis();
                    if (now - lastNavTime < 140) return true;

                    int index = gridTileViews.indexOf(v);
                    if (index < 0) return false;

                    // Toggle reorder mode on Remote Menu/Options button
                    if (keyCode == KeyEvent.KEYCODE_MENU) {
                        if (!isReorderMode) {
                            enterReorderMode(index);
                        } else {
                            exitReorderMode();
                        }
                        return true;
                    }

                    // Handle Reorder Mode Keys
                    if (isReorderMode) {
                        if (keyCode == KeyEvent.KEYCODE_DPAD_CENTER || keyCode == KeyEvent.KEYCODE_ENTER) {
                            exitReorderMode();
                            return true;
                        }
                        if (keyCode == KeyEvent.KEYCODE_BACK) {
                            exitReorderMode();
                            return true;
                        }
                        if (keyCode == KeyEvent.KEYCODE_DPAD_RIGHT) {
                            int col = index % 4;
                            if (col < 3 && index + 1 < gridApps.size()) {
                                lastNavTime = now;
                                moveGridItem(index, index + 1);
                                return true;
                            }
                            return true;
                        } else if (keyCode == KeyEvent.KEYCODE_DPAD_LEFT) {
                            int col = index % 4;
                            if (col > 0 && index - 1 >= 0) {
                                lastNavTime = now;
                                moveGridItem(index, index - 1);
                                return true;
                            }
                            return true;
                        } else if (keyCode == KeyEvent.KEYCODE_DPAD_UP) {
                            if (index - 4 >= 0) {
                                lastNavTime = now;
                                moveGridItem(index, index - 4);
                                return true;
                            }
                            return true; // Block escaping to dock while reordering
                        } else if (keyCode == KeyEvent.KEYCODE_DPAD_DOWN) {
                            if (index + 4 < gridApps.size()) {
                                lastNavTime = now;
                                moveGridItem(index, index + 4);
                                return true;
                            }
                            return true;
                        }
                        return false;
                    }

                    // Normal (Non-Reorder) Navigation:
                    int row = index / 4;
                    int col = index % 4;

                    if (keyCode == KeyEvent.KEYCODE_DPAD_RIGHT) {
                        if (col < 3 && index + 1 < gridTileViews.size()) {
                            lastNavTime = now;
                            final View target = gridTileViews.get(index + 1);
                            v.post(new Runnable() {
                                @Override
                                public void run() {
                                    target.requestFocus();
                                }
                            });
                            return true;
                        }
                        return true; // Stop at right edge
                    } else if (keyCode == KeyEvent.KEYCODE_DPAD_LEFT) {
                        if (col > 0 && index - 1 >= 0) {
                            lastNavTime = now;
                            final View target = gridTileViews.get(index - 1);
                            v.post(new Runnable() {
                                @Override
                                public void run() {
                                    target.requestFocus();
                                }
                            });
                            return true;
                        }
                        return true; // Stop at left edge
                    } else if (keyCode == KeyEvent.KEYCODE_DPAD_UP) {
                        lastNavTime = now;
                        if (row == 0) {
                            if (!favoritesTileViews.isEmpty()) {
                                int favTarget = Math.min(col, favoritesTileViews.size() - 1);
                                final View ft = (lastFocusedFavoritesView != null) ? lastFocusedFavoritesView : favoritesTileViews.get(favTarget);
                                v.post(new Runnable() {
                                    @Override
                                    public void run() {
                                        ft.requestFocus();
                                        centerSeriesInScrollView(ft);
                                    }
                                });
                                return true;
                            } else {
                                mainScrollView.scrollTo(0, 0);
                                int dockTarget = Math.min(col, dockTileViews.size() - 1);
                                if (dockTarget >= 0) {
                                    final View dt = dockTileViews.get(dockTarget);
                                    v.post(new Runnable() {
                                        @Override
                                        public void run() {
                                            dt.requestFocus();
                                        }
                                    });
                                    return true;
                                }
                            }
                        } else {
                            int targetIdx = index - 4;
                            if (targetIdx >= 0) {
                                final View target = gridTileViews.get(targetIdx);
                                v.post(new Runnable() {
                                    @Override
                                    public void run() {
                                        target.requestFocus();
                                    }
                                });
                                return true;
                            }
                        }
                        return true;
                    } else if (keyCode == KeyEvent.KEYCODE_DPAD_DOWN) {
                        int targetIdx = index + 4;
                        if (targetIdx < gridTileViews.size()) {
                            lastNavTime = now;
                            final View target = gridTileViews.get(targetIdx);
                            v.post(new Runnable() {
                                @Override
                                public void run() {
                                    target.requestFocus();
                                }
                            });
                            return true;
                        }
                        return true; // Stop at bottom of grid
                    }
                    return false;
                }
            });

            appsGrid.addView(tile);
            gridTileViews.add(tile);
        }
    }

    private void enterReorderMode(int index) {
        if (index < 0 || index >= gridTileViews.size()) return;
        isReorderMode = true;
        reorderActiveIndex = index;

        final View tile = gridTileViews.get(index);
        applyReorderVisuals(tile);

        // Slide out top bar cleanly to give HUD pill dedicated focus
        topBar.animate().alpha(0.0f).translationY(-50f).setDuration(160).start();
        if (heroMetadataLayout != null) {
            heroMetadataLayout.animate().alpha(0.0f).setDuration(140).start();
        } else if (tvFocusedTitle != null) {
            tvFocusedTitle.animate().alpha(0.0f).setDuration(140).start();
        }
        if (isHeroTheme() && ivHeroBackdrop != null && ivHeroBackdrop.getAlpha() > 0.2f) {
            ivHeroBackdrop.animate().alpha(0.18f).setDuration(160).start();
        }

        AppItem activeApp = gridApps.get(index);
        if (tvReorderPrompt != null) {
            tvReorderPrompt.setText("Moving " + activeApp.label + "  \u2022  Use D-Pad  \u2022  OK Done");
        }

        if (hudReorder != null) {
            hudReorder.setVisibility(View.VISIBLE);
            hudReorder.setAlpha(0f);
            hudReorder.animate().alpha(1f).setDuration(200).start();
        }
    }

    private void applyReorderVisuals(View tile) {
        if (currentWobbleAnimator != null) {
            currentWobbleAnimator.cancel();
            if (currentWobbleTile != null) {
                View prevCard = currentWobbleTile.findViewById(R.id.cardContainer);
                if (prevCard != null) {
                    prevCard.setRotation(0f);
                    prevCard.setScaleX(1.0f);
                    prevCard.setScaleY(1.0f);
                }
            }
        }

        currentWobbleTile = tile;
        View card = tile.findViewById(R.id.cardContainer);
        if (card != null) {
            card.setScaleX(1.10f);
            card.setScaleY(1.10f);

            currentWobbleAnimator = ObjectAnimator.ofFloat(card, "rotation", -2.0f, 2.0f);
            currentWobbleAnimator.setDuration(120);
            currentWobbleAnimator.setRepeatCount(ValueAnimator.INFINITE);
            currentWobbleAnimator.setRepeatMode(ValueAnimator.REVERSE);
            currentWobbleAnimator.setInterpolator(new AccelerateDecelerateInterpolator());
            currentWobbleAnimator.start();
        }
    }

    private void moveGridItem(final int fromIdx, final int toIdx) {
        if (fromIdx < 0 || fromIdx >= gridApps.size()) return;
        if (toIdx < 0 || toIdx >= gridApps.size()) return;
        if (fromIdx == toIdx) return;

        // 1. Swap data list
        Collections.swap(gridApps, fromIdx, toIdx);

        // 2. Re-bind the two views
        final View fromView = gridTileViews.get(fromIdx);
        final View toView = gridTileViews.get(toIdx);
        bindTile(fromView, gridApps.get(fromIdx));
        bindTile(toView, gridApps.get(toIdx));

        // 3. Reset visual on fromView
        View prevCard = fromView.findViewById(R.id.cardContainer);
        if (prevCard != null) {
            prevCard.setRotation(0f);
            prevCard.setScaleX(1.0f);
            prevCard.setScaleY(1.0f);
        }
        TextView prevTv = fromView.findViewById(R.id.tvLabel);
        if (prevTv != null) {
            prevTv.setAlpha(0.0f);
        }

        // 4. Update reorderActiveIndex and move focus to toView
        reorderActiveIndex = toIdx;
        toView.requestFocus();
        applyReorderVisuals(toView);

        AppItem activeApp = gridApps.get(toIdx);
        if (tvReorderPrompt != null) {
            tvReorderPrompt.setText("Moving " + activeApp.label + "  \u2022  Use D-Pad  \u2022  OK Done");
        }

        saveGridAppOrder();
    }

    private void exitReorderMode() {
        if (!isReorderMode) return;
        isReorderMode = false;
        reorderActiveIndex = -1;

        if (currentWobbleAnimator != null) {
            currentWobbleAnimator.cancel();
            currentWobbleAnimator = null;
        }
        if (currentWobbleTile != null) {
            View card = currentWobbleTile.findViewById(R.id.cardContainer);
            if (card != null) {
                card.animate().rotation(0f).scaleX(1.08f).scaleY(1.08f).setDuration(120).start();
            }
            currentWobbleTile = null;
        }

        if (hudReorder != null) {
            hudReorder.animate().alpha(0f).setDuration(150).withEndAction(new Runnable() {
                @Override
                public void run() {
                    hudReorder.setVisibility(View.GONE);
                }
            }).start();
        }

        if (mainScrollView.getScrollY() <= 50) {
            topBar.animate().alpha(1.0f).translationY(0f).setDuration(180).start();
            if (isHeroTheme() && dockTileViews.contains(lastFocusedView) && ivHeroBackdrop != null) {
                ivHeroBackdrop.animate().alpha(1.0f).setDuration(200).start();
            }
        }

        saveGridAppOrder();
    }

    private void onTileFocused(View tile, final AppItem app, boolean isDock) {
        if (isUserNavigating) {
            playSoundNavigate();
        }

        // 1. Smooth Spring Scale strictly on the rounded cardContainer (not the whole tile)
        View card = tile.findViewById(R.id.cardContainer);
        if (card != null) {
            card.setPivotX(card.getWidth() / 2f);
            card.setPivotY(card.getHeight() / 2f);
            card.animate()
                .scaleX(1.08f)
                .scaleY(1.08f)
                .setDuration(180)
                .setInterpolator(new OvershootInterpolator(1.15f))
                .start();
        }

        // Reveal tile name underneath
        TextView tvLabel = tile.findViewById(R.id.tvLabel);
        if (tvLabel != null) {
            tvLabel.animate().alpha(1.0f).setDuration(180).start();
        }

        // Hide overlay highlight to keep cards clean
        if (glassHighlight != null) {
            glassHighlight.setVisibility(View.GONE);
        }

        // 3. Update Title, Header Visibility, Top Shelf Hero & Ambient Glow
        if (isDock) {
            int dockIdx = dockTileViews.indexOf(tile);
            if (dockIdx >= 0) {
                applyParallaxForDockIndex(dockIdx, dockApps.size());
            }

            topBar.animate().alpha(1.0f).translationY(0f).setDuration(220).start();

            final String tagline = APP_TAGLINES.get(app.packageName);
            final String currentTitle = tvFocusedTitle.getText() != null ? tvFocusedTitle.getText().toString() : "";
            final String newTagline = (tagline != null) ? tagline : "";

            if (!app.label.equals(currentTitle)) {
                if (heroMetadataLayout != null) {
                    heroMetadataLayout.animate().cancel();
                    heroMetadataLayout.animate().alpha(0.0f).translationX(-16f).setDuration(90).withLayer().withEndAction(new Runnable() {
                        @Override
                        public void run() {
                            tvFocusedTitle.setText(app.label);
                            if (tvHeroTagline != null) {
                                if (!newTagline.isEmpty()) {
                                    tvHeroTagline.setText(newTagline);
                                    tvHeroTagline.setVisibility(View.VISIBLE);
                                } else {
                                    tvHeroTagline.setVisibility(View.GONE);
                                }
                            }
                            heroMetadataLayout.setTranslationX(16f);
                            if (mainScrollView != null && mainScrollView.getScrollY() <= 10) {
                                heroMetadataLayout.animate().alpha(1.0f).translationX(0f).setDuration(160).withLayer().start();
                            } else {
                                heroMetadataLayout.setAlpha(0.0f);
                            }
                        }
                    }).start();
                } else {
                    tvFocusedTitle.setText(app.label);
                }
            } else {
                if (heroMetadataLayout != null) {
                    heroMetadataLayout.animate().cancel();
                    if (mainScrollView != null && mainScrollView.getScrollY() <= 10) {
                        heroMetadataLayout.animate().alpha(1.0f).translationX(0f).setDuration(140).withLayer().start();
                    } else {
                        heroMetadataLayout.setAlpha(0.0f);
                    }
                }
            }

            // Optional Dynamic Hero Backdrops
            if (isHeroTheme()) {
                Integer heroRes = HERO_DRAWABLES.get(app.packageName);
                if (heroRes != null) {
                    if (heroRes != currentHeroRes) {
                        transitionHeroBackdrop(heroRes);
                    } else if (ivHeroBackdrop != null) {
                        ivHeroBackdrop.animate()
                            .alpha(1.0f)
                            .translationX(currentParallaxX)
                            .setDuration(240)
                            .setInterpolator(new DecelerateInterpolator())
                            .withLayer()
                            .start();
                    }
                }
            } else {
                restoreOriginalWallpaperForDock();
            }
        } else {
            resetParallax();
            if (inputsDropdown != null && inputsDropdown.getVisibility() == View.VISIBLE) {
                inputsDropdown.setVisibility(View.GONE);
            }
            topBar.animate().alpha(0.0f).translationY(-50f).setDuration(180).start();
            if (heroMetadataLayout != null) {
                heroMetadataLayout.animate().alpha(0.0f).setDuration(160).start();
            } else if (tvFocusedTitle != null) {
                tvFocusedTitle.animate().alpha(0.0f).setDuration(160).start();
            }
            if (isHeroTheme()) {
                if (ivHeroBackdrop != null && ivHeroBackdrop.getAlpha() > 0.2f) {
                    ivHeroBackdrop.animate().alpha(0.18f).setDuration(180).start();
                }
            } else {
                restoreOriginalWallpaperForDock();
            }
        }
        setAmbientGlow(app.accentColor);
    }

    private void onTileUnfocused(View tile) {
        View card = tile.findViewById(R.id.cardContainer);
        if (card != null) {
            card.animate()
                .scaleX(1.0f)
                .scaleY(1.0f)
                .setDuration(150)
                .setInterpolator(new DecelerateInterpolator())
                .start();
        }
        ImageView ivFocused = tile.findViewById(R.id.ivIconFocused);
        ImageView ivUnfocused = tile.findViewById(R.id.ivIconUnfocused);
        if (ivFocused != null) ivFocused.animate().alpha(0.0f).setDuration(150).start();
        if (ivUnfocused != null) ivUnfocused.animate().alpha(1.0f).setDuration(150).start();

        // Dim tile name underneath
        TextView tvLabel = tile.findViewById(R.id.tvLabel);
        if (tvLabel != null) {
            tvLabel.animate().alpha(0.0f).setDuration(150).start();
        }
    }

    private void animateGlassHighlightTo(final View tile) {
        if (glassHighlight != null) {
            glassHighlight.setVisibility(View.GONE);
        }
    }

    private void applyParallaxForDockIndex(int index, int totalCount) {
        if (totalCount <= 1) return;
        // Normalized index across dock: -1.0 (left) to +1.0 (right)
        float normalized = ((float) index / (totalCount - 1)) * 2.0f - 1.0f;
        // Optical counter-pan: moving focus right shifts background left (-18dp to +18dp)
        float targetTranslationDp = -normalized * 18.0f;
        float targetPx = targetTranslationDp * getResources().getDisplayMetrics().density;
        currentParallaxX = targetPx;

        if (ivWallpaper != null && ivWallpaper.getVisibility() == View.VISIBLE) {
            ivWallpaper.animate()
                .translationX(targetPx * 0.7f)
                .setDuration(260)
                .setInterpolator(new DecelerateInterpolator())
                .withLayer()
                .start();
        }
        if (ambientGlowView != null) {
            ambientGlowView.animate()
                .translationX(targetPx * 0.5f)
                .setDuration(260)
                .setInterpolator(new DecelerateInterpolator())
                .start();
        }
    }

    private void applyParallaxForFavoritesIndex(int index, int totalCount) {
        if (totalCount <= 1) return;
        // Normalized index across favorites: -1.0 (left) to +1.0 (right)
        float normalized = ((float) index / (totalCount - 1)) * 2.0f - 1.0f;
        // Optical counter-pan: moving focus right shifts background left (-20dp to +20dp)
        float targetTranslationDp = -normalized * 20.0f;
        float targetPx = targetTranslationDp * getResources().getDisplayMetrics().density;
        currentParallaxX = targetPx;

        if (ivHeroBackdrop != null && ivHeroBackdrop.getVisibility() == View.VISIBLE) {
            ivHeroBackdrop.animate()
                .translationX(targetPx)
                .setDuration(240)
                .setInterpolator(new DecelerateInterpolator())
                .withLayer()
                .start();
        }
        if (ambientGlowView != null) {
            ambientGlowView.animate()
                .translationX(targetPx * 0.5f)
                .setDuration(260)
                .setInterpolator(new DecelerateInterpolator())
                .start();
        }
    }

    private void resetParallax() {
        if (currentParallaxX == 0f) return;
        currentParallaxX = 0f;
        if (ivHeroBackdrop != null) {
            ivHeroBackdrop.animate().translationX(0f).setDuration(240).withLayer().start();
        }
        if (ivHeroBackdropBack != null) {
            ivHeroBackdropBack.animate().translationX(0f).setDuration(240).withLayer().start();
        }
        if (ivWallpaper != null) {
            ivWallpaper.animate().translationX(0f).setDuration(240).withLayer().start();
        }
        if (ambientGlowView != null) {
            ambientGlowView.animate().translationX(0f).setDuration(240).start();
        }
    }

    private int currentGlowColor = 0;

    private void setAmbientGlow(final int color) {
        if (!isAmbientGlowEnabled) {
            currentGlowColor = color;
            if (ambientGlowView != null) {
                ambientGlowView.animate().cancel();
                ambientGlowView.setAlpha(0.0f);
            }
            if (ambientGlowViewBack != null) {
                ambientGlowViewBack.animate().cancel();
                ambientGlowViewBack.setAlpha(0.0f);
            }
            return;
        }
        if (currentGlowColor == color) return;
        currentGlowColor = color;

        final GradientDrawable newGradient = createAmbientGradient(color);

        if (ambientGlowViewBack == null) {
            if (ambientGlowView != null) {
                ambientGlowView.setBackground(newGradient);
                ambientGlowView.setAlpha(1.0f);
            }
            return;
        }

        ambientGlowView.animate().cancel();
        ambientGlowViewBack.animate().cancel();

        // Animate buttery smooth crossfade across full background
        ambientGlowViewBack.setBackground(newGradient);
        ambientGlowViewBack.setAlpha(1.0f);

        ambientGlowView.animate()
            .alpha(0.0f)
            .setDuration(220)
            .withLayer()
            .withEndAction(new Runnable() {
                @Override
                public void run() {
                    if (ambientGlowView != null && ambientGlowViewBack != null) {
                        ambientGlowView.setBackground(newGradient);
                        ambientGlowView.setAlpha(1.0f);
                        ambientGlowViewBack.setAlpha(0.0f);
                    }
                }
            })
            .start();
    }

    private GradientDrawable createAmbientGradient(int color) {
        int r = Color.red(color);
        int g = Color.green(color);
        int b = Color.blue(color);

        GradientDrawable gradient = new GradientDrawable();
        gradient.setShape(GradientDrawable.RECTANGLE);
        gradient.setGradientType(GradientDrawable.RADIAL_GRADIENT);
        gradient.setGradientCenter(0.5f, 0.35f);
        gradient.setGradientRadius(1400f);

        // Luminous Apple TV atmospheric wash across wallpaper
        int stop0 = Color.argb(130, r, g, b); // Center / hero area
        int stop1 = Color.argb(75, r, g, b);  // Inner mid
        int stop2 = Color.argb(25, r, g, b);  // Outer mid
        int stop3 = Color.argb(0, r, g, b);   // Edge / corners

        gradient.setColors(new int[]{ stop0, stop1, stop2, stop3 });
        return gradient;
    }

    private void launchApp(final AppItem app) {
        if (app == null) return;
        int glow = BRAND_COLORS.containsKey(app.packageName) ? BRAND_COLORS.get(app.packageName) : app.accentColor;
        animateAppLaunch(getCurrentFocus(), new Runnable() {
            @Override
            public void run() {
                executeLaunchApp(app);
            }
        }, glow);
    }

    private void centerDockInScrollView(View view) {
        if (dockScrollView == null || view == null) return;
        int scrollX = (view.getLeft() + view.getRight()) / 2 - dockScrollView.getWidth() / 2;
        dockScrollView.smoothScrollTo(Math.max(0, scrollX), 0);
    }

    private void saveDockAppOrder() {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < dockApps.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append(dockApps.get(i).packageName);
        }
        getSharedPreferences(PREF_NAME, MODE_PRIVATE)
            .edit()
            .putString("dock_order", sb.toString())
            .apply();
    }

    private void moveDockItem(int fromIndex, int toIndex) {
        if (fromIndex < 0 || fromIndex >= dockApps.size() || toIndex < 0 || toIndex >= dockApps.size() || fromIndex == toIndex) return;
        AppItem item = dockApps.remove(fromIndex);
        dockApps.add(toIndex, item);
        buildDockViews();
        reorderActiveIndex = toIndex;
        if (toIndex >= 0 && toIndex < dockTileViews.size()) {
            View target = dockTileViews.get(toIndex);
            target.requestFocus();
            centerDockInScrollView(target);
            applyReorderVisuals(target);
            if (tvReorderPrompt != null) {
                tvReorderPrompt.setText("Moving " + item.label + "  •  Use Left/Right D-Pad  •  OK Done");
            }
        }
        saveDockAppOrder();
    }

    private boolean isDpadKey(int keyCode) {
        return keyCode == KeyEvent.KEYCODE_DPAD_UP 
            || keyCode == KeyEvent.KEYCODE_DPAD_DOWN 
            || keyCode == KeyEvent.KEYCODE_DPAD_LEFT 
            || keyCode == KeyEvent.KEYCODE_DPAD_RIGHT;
    }

    private void animateAppLaunch(final View tileView, final Runnable onComplete, int glowColor) {
        playSoundClick();
        if (tileView == null || launchZoomContainer == null || ivLaunchZoomIcon == null) {
            if (onComplete != null) onComplete.run();
            return;
        }

        View card = tileView.findViewById(R.id.cardContainer);
        if (card == null) card = tileView;

        int[] tilePos = new int[2];
        card.getLocationOnScreen(tilePos);
        int[] containerPos = new int[2];
        launchZoomContainer.getLocationOnScreen(containerPos);

        int startX = tilePos[0] - containerPos[0];
        int startY = tilePos[1] - containerPos[1];
        int cardW = card.getWidth();
        int cardH = card.getHeight();

        ImageView ivFocused = tileView.findViewById(R.id.ivIconFocused);
        ImageView ivUnfocused = tileView.findViewById(R.id.ivIconUnfocused);
        ImageView ivBanner = tileView.findViewById(R.id.ivBanner);
        ImageView ivFallback = tileView.findViewById(R.id.ivIconFallback);
        Drawable iconDrawable = null;

        if (ivFocused != null && ivFocused.getVisibility() == View.VISIBLE && ivFocused.getAlpha() > 0.5f) {
            iconDrawable = ivFocused.getDrawable();
        } else if (ivUnfocused != null && ivUnfocused.getVisibility() == View.VISIBLE) {
            iconDrawable = ivUnfocused.getDrawable();
        } else if (ivBanner != null && ivBanner.getVisibility() == View.VISIBLE) {
            iconDrawable = ivBanner.getDrawable();
        } else if (ivFallback != null && ivFallback.getVisibility() == View.VISIBLE) {
            iconDrawable = ivFallback.getDrawable();
        }

        if (iconDrawable != null) {
            ivLaunchZoomIcon.setImageDrawable(iconDrawable);
        }

        FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams) ivLaunchZoomIcon.getLayoutParams();
        if (lp != null) {
            lp.width = cardW;
            lp.height = cardH;
            lp.leftMargin = startX;
            lp.topMargin = startY;
            ivLaunchZoomIcon.setLayoutParams(lp);
        }

        if (vLaunchGlow != null) {
            GradientDrawable glow = new GradientDrawable();
            glow.setShape(GradientDrawable.OVAL);
            glow.setGradientType(GradientDrawable.RADIAL_GRADIENT);
            glow.setGradientRadius(Math.max(cardW, cardH) * 1.5f);
            glow.setColors(new int[]{ Color.argb(180, Color.red(glowColor), Color.green(glowColor), Color.blue(glowColor)), Color.TRANSPARENT });
            vLaunchGlow.setBackground(glow);
            vLaunchGlow.setAlpha(0.0f);
        }

        launchZoomContainer.setVisibility(View.VISIBLE);
        ivLaunchZoomIcon.setScaleX(1.0f);
        ivLaunchZoomIcon.setScaleY(1.0f);
        ivLaunchZoomIcon.setAlpha(1.0f);

        ivLaunchZoomIcon.animate()
            .scaleX(1.4f)
            .scaleY(1.4f)
            .alpha(0.0f)
            .setDuration(450)
            .setInterpolator(new AccelerateInterpolator())
            .start();

        if (vLaunchGlow != null) {
            vLaunchGlow.animate()
                .alpha(1.0f)
                .setDuration(300)
                .withEndAction(new Runnable() {
                    @Override
                    public void run() {
                        if (vLaunchGlow != null) vLaunchGlow.animate().alpha(0.0f).setDuration(200).start();
                    }
                })
                .start();
        }

        if (mainScrollView != null) {
            mainScrollView.animate().alpha(0.0f).setDuration(350).start();
        }
        if (topBar != null) {
            topBar.animate().alpha(0.0f).setDuration(350).start();
        }

        keyHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                if (launchZoomContainer != null) launchZoomContainer.setVisibility(View.GONE);
                if (mainScrollView != null) mainScrollView.setAlpha(1.0f);
                if (topBar != null) topBar.setAlpha(1.0f);
                if (onComplete != null) onComplete.run();
            }
        }, 550);
    }

    private void executeLaunchApp(AppItem app) {
        if (app != null) launchPackage(app.packageName);
    }

    private void executeLaunchSeries(SeriesItem series) {
        if (series != null) launchSeriesDirect(series);
    }

    @Override
    protected void onStop() {
        super.onStop();
        if (idleHandler != null) {
            idleHandler.removeCallbacksAndMessages(null);
        }
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        if (!hasFocus) {
            if (idleHandler != null) {
                idleHandler.removeCallbacksAndMessages(null);
            }
        } else {
            resetIdleTimer();
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
            }
        } catch (Exception e) {
            android.util.Log.e("AppleTV", "Error launching package: " + packageName, e);
        }
    }

    private boolean isNetflixKey(int keyCode) {
        return keyCode == 4062 // TCL_NETFLIX
            || keyCode == KeyEvent.KEYCODE_BUTTON_3
            || keyCode == KeyEvent.KEYCODE_BUTTON_12
            || keyCode == 289  // KEYCODE_VIDEO_APP_1
            || keyCode == 297  // KEYCODE_FEATURED_APP_1
            || keyCode == 591;
    }

    private boolean isYouTubeKey(int keyCode) {
        return keyCode == 4065 // TCL_YOUTUBE
            || keyCode == KeyEvent.KEYCODE_BUTTON_2
            || keyCode == 290  // KEYCODE_VIDEO_APP_2
            || keyCode == 298  // KEYCODE_FEATURED_APP_2
            || keyCode == 593;
    }

    private boolean isPrimeVideoKey(int keyCode) {
        return keyCode == 4099 // TCL_PRIMEVIDEO
            || keyCode == KeyEvent.KEYCODE_BUTTON_4
            || keyCode == KeyEvent.KEYCODE_BUTTON_5
            || keyCode == 291  // KEYCODE_VIDEO_APP_3
            || keyCode == 299  // KEYCODE_FEATURED_APP_3
            || keyCode == 752;
    }

    private boolean isDisneyKey(int keyCode) {
        return keyCode == 4141 // TCL_DISNEY
            || keyCode == 292  // KEYCODE_VIDEO_APP_4
            || keyCode == 300; // KEYCODE_FEATURED_APP_4
    }

    private boolean isSettingsKey(int keyCode) {
        return keyCode == 4077 // TCL_SET (TCL remote settings key)
            || keyCode == 4020 // TCL_QUICK_MENU
            || keyCode == KeyEvent.KEYCODE_SETTINGS
            || keyCode == 312; // KEYCODE_QUICK_OPTIONS
    }

    private boolean isTclHomeKey(int keyCode) {
        return keyCode == 4137  // KEYCODE_TCL_DASHBOARD (TCL Home / Dashboard on RC813)
            || keyCode == 4158  // KEYCODE_TCL_TVPLUS (TCL Channel / Home on RC813)
            || keyCode == 4082  // KEYCODE_TCL_ALL_APP
            || keyCode == 4140  // KEYCODE_TCL_GUARD
            || keyCode == 4138  // KEYCODE_TCL_WATCHLIST
            || keyCode == 4139  // KEYCODE_TCL_USER_CENTER
            || keyCode == 284;  // KEYCODE_ALL_APPS
    }

    private void launchTvSettings() {
        try {
            Intent intent = new Intent();
            intent.setComponent(new ComponentName("com.tcl.settings", "com.tcl.settings.MainActivity"));
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
        } catch (Exception e) {
            try {
                Intent fallback = new Intent(Settings.ACTION_SETTINGS);
                fallback.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(fallback);
            } catch (Exception ignored) {}
        }
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        resetIdleTimer();
        int keyCode = event.getKeyCode();
        int action = event.getAction();

        android.util.Log.i("AppleTV_Key", "MainActivity dispatchKeyEvent: action=" + action + ", keyCode=" + keyCode);

        if (keyCode == KeyEvent.KEYCODE_BACK) {
            if (action == KeyEvent.ACTION_DOWN) {
                return true;
            } else if (action == KeyEvent.ACTION_UP) {
                handleBackAction();
                return true;
            }
        }

        if (keyCode == KeyEvent.KEYCODE_MENU) {
            if (action == KeyEvent.ACTION_UP) {
                toggleControlCenter();
                return true;
            } else if (action == KeyEvent.ACTION_DOWN) {
                return true;
            }
        }

        if (action == KeyEvent.ACTION_DOWN) {
            if (keyCode == KeyEvent.KEYCODE_DPAD_UP || keyCode == KeyEvent.KEYCODE_DPAD_DOWN 
                || keyCode == KeyEvent.KEYCODE_DPAD_LEFT || keyCode == KeyEvent.KEYCODE_DPAD_RIGHT) {
                isUserNavigating = true;
            }

            if (isNetflixKey(keyCode)) {
                if (isReorderMode) exitReorderMode();
                launchPackage("com.netflix.ninja");
                return true;
            } else if (isYouTubeKey(keyCode)) {
                if (isReorderMode) exitReorderMode();
                launchPackage("com.google.android.youtube.tv");
                return true;
            } else if (isPrimeVideoKey(keyCode)) {
                if (isReorderMode) exitReorderMode();
                launchPackage("com.amazon.amazonvideo.livingroom");
                return true;
            } else if (isDisneyKey(keyCode)) {
                if (isReorderMode) exitReorderMode();
                launchPackage("in.startv.hotstar");
                return true;
            } else if (isSettingsKey(keyCode)) {
                if (isReorderMode) exitReorderMode();
                launchTvSettings();
                return true;
            } else if (isTclHomeKey(keyCode)) {
                if (isReorderMode) exitReorderMode();
                cycleWallpaper();
                return true;
            }
        } else if (action == KeyEvent.ACTION_UP) {
            if (isNetflixKey(keyCode) || isYouTubeKey(keyCode) || isPrimeVideoKey(keyCode) || isDisneyKey(keyCode) || isSettingsKey(keyCode) || isTclHomeKey(keyCode)) {
                return true;
            }
        }

        return super.dispatchKeyEvent(event);
    }

    private void handleBackAction() {
        if (isControlCenterOpen) {
            closeControlCenter();
            return;
        }

        if (isReorderMode) {
            playSoundBack();
            exitReorderMode();
            return;
        }

        if (inputsDropdown != null && inputsDropdown.getVisibility() == View.VISIBLE) {
            playSoundBack();
            inputsDropdown.setVisibility(View.GONE);
            if (btnInputs != null) btnInputs.requestFocus();
            return;
        }

        // If inside the All Apps grid or Favorite Series, scroll back up to the Dock
        if (lastFocusedView != null && (gridTileViews.contains(lastFocusedView) || favoritesTileViews.contains(lastFocusedView))) {
            playSoundBack();
            if (heroMetadataLayout != null) {
                heroMetadataLayout.animate().cancel();
                heroMetadataLayout.setAlpha(0.0f);
            }
            mainScrollView.scrollTo(0, 0);
            if (favoritesScrollView != null) {
                favoritesScrollView.scrollTo(0, 0);
            }
            final View target = (lastFocusedDockView != null) ? lastFocusedDockView : (dockTileViews.isEmpty() ? null : dockTileViews.get(0));
            if (target != null) {
                target.post(new Runnable() {
                    @Override
                    public void run() {
                        target.requestFocus();
                    }
                });
            }
            return;
        }

        // Already at top level (Dock / Top Bar) -> Launch Ambient Screensaver!
        playSoundClick();
        showWallpaperHud("Ambient Screensaver");
        rootView.postDelayed(new Runnable() {
            @Override
            public void run() {
                startAerialScreensaver();
            }
        }, 120);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (isReorderMode) {
            if (keyCode == KeyEvent.KEYCODE_BACK || keyCode == KeyEvent.KEYCODE_DPAD_CENTER || keyCode == KeyEvent.KEYCODE_ENTER || keyCode == KeyEvent.KEYCODE_MENU) {
                playSoundBack();
                exitReorderMode();
                return true;
            }
        }
        if (isTclHomeKey(keyCode)) {
            if (isReorderMode) exitReorderMode();
            cycleWallpaper();
            return true;
        }
        if (keyCode == KeyEvent.KEYCODE_TV_INPUT) {
            if (isReorderMode) exitReorderMode();
            playSoundClick();
            toggleInputsDropdown();
            return true;
        }
        if (keyCode == KeyEvent.KEYCODE_SETTINGS) {
            if (isReorderMode) exitReorderMode();
            playSoundClick();
            launchTvSettings();
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }
}
