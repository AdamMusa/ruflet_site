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

## Install

```bash
ruflet devices
ruflet install
ruflet install --device DEVICE_ID
```

Store signing, release keys, versioning, and Play Console submission remain
standard Android release responsibilities.
