# Android Builds

Build an APK for direct installation or an Android App Bundle for store
distribution:

```bash
ruflet build apk
ruflet build aab
```

`ruflet build android` is an alias for the APK build.

Add `--self` when the Ruby project should be packaged with the client:

```bash
ruflet build android --self
```

Server-driven builds require `app.backend_url` in `ruflet.yaml`.

## Permissions

Declare protected device access in `services.yaml` before building:

```yaml
services:
  - camera:
      description: Allows users to capture photos.
  - location:
      description: Shows nearby locations.
```

Ruflet adds the matching permissions to `AndroidManifest.xml` during client
preparation:

- `camera` adds `android.permission.CAMERA`.
- `microphone` adds `android.permission.RECORD_AUDIO`.
- `location` adds `android.permission.ACCESS_COARSE_LOCATION` and `android.permission.ACCESS_FINE_LOCATION`.
- `motion` adds `android.permission.ACTIVITY_RECOGNITION` and `android.permission.HIGH_SAMPLING_RATE_SENSORS`.

Removing a declaration removes its permissions on the next build, unless a
selected extension such as `camera` or `geolocator` still writes them; see
[Configuration](/docs/configuration-reference#extensions).

While the `local_auth` extension is selected, directly or through a
`biometrics` declaration, the build switches the generated `MainActivity` from
`FlutterActivity` to `FlutterFragmentActivity`, which the Android biometric
prompt needs, and switches it back once `local_auth` is removed.
**Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Launcher icon and splash

Android builds get an adaptive launcher icon and an Android 12 splash on every
build. Without any Android keys, Ruflet uses the shared launcher icon as the
adaptive icon foreground and the shared `icon_background` as its background,
and mirrors the shared splash image into the Android 12 splash. An `android:`
section controls both:

```yaml
assets:
  splash_screen: assets/splash.png
  icon_launcher: assets/icon.png

android:
  adaptive_icon_foreground: assets/icon-foreground.png
  adaptive_icon_background: "#0F172A"
  adaptive_icon_monochrome: assets/icon-monochrome.png
  splash_android_12: assets/splash-android-12.png
  splash_android_12_color: "#0F172A"
  splash_fullscreen: false
```

- The `adaptive_icon_*` keys set the foreground, the background color or image, and the monochrome icon Android uses for themed icons.
- The `splash_android_12*` keys set the image, the circle behind it, the background color and the branding image of the system splash that Android 12 and later show.
- `splash_fullscreen: false` keeps the status bar visible on the splash; the template hides it. `splash_gravity` places the splash image.
- `min_sdk` is the API level the icon generator assumes, 21 by default. It does not change the app's `minSdkVersion`.

See [`android`](/docs/configuration-reference#android) for every key and its
alias.

## Release signing

A release build is signed with the debug key unless you provide an upload key,
and Google Play rejects a debug-signed bundle. Create the keystore once and keep
it safe — losing it means you can no longer update the listing:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Declare it in `android/key.properties` beside your app:

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

`storeFile` may also be relative to that file. Ruflet copies the configuration
into the generated client during the build, so `build/client` never has to be
edited by hand, and the file is excluded from self-contained bundles so the
passwords are never shipped inside the app.

In CI, set the same values in the environment instead, which takes precedence:

```
RUFLET_ANDROID_KEYSTORE
RUFLET_ANDROID_KEYSTORE_PASSWORD
RUFLET_ANDROID_KEY_ALIAS
RUFLET_ANDROID_KEY_PASSWORD
```

Keep `key.properties` and the keystore out of version control.

## Store listing

The version shipped to Play comes from `app.version` in `ruflet.yaml`:

```yaml
app:
  name: My App
  package_name: my_app
  organization: com.example
  version: 1.0.0+1
```

The number after `+` is the Android version code, and Play rejects an upload
that reuses one. Raise it for every build you upload.

## Install

```bash
ruflet devices
ruflet install
ruflet install --device DEVICE_ID
```

Play Console submission itself — tracks, review, and rollout — stays a normal
Android release responsibility.
