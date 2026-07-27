# Services and Device APIs

Ruflet services let Ruby code interact with capabilities provided by the
connected web, mobile, or desktop client. Use them to open URLs, select files,
read device state, access sensors, share content, store values, and work with
camera, location, audio, video, and other platform features.

Most service calls are asynchronous because the work happens on the client.
Handle the result with `on_result`:

```ruby
page.get_battery_level(
  on_result: ->(level, error) {
    if error && !error.to_s.empty?
      page.update(status, value: "Battery error: #{error}")
    else
      page.update(status, value: "Battery: #{level}%")
    end
  }
)
```

## Convenience methods

Use page convenience methods for one-time actions. Ruflet creates and reuses
the required service automatically.

```ruby
page.launch_url("https://ruflet.dev")

page.set_clipboard("Copied from Ruflet")

page.pick_files(
  allow_multiple: true,
  on_result: ->(files, error) {
    value = error && !error.to_s.empty? ? error.to_s : Array(files).inspect
    page.update(status, value: value)
  }
)

page.share_text(
  "Hello from Ruflet",
  title: "Greeting",
  on_result: ->(result, error) {
    value = error && !error.to_s.empty? ? error.to_s : result.inspect
    page.update(status, value: value)
  }
)
```

Common convenience methods include:

- Clipboard: `set_clipboard`, `get_clipboard`, `set_clipboard_files`, `get_clipboard_files`, `set_clipboard_image`, and `get_clipboard_image`
- Files: `pick_files`, `save_file`, `get_directory_path`, and `upload_files`
- URLs: `launch_url`, `can_launch_url`, `open_window`, and `close_in_app_web_view`
- Sharing: `share_text`, `share_uri`, and `share_files`
- Device state: `get_connectivity`, `get_battery_level`, `get_battery_state`, and `battery_save_mode?`
- Storage paths: `get_application_documents_directory`, `get_downloads_directory`, `get_temporary_directory`, and related path helpers
- Feedback: `vibrate`, `light_impact`, `medium_impact`, `heavy_impact`, and `selection_click`

### One-shot method signatures

Unless shown otherwise, asynchronous calls accept `timeout:` and `on_result:`.
`on_result` receives `|result, error|`.

| Capability | Signatures |
|---|---|
| URLs | `launch_url(url, mode: nil, web_view_configuration: nil, browser_configuration: nil, web_only_window_name: nil, timeout: 10, on_result: nil)`; `can_launch_url(url, timeout: 10)`; `close_in_app_web_view(timeout: 10, on_result: nil)`; `open_window(url, title: nil, width: nil, height: nil, timeout: 10, on_result: nil)`; `supports_launch_mode(mode, timeout: 10, on_result: nil)`; `supports_close_for_launch_mode(mode, timeout: 10, on_result: nil)` |
| Pick files | `pick_files(dialog_title: nil, initial_directory: nil, file_type: "any", allowed_extensions: nil, allow_multiple: false, with_data: false, timeout: nil, on_result: nil)` |
| Save files | `save_file(dialog_title: nil, file_name: nil, initial_directory: nil, file_type: "any", allowed_extensions: nil, src_bytes: nil, timeout: nil, on_result: nil)`; `get_directory_path(dialog_title: nil, initial_directory: nil, timeout: nil, on_result: nil)` |
| Upload | `upload(files, timeout: nil, on_result: nil)`; `upload_files(files, timeout: nil, on_result: nil)` |
| Haptics | `heavy_impact(timeout: 10, on_result: nil)`; `medium_impact(...)`; `light_impact(...)`; `selection_click(...)`; `vibrate(...)` |
| Clipboard | `set_clipboard(value, timeout: nil, on_result: nil)`; `get_clipboard(timeout: nil, on_result: nil)`; `set_clipboard_files(files, ...)`; `get_clipboard_files(...)`; `set_clipboard_image(value, ...)`; `get_clipboard_image(...)` |
| Device state | `get_connectivity(timeout: nil, on_result: nil)`; `get_battery_level(...)`; `get_battery_state(...)`; `is_in_battery_save_mode(...)`; `battery_save_mode?(...)` |
| Storage paths | `get_application_cache_directory(...)`; `get_application_documents_directory(...)`; `get_application_support_directory(...)`; `get_downloads_directory(...)`; `get_external_cache_directories(...)`; `get_external_storage_directories(...)`; `get_external_storage_directory(...)`; `get_library_directory(...)`; `get_temporary_directory(...)`; `get_console_log_filename(...)` |
| Share text | `share_text(text = nil, title: nil, subject: nil, preview_thumbnail: nil, share_position_origin: nil, download_fallback_enabled: true, mail_to_fallback_enabled: true, excluded_cupertino_activities: nil, timeout: nil, on_result: nil)` |
| Share URI | `share_uri(uri = nil, share_position_origin: nil, excluded_cupertino_activities: nil, timeout: nil, on_result: nil)` |
| Share files | `share_files(files = nil, text: nil, title: nil, subject: nil, preview_thumbnail: nil, share_position_origin: nil, download_fallback_enabled: true, mail_to_fallback_enabled: true, excluded_cupertino_activities: nil, timeout: nil, on_result: nil)` |

