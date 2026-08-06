# ERB to Native: Services

ERB-to-native screens can mount Ruflet services and invoke native device
actions from controls. Declare every long-lived or streaming service used by a
screen, and invoke one-shot operations from a user action.

## Declare services

Service helpers are non-visual: they register the service with the native page
instead of adding a visible control.

```erb
<%= battery %>
<%= connectivity %>
<%= permission_handler %>

<%= column class: "p-6 gap-4" do %>
  <%= text "Checking battery…", id: "battery-status" %>
  <%= button "Refresh",
        service: "battery",
        result_target: "battery-status" %>
<% end %>
```

| ERB helper | Native service | Full Ruby reference |
| --- | --- | --- |
| `accelerometer` | Device acceleration including gravity | [Accelerometer](/docs/service-accelerometer) |
| `audio` | Audio playback service | [Audio extension](/docs/extension-audio) |
| `audio_recorder` | Microphone recording | [Audio Recorder](/docs/service-audio-recorder) |
| `barometer` | Atmospheric pressure | [Barometer](/docs/service-barometer) |
| `battery` | Battery level, state, and saver mode | [Battery](/docs/service-battery) |
| `clipboard` | Text, files, and image clipboard | [Clipboard](/docs/service-clipboard) |
| `connectivity` | Current connection types and changes | [Connectivity](/docs/service-connectivity) |
| `file_picker` | Open, save, and directory pickers | [File Picker](/docs/service-file-picker) |
| `flashlight` | Torch availability and state | [Flashlight](/docs/service-flashlight) |
| `geolocator` | Position, permission, settings, and distance | [Geolocator](/docs/service-geolocator) |
| `gyroscope` | Rotation-rate stream | [Gyroscope](/docs/service-gyroscope) |
| `haptic_feedback` | Impact, selection, and vibration feedback | [Haptic Feedback](/docs/service-haptic-feedback) |
| `magnetometer` | Magnetic-field stream | [Magnetometer](/docs/service-magnetometer) |
| `permission_handler` | Inspect and request OS permissions | [Permission Handler](/docs/service-permission-handler) |
| `screen_brightness` | Application and system brightness | [Screen Brightness](/docs/service-screen-brightness) |
| `secure_storage` | Platform-secure key/value storage | [Secure Storage](/docs/service-secure-storage) |
| `semantics_service` | Accessibility announcements and features | [Semantics Service](/docs/service-semantics-service) |
| `shake_detector` | Shake gesture stream | [Shake Detector](/docs/service-shake-detector) |
| `share` | Native share sheet | [Share](/docs/service-share) |
| `shared_preferences` | Persistent app preferences | [Shared Preferences](/docs/service-shared-preferences) |
| `storage_paths` | Application and platform directories | [Storage Paths](/docs/service-storage-paths) |
| `url_launcher` | External URLs, windows, and in-app browser control | [URL Launcher](/docs/service-url-launcher) |
| `user_accelerometer` | Acceleration with gravity removed | [User Accelerometer](/docs/service-user-accelerometer) |
| `wakelock` | Keep the display awake | [Wakelock](/docs/service-wakelock) |

`camera` is a visible extension control rather than a non-visual helper; use
the [`camera` component](/docs/rails-native-components), the full
[Camera service reference](/docs/service-camera), and camera service actions
together.

## Invoke a service from a control

Set `service:` on `button`, `link`, or another clickable control. Other
attributes become the action payload. Use `result_target:` to write frequent
or returned values into a native text control instead of opening a dialog.

```erb
<%= text "No location yet", id: "location-result" %>
<%= button "Use my location",
      service: "location",
      result_target: "location-result" %>
```

## Clipboard, sharing, and URLs

| Capability | Supported service actions |
| --- | --- |
| Clipboard | `copy`, `clipboard`, `clipboard-set`, `paste`, `read-clipboard`, `clipboard-get`, `clipboard-set-files`, `clipboard-get-files`, `clipboard-set-image`, `clipboard-get-image` |
| Sharing | `share`, `share-text`, `share-link`, `share-url`, `share-uri`, `share-files` |
| URL launcher | `launch`, `open`, `url`, `can-launch`, `open-window`, `close-in-app-web-view` |
| Haptics | `haptic`, `vibrate`; use `style: "selection"`, `"light"`, `"medium"`, `"heavy"`, or `"vibrate"` |

