# P4wnP1 Tool Installer — Android App

A minimal Android WebView wrapper that loads the P4wnP1 Tool Installer web UI
served by the Pi Zero over USB OTG.

## How it works

```
Android Phone ──USB OTG──► Pi Zero 1.3
                             │
                             └── Python installer server (port 8080)
                                 serving the web UI at 172.16.0.1:8080
```

The app simply opens `http://172.16.0.1:8080` in a full-screen WebView.
No internet connection is required — all traffic stays on the USB RNDIS link.

## Requirements

- Android 5.0+ (API 21+)
- USB OTG cable (USB-C to micro-USB or adapter)
- Pi Zero 1.3 running the tool installer server (`run_ondevice.sh`)
- USB tethering enabled: **Settings → Network → USB Tethering → ON**

## Building with Android Studio

1. Install [Android Studio](https://developer.android.com/studio) (free)
2. Open Android Studio → **Open** → select this `android/` directory
3. Wait for Gradle sync to complete (~1 minute)
4. **Build → Build Bundle(s) / APK(s) → Build APK(s)**
5. The APK is at `app/build/outputs/apk/debug/app-debug.apk`
6. Transfer to your phone and install (enable "Unknown Sources" in settings)

Or install directly while connected via USB cable:
```bash
# From the android/ directory
./gradlew installDebug
```

## Changing the target IP

If your Pi Zero uses a different IP (e.g., `192.168.7.1` for CDC-ECM on some
hosts), edit `MainActivity.java`:

```java
private static final String DEFAULT_URL = "http://YOUR_PI_IP:8080";
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| "Could not connect" error | Enable USB tethering on Android; confirm Pi is booted |
| Blank white screen | Wait ~10s for Pi to assign IP; reload |
| Page loads but tools don't install | Tool installer needs root on Pi; check service is running |
| App crashes immediately | Check Android version is 5.0+ |

## Running without the app

You don't need the APK — just open Chrome on Android and navigate to:
```
http://172.16.0.1:8080
```
The web UI is fully mobile-responsive and works in any browser.
