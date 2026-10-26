package com.appletv.launcher;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class WeatherService {
    private static final String TAG = "WeatherService";
    private static final String PREF_NAME = "appletv_weather_prefs";
    private static final String KEY_PILL_TEXT = "weather_pill_text";
    private static final String KEY_DETAIL_TEXT = "weather_detail_text";
    private static final String KEY_LAST_FETCH = "weather_last_fetch";

    // Cache duration: 30 minutes
    private static final long CACHE_DURATION_MS = 30 * 60 * 1000L;

    private static final ExecutorService executor = Executors.newSingleThreadExecutor();
    private static final Handler mainHandler = new Handler(Looper.getMainLooper());

    public interface WeatherCallback {
        void onWeatherLoaded(String pillText, String detailText);
    }

    public static String getCachedPillText(Context context) {
        SharedPreferences prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE);
        return prefs.getString(KEY_PILL_TEXT, null);
    }

    public static String getCachedDetailText(Context context) {
        SharedPreferences prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE);
        return prefs.getString(KEY_DETAIL_TEXT, null);
    }

    public static void fetchWeather(final Context context, final boolean force, final WeatherCallback callback) {
        final SharedPreferences prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE);
        long lastFetch = prefs.getLong(KEY_LAST_FETCH, 0);
        long now = System.currentTimeMillis();

        if (!force && (now - lastFetch < CACHE_DURATION_MS)) {
            String cachedPill = prefs.getString(KEY_PILL_TEXT, null);
            String cachedDetail = prefs.getString(KEY_DETAIL_TEXT, null);
            if (cachedPill != null && callback != null) {
                callback.onWeatherLoaded(cachedPill, cachedDetail);
                return;
            }
        }

        executor.execute(new Runnable() {
            @Override
            public void run() {
                try {
                    // Step 1: Detect location via IP (default coordinates: Pune)
                    String city = "Pune";
                    double lat = 18.5204;
                    double lon = 73.8567;

                    try {
                        URL ipUrl = new URL("http://ip-api.com/json");
                        HttpURLConnection ipConn = (HttpURLConnection) ipUrl.openConnection();
                        ipConn.setConnectTimeout(4000);
                        ipConn.setReadTimeout(4000);
                        ipConn.setRequestMethod("GET");
                        if (ipConn.getResponseCode() == 200) {
                            BufferedReader reader = new BufferedReader(new InputStreamReader(ipConn.getInputStream()));
                            StringBuilder sb = new StringBuilder();
                            String line;
                            while ((line = reader.readLine()) != null) sb.append(line);
                            reader.close();

                            JSONObject json = new JSONObject(sb.toString());
                            if ("success".equalsIgnoreCase(json.optString("status"))) {
                                city = json.optString("city", city);
                                lat = json.optDouble("lat", lat);
                                lon = json.optDouble("lon", lon);
                            }
                        }
                        ipConn.disconnect();
                    } catch (Exception e) {
                        Log.w(TAG, "IP location lookup failed, using fallback: " + e.getMessage());
                    }

                    // Step 2: Query Open-Meteo current weather
                    String weatherUrlStr = "https://api.open-meteo.com/v1/forecast?latitude=" 
                            + lat + "&longitude=" + lon + "&current_weather=true";
                    URL weatherUrl = new URL(weatherUrlStr);
                    HttpURLConnection wConn = (HttpURLConnection) weatherUrl.openConnection();
                    wConn.setConnectTimeout(5000);
                    wConn.setReadTimeout(5000);
                    wConn.setRequestMethod("GET");

                    if (wConn.getResponseCode() == 200) {
                        BufferedReader reader = new BufferedReader(new InputStreamReader(wConn.getInputStream()));
                        StringBuilder sb = new StringBuilder();
                        String line;
                        while ((line = reader.readLine()) != null) sb.append(line);
                        reader.close();

                        JSONObject wJson = new JSONObject(sb.toString());
                        JSONObject current = wJson.getJSONObject("current_weather");
                        double temp = current.getDouble("temperature");
                        int code = current.getInt("weathercode");

                        int roundedTemp = (int) Math.round(temp);
                        String condition = mapWeatherCode(code);

                        // Elegant tvOS pill style: e.g. "33° Mostly Clear"
                        final String pillText = roundedTemp + "\u00B0 " + condition;
                        final String detailText = city + " \u2022 " + roundedTemp + "\u00B0C \u2022 " + condition;

                        // Save cache
                        prefs.edit()
                                .putString(KEY_PILL_TEXT, pillText)
                                .putString(KEY_DETAIL_TEXT, detailText)
                                .putLong(KEY_LAST_FETCH, System.currentTimeMillis())
                                .apply();

                        if (callback != null) {
                            mainHandler.post(new Runnable() {
                                @Override
                                public void run() {
                                    callback.onWeatherLoaded(pillText, detailText);
                                }
                            });
                        }
                    }
                    wConn.disconnect();
                } catch (Exception e) {
                    Log.e(TAG, "Weather fetch failed: " + e.getMessage(), e);
                }
            }
        });
    }

    private static String mapWeatherCode(int code) {
        switch (code) {
            case 0: return "Clear";
            case 1: return "Mostly Clear";
            case 2: return "Partly Cloudy";
            case 3: return "Overcast";
            case 45:
            case 48: return "Foggy";
            case 51:
            case 53:
            case 55: return "Drizzle";
            case 61:
            case 63:
            case 65: return "Rain";
            case 71:
            case 73:
            case 75: return "Snow";
            case 80:
            case 81:
            case 82: return "Showers";
            case 95:
            case 96:
            case 99: return "Thunderstorm";
            default: return "Clear";
        }
    }
}
