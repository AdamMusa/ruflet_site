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

## Client configuration

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
client extensions, Android permissions, Apple usage descriptions, and macOS
entitlements.

Supported protected service declarations are:

- `camera`
- `microphone`
- `location`
- `motion`

Write descriptions that clearly explain your application's reason for
requesting access.

### Optional client extensions

Declare optional non-permission extensions in `ruflet.yaml`:

```yaml
extensions:
  - audio
  - charts
  - map
  - video
  - webview
```

Available extension keys include:

- `ads`, `audio`, `charts`, `code_editor`, `color_pickers`, and `datatable2`
- `flashlight`, `lottie`, `map`, `secure_storage`, `video`, and `webview`

Permission-backed extensions such as camera, audio recording, geolocation, and
permission handling are activated through `services.yaml`.

Rebuild the client after changing `services.yaml` or the `extensions` list.

## Choosing the right API

- Use a page convenience method for a single action and result.
- Use a service object for events, repeated operations, or service-specific methods.
- Add protected device access to `services.yaml` before building native clients.
- Add optional visual or media packages to `ruflet.yaml` under `extensions`.
- Check platform support and handle service errors in the UI.

Services belong to the connected client. In a server-driven app, a file path,
permission, battery reading, or clipboard value refers to the user's device,
not the Ruby server.
