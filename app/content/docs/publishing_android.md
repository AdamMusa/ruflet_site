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

Ruflet adds the corresponding Android permissions during client preparation.

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