Availability varies by platform. Handle errors and avoid assuming that every
web browser or device supports every operation.

## Service objects

Create a service object when you need events, configuration, repeated calls, or
direct access to service-specific methods.

```ruby
page.connectivity(
  on_change: ->(event) {
    connections = Array(event.data).join(", ")
    page.update(status, value: connections.empty? ? "Offline" : connections)
  }
)
```

Calling a named helper such as `page.connectivity`, `page.battery`, or
`page.secure_storage` registers that service with the page. Calling it again
returns the same service unless you give it a different `id`.

Use `page.service` when you need a service by name or want to invoke a method
that does not have a Ruby convenience wrapper:

```ruby
flashlight = page.service(
  :flashlight,
  on_error: ->(event) {
    page.update(status, value: "Flashlight error: #{event.data}")
  }
)

page.invoke(flashlight, "on")
```

### Service object reference

Create these with the same-named Page helper. Sensor interval values are
client intervals; availability remains platform-dependent.

Every service control also inherits the `Ruflet::Control` readers and methods:
`type`, `id`, `props`, `children`, `on`, `attach_handler`, `emit`,
`has_handler?`, `merge_props`, and `to_patch`. Application code normally uses
`on` for events and the service-specific methods below; wire/runtime accessors
are framework integration details.

| Service | Properties | Events | Service-specific methods |
|---|---|---|---|
| `accelerometer`, `barometer`, `gyroscope`, `magnetometer`, `user_accelerometer` | `cancel_on_error`, `data`, `enabled`, `interval`, `key` | `on_error`, `on_reading` | Invoke through events and generic `page.invoke` when necessary. |
| `audio` | `autoplay`, `balance`, `data`, `key`, `opacity`, `playback_rate`, `release_mode`, `rtl`, `src`, `src_base64`, `tooltip`, `visible`, `volume` | `on_duration_change`, `on_error`, `on_loaded`, `on_position_change`, `on_seek_complete`, `on_state_change` | `get_current_position`, `get_duration`, `pause`, `play(position: 0, ...)`, `release`, `resume`, `seek(position_milliseconds, ...)` |
| `audio_recorder` | `configuration`, `data`, `key` | `on_state_change`, `on_stream`, `on_upload` | `cancel_recording`, `get_input_devices`, `has_permission`, `is_paused`, `is_recording`, `is_supported_encoder`, `pause_recording`, `resume_recording`, `start_recording`, `stop_recording` |
| `battery` | `data`, `key` | `on_state_change` | Prefer Page battery convenience methods. |
| `camera` | Common visual properties, `preview_enabled` | `on_animation_end`, `on_error`, `on_size_change`, `on_state_change`, `on_stream_image` | — |
| `clipboard` | `data`, `key` | — | `get`, `get_files`, `get_image`, `set`, `set_files`, `set_image` |
| `connectivity` | `data`, `key` | `on_change` | Prefer `page.get_connectivity` for a snapshot. |
| `file_picker` | `data`, `key` | `on_result`, `on_upload` | Prefer Page picker and upload convenience methods. |
| `flashlight` | `data`, `key` | `on_error` | `on`, `off`, `is_available` |
| `geolocator` | `configuration`, `data`, `key` | `on_error`, `on_position_change` | `distance_between`, `get_current_position`, `get_last_known_position`, `get_permission_status`, `is_location_service_enabled`, `open_app_settings`, `open_location_settings`, `request_permission` |
| `haptic_feedback` | `data`, `key` | — | Prefer `heavy_impact`, `medium_impact`, `light_impact`, `selection_click`, and `vibrate` on Page. |
| `permission_handler` | `data`, `key` | — | `get_status`, `open_app_settings`, `request` |
| `screen_brightness` | `data`, `key` | `on_application_screen_brightness_change`, `on_system_screen_brightness_change` | `can_change_system_screen_brightness`, `get_application_screen_brightness`, `get_system_screen_brightness`, `is_animate`, `is_auto_reset`, `reset_application_screen_brightness`, `set_animate`, `set_auto_reset`, `set_application_screen_brightness`, `set_system_screen_brightness` |
| `secure_storage` | `android_options`, `ios_options`, `macos_options`, `web_options`, `windows_options`, `data`, `key` | `on_change` | `clear`, `contains_key`, `get`, `get_all`, `get_availability`, `remove`, `set` |
| `semantics_service` | `data`, `key` | — | `announce_message`, `announce_tooltip`, `get_accessibility_features` |
| `shake_detector` | `data`, `key`, `minimum_shake_count`, `shake_count_reset_time_ms`, `shake_slop_time_ms`, `shake_threshold_gravity` | `on_shake` | Event-driven. |
| `share`, `storage_paths`, `url_launcher` | `data`, `key` | — | Prefer the corresponding Page convenience methods. |
| `shared_preferences` | `data`, `key` | — | Use the proxy methods below. |
| `wakelock` | `data`, `key` | — | Use the proxy methods below. |