```erb
<%= button "Copy code", service: "copy", text: @invite.code, toast: "Copied" %>
<%= button "Share", service: "share-text", text: invite_url(@invite) %>
<%= button "Open docs", service: "launch", url: "https://ruflet.dev/docs" %>
```

## Hardware and device state

| Capability | Supported service actions |
| --- | --- |
| Flashlight | `flashlight`, `torch`, `flashlight-on`, `torch-on`, `flashlight-off`, `torch-off`, `flashlight-available` |
| Wakelock | `wakelock`, `keep-awake`, `wakelock-enable`, `wakelock-disable`, `wakelock-status` |
| Brightness | `brightness`, `brightness-get`, `brightness-application`, `brightness-system`, `brightness-system-get`, `brightness-can-change-system`, `brightness-animate-get`, `brightness-animate-set`, `brightness-auto-reset-get`, `brightness-auto-reset-set`, `brightness-reset` |
| Battery | `battery`, `battery-level`, `battery-state`, `battery-save-mode` |
| Connectivity | `connectivity` |

## Location, permissions, and files

| Capability | Supported service actions |
| --- | --- |
| Location | `location`, `geolocate`, `position`, `location-last`, `location-permission`, `location-request-permission`, `location-service-enabled`, `location-open-settings`, `location-open-app-settings`, `location-distance` |
| Permissions | `permission`, `request-permission`, `permission-status`, `permission-settings` |
| File picker | `pick-files`, `file-picker`, `pick-directory`, `directory-picker`, `save-file` |
| Storage paths | `storage-cache`, `storage-documents`, `storage-support`, `storage-downloads`, `storage-external-cache`, `storage-external-storage-directories`, `storage-external-storage`, `storage-library`, `storage-temporary`, `storage-temp`, `storage-console-log` |

Interactive permission and picker actions are meant to follow a user tap. Add
the corresponding service and required OS permission description to the Rails
Ruflet initializer so the build includes the package and platform metadata.

## Persistence and security

| Capability | Supported service actions |
| --- | --- |
| Secure storage | `secure-set`, `secure-get`, `secure-contains`, `secure-all`, `secure-remove`, `secure-clear`, `secure-availability` |
| Shared preferences | `prefs-set`, `preference-set`, `prefs-get`, `preference-get`, `prefs-contains`, `preference-contains`, `prefs-keys`, `preference-keys`, `prefs-remove`, `preference-remove`, `prefs-clear`, `preference-clear` |

Pass values with `key:` and `value:`. Results can be displayed in a dialog or
written to `result_target:`.

## Accessibility, recording, sensors, and camera

| Capability | Supported service actions |
| --- | --- |
| Semantics | `announce`, `semantics-announce`, `semantics-tooltip`, `semantics-features` |
| Audio recorder | `audio-recorder-start`, `audio-recorder-stop`, `audio-recorder-supported-encoder`, plus supported recorder methods through the `audio-recorder-<method>` form |
| Sensors | `accelerometer-start`, `accelerometer-stop`, `user-accelerometer-start`, `user-accelerometer-stop`, `gyroscope-start`, `gyroscope-stop`, `magnetometer-start`, `magnetometer-stop`, `barometer-start`, `barometer-stop` |
| Camera | `camera-open`, `camera-initialize`, `camera-capture`, `camera-take-picture` |

Audio recording requests microphone permission, obtains a writable native
documents path, starts recording, and can play the recorded file after Stop.
Declare `audio_recorder` and the microphone permission in the build.

## On-load actions and generic access

Use `on_load:` when a query should run after the native screen and its services
are mounted. Use `service: "control"` to invoke a method on a named control.
Actions not matched by the convenience list fall through to the generic
service dispatcher, so the underlying Ruflet service methods remain reachable.

```erb
<%= text "Loading…", id: "battery-status" %>
<%= button "Refresh battery",
      service: "battery",
      result_target: "battery-status",
      on_load: true %>
```

For exact service properties, events, methods, and permission requirements,
follow the service reference links above or open
[Services and Device APIs](/docs/services-and-plugins). Continue with
[ERB-to-native Components](/docs/rails-native-components).
