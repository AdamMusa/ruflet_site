# iOS

Ruflet supports iOS builds through the same CLI-driven pipeline.

## Build commands

```bash
ruflet build ios
ruflet build ios --self
```

## What to keep in mind

- iOS is sensitive to client capabilities and permissions.
- Camera, media, storage, and similar features should be planned early.
- Build expectations are different between simulator and physical device installs.

## Good practice

Test on mobile early with the Ruflet client, then move to a real iOS build once the feature flow is stable.