Four Page helpers have two modes: call them with no arguments to get a focused
proxy object, or pass properties to register/configure the underlying service
control. Their no-argument proxy APIs are:

- `page.shared_preferences`: `set(key, value, timeout: 10, on_result: nil)`,
  `get(key, ...)`, `contains_key(key, ...)`, `get_keys(key_prefix, ...)`,
  `remove(key, ...)`, and `clear(...)`
- `page.wakelock`: `enable(...)`, `disable(...)`, and `is_enabled(...)`
- `page.flashlight`: `on(...)`, `off(...)`, and `is_available(...)`
- `page.screen_brightness`: the screen-brightness methods listed in the table;
  setters take the new boolean or brightness value before callback options

`page.screenshot(**properties)` creates the visual Screenshot control; it does
not register a service object.

## Service-specific examples

Persistent services expose their own methods and events.

### Secure storage

```ruby
storage = page.secure_storage

storage.set("access_token", token, on_result: ->(_result, error) {
  value = error && !error.to_s.empty? ? error.to_s : "Token saved"
  page.update(status, value: value)
})

storage.get("access_token", on_result: ->(value, error) {
  result = error && !error.to_s.empty? ? error.to_s : value.to_s
  page.update(status, value: result)
})
```

### Location

```ruby
location = page.geolocator

location.request_permission(on_result: ->(permission, error) {
  if error && !error.to_s.empty?
    page.update(status, value: error.to_s)
  else
    location.get_current_position(on_result: ->(position, position_error) {
      failed = position_error && !position_error.to_s.empty?
      page.update(status, value: failed ? position_error.to_s : position.inspect)
    })
  end
})
```

### Permissions

```ruby
permissions = page.permission_handler

permissions.request("camera", on_result: ->(result, error) {
  failed = error && !error.to_s.empty?
  page.update(status, value: failed ? error.to_s : result.inspect)
})
```

Request permission when the user starts the related action. Explain why the
permission is needed before opening the operating system prompt.

### Sensors

```ruby
page.accelerometer(
  interval: 250,
  on_reading: ->(event) {
    page.update(status, value: event.data.inspect)
  },
  on_error: ->(event) {
    page.update(status, value: event.data.to_s)
  }
)
```

Sensor services include `accelerometer`, `user_accelerometer`, `gyroscope`,
`magnetometer`, `barometer`, and `shake_detector`.

## Native capability configuration

Some capabilities require additional Flutter packages or native permissions in
the built client. Runtime Ruby code alone cannot add these after the app has
been built.

### Protected device access

Declare protected device access in `services.yaml` at the project root:

```yaml
services:
  - camera:
      description: Allows users to capture profile photos.
  - microphone:
      description: Allows users to record voice notes.
  - location:
      description: Shows nearby locations.
  - motion:
      description: Reads motion sensor data.
```

During a native build, Ruflet uses these declarations to include the required
client package, Android permissions, Apple usage descriptions, and macOS
entitlements.

Supported protected service declarations are:

- `camera`
- `microphone`
- `location`
- `motion`

Write descriptions that clearly explain your application's reason for
requesting access.

Optional Flutter packages are documented separately in the
[Extension Catalog](/docs/extensions). Rebuild the client after changing
`services.yaml` or `ruflet.yaml` extensions.

## Choosing the right API

- Use a page convenience method for a single action and result.
- Use a service object for events, repeated operations, or service-specific methods.
- Add protected device access to `services.yaml` before building native clients.
- Use the [Extension Catalog](/docs/extensions) for optional visual controls,
  media packages, and third-party integrations.
- Check platform support and handle service errors in the UI.

Services belong to the connected client. In a server-driven app, a file path,
permission, battery reading, or clipboard value refers to the user's device,
not the Ruby server.
