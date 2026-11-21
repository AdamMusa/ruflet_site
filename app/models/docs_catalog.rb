require "json"

class DocsCatalog
  Entry = Struct.new(:slug, :title, :summary, :source, :section, :content, :parent_slug, keyword_init: true)
  Section = Struct.new(:id, :title, :entries, keyword_init: true)

  SOURCE_ROOT = Rails.root.join("app/content/docs")
  CONTROL_CATALOG_PATH = Rails.root.join("config/control_catalog.json")
  SERVICE_CATALOG_PATH = Rails.root.join("config/service_catalog.json")
  RUNTIME_CATALOG_PATH = Rails.root.join("config/runtime_catalog.json")
  CONTROL_DOCS_PATH = Rails.root.join("config/control_docs.json")
  NEXT_RELEASE_PATH = Rails.root.join("config/next_release.json")

  # Pages for APIs that are on Ruflet main but not in the published gems carry
  # this phrase. Delete every occurrence when the next release ships.
  NEXT_RELEASE_MARKER = "**Requires the next Ruflet release** (on `main`, not in 0.0.23)".freeze
  NEXT_RELEASE_CONSEQUENCES = {
    controls: 'With 0.0.23 the client shows "Unknown control".',
    services: "On 0.0.23 `page.%<helper>s` raises NoMethodError."
  }.freeze
  # Said before the inline marker on generated lines that 0.0.23 Ruby accepts
  # but the 0.0.23 client does not act on (config/next_release.json "client_ignored").
  NEXT_RELEASE_CLIENT_NOTES = {
    "properties" => "The 0.0.23 client ignores it.",
    "events" => "The 0.0.23 client never sends it."
  }.freeze
  # The same for lines that work with 0.0.23 on one design but not on the
  # listed one (config/next_release.json "design_client_ignored"). Clients
  # draw iOS and macOS with Cupertino widgets and other platforms with
  # Material ones.
  NEXT_RELEASE_DESIGN_PLATFORMS = {
    "cupertino" => "On iOS and macOS",
    "material" => "On Android, web, Windows and Linux"
  }.freeze
  NEXT_RELEASE_DESIGN_NOTES = {
    "properties" => "the 0.0.23 client ignores it.",
    "events" => "the 0.0.23 client never sends it.",
    "methods" => "the 0.0.23 client does not run it."
  }.freeze

  SERVICE_SUMMARIES = {
    "accelerometer" => "Stream accelerometer readings, gravity included, while the device moves.",
    "audio_recorder" => "Record microphone audio to a file or a stream, and pause, resume, or cancel the recording.",
    "barometer" => "Stream air-pressure readings from the device barometer.",
    "battery" => "Read the battery level and charging state, and check for battery-save mode.",
    "browser_context_menu" => "Turn the browser's own right-click menu off or on in a web app.",
    "camera" => "Show a camera preview, take pictures, record video, and stream camera images.",
    "clipboard" => "Copy text, images, and files to the system clipboard and read them back.",
    "connectivity" => "Check the current network connection and react when it changes.",
    "file_picker" => "Let the user pick files or a directory, save a file, and upload picked files.",
    "flashlight" => "Check whether the device has a torch and turn it on or off.",
    "geolocator" => "Request location access, read the device position, and follow position changes.",
    "gyroscope" => "Stream rotation-rate readings from the device gyroscope.",
    "haptic_feedback" => "Trigger vibration and impact feedback on devices that support it.",
    "local_authentication" => "Ask the user to confirm their identity with biometrics or the device passcode.",
    "magnetometer" => "Stream magnetic-field readings from the device magnetometer.",
    "permission_handler" => "Check and request operating-system permissions, or open the app's settings page.",
    "screen_brightness" => "Read and change the app's or the system's screen brightness.",
    "secure_storage" => "Store small secrets, such as access tokens, in the platform's secure storage.",
    "semantics_service" => "Send announcements to screen readers and read the accessibility features in use.",
    "shake_detector" => "Detect when the user shakes the device.",
    "share" => "Open the system share sheet for text, a URI, or files.",
    "shared_preferences" => "Keep small key-value settings on the device between sessions.",
    "storage_paths" => "Find the app's documents, cache, support, temporary, and downloads directories.",
    "url_launcher" => "Open URLs in the browser or another app, and check whether a URL can be opened.",
    "user_accelerometer" => "Stream device acceleration without gravity, so only the user's own movement remains.",
    "wakelock" => "Keep the screen on while the app needs it, and let it turn off again."
  }.freeze

  SERVICE_CONVENIENCE_METHODS = {
    "battery" => %w[get_battery_level get_battery_state is_in_battery_save_mode battery_save_mode?],
    "clipboard" => %w[set_clipboard get_clipboard set_clipboard_files get_clipboard_files set_clipboard_image get_clipboard_image],
    "connectivity" => %w[get_connectivity],
    "file_picker" => %w[pick_files save_file get_directory_path upload upload_files],
    "haptic_feedback" => %w[heavy_impact medium_impact light_impact selection_click vibrate],
    "share" => %w[share_text share_uri share_files],
    "storage_paths" => %w[get_application_cache_directory get_application_documents_directory get_application_support_directory get_downloads_directory get_external_cache_directories get_external_storage_directories get_external_storage_directory get_library_directory get_temporary_directory get_console_log_filename],
    "url_launcher" => %w[launch_url can_launch_url close_in_app_web_view open_window supports_launch_mode supports_close_for_launch_mode]
  }.freeze

  SERVICE_PROTECTED_ACCESS = {
    "accelerometer" => %w[motion], "barometer" => %w[motion],
    "gyroscope" => %w[motion], "magnetometer" => %w[motion],
    "shake_detector" => %w[motion], "user_accelerometer" => %w[motion]
  }.freeze

  SERVICE_EXAMPLES = {
    "accelerometer" => <<~'RUBY',
      reading = text(value: "Move the device")
      page.add(reading)
      page.accelerometer(
        interval: 200,
        on_reading: ->(event) { page.update(reading, value: event.data.inspect) },
        on_error: ->(event) { page.update(reading, value: "Motion error: #{event.data}") }
      )
    RUBY
    "audio_recorder" => <<~'RUBY',
      status = text(value: "Recorder ready")
      page.add(status)
      recorder = page.audio_recorder(
        on_state_change: ->(event) { page.update(status, value: event.data.to_s) }
      )
      recorder.has_permission(on_result: ->(allowed, error) {
        if error
          page.update(status, value: error.to_s)
        elsif allowed
          recorder.start_recording(
            output_path: "voice-note.m4a",
            configuration: { encoder: "aac_lc" },
            on_result: ->(_result, start_error) {
              page.update(status, value: start_error ? start_error.to_s : "Recording")
            }
          )
        end
      })
    RUBY
    "barometer" => <<~'RUBY',
      pressure = text(value: "Waiting for pressure data")
      page.add(pressure)
      page.barometer(
        interval: 500,
        on_reading: ->(event) { page.update(pressure, value: "Pressure: #{event.data}") },
        on_error: ->(event) { page.update(pressure, value: event.data.to_s) }
      )
    RUBY
    "battery" => <<~'RUBY',
      battery = text(value: "Reading battery…")
      page.add(battery)
      page.get_battery_level(on_result: ->(level, error) {
        value = error ? error.to_s : "Battery: #{level}%"
        page.update(battery, value: value)
      })
    RUBY
    "browser_context_menu" => <<~'RUBY',
      status = text(value: "Right-click uses the browser menu")
      page.add(status)
      menu = page.service(:browser_context_menu)
      menu.disable(on_result: ->(_result, error) {
        page.update(status, value: error ? error.to_s : "Browser menu disabled: #{menu.disabled?}")
      })
    RUBY
    "camera" => <<~'RUBY',
      preview = page.camera(
        preview_enabled: true,
        expand: true,
        on_state_change: ->(event) { puts "Camera: #{event.data}" },
        on_error: ->(event) { puts "Camera error: #{event.data}" }
      )
      page.add(preview)
    RUBY
    "clipboard" => <<~'RUBY',
      result = text(value: "Nothing copied yet")
      page.add(result)
      page.set_clipboard("Copied from Ruflet", on_result: ->(_saved, save_error) {
        next page.update(result, value: save_error.to_s) if save_error

        page.get_clipboard(on_result: ->(value, read_error) {
          page.update(result, value: read_error ? read_error.to_s : value.to_s)
        })
      })
    RUBY
    "connectivity" => <<~'RUBY',
      network = text(value: "Checking connection…")
      page.add(network)
      page.connectivity(
        on_change: ->(event) {
          connections = Array(event.data).join(", ")
          page.update(network, value: connections.empty? ? "Offline" : connections)
        }
      )
      page.get_connectivity(on_result: ->(value, error) {
        page.update(network, value: error ? error.to_s : Array(value).join(", "))
      })
    RUBY
    "file_picker" => <<~'RUBY',
      selected = text(value: "No files selected")
      page.add(selected)
      page.pick_files(
        allow_multiple: true,
        file_type: "image",
        on_result: ->(files, error) {
          names = Array(files).map { |file| file["name"] || file[:name] }
          page.update(selected, value: error ? error.to_s : names.join(", "))
        }
      )
    RUBY
    "flashlight" => <<~'RUBY',
      status = text(value: "Checking flashlight…")
      page.add(status)
      flashlight = page.flashlight
      flashlight.is_available(on_result: ->(available, error) {
        if error || !available
          page.update(status, value: error ? error.to_s : "Flashlight unavailable")
        else
          flashlight.on(on_result: ->(_result, on_error) {
            page.update(status, value: on_error ? on_error.to_s : "Flashlight on")
          })
        end
      })
    RUBY
    "geolocator" => <<~'RUBY',
      location = text(value: "Location not requested")
      page.add(location)
      geolocator = page.geolocator
      geolocator.request_permission(on_result: ->(_permission, permission_error) {
        next page.update(location, value: permission_error.to_s) if permission_error

        geolocator.get_current_position(on_result: ->(position, error) {
          page.update(location, value: error ? error.to_s : position.inspect)
        })
      })
    RUBY
    "gyroscope" => <<~'RUBY',
      rotation = text(value: "Rotate the device")
      page.add(rotation)
      page.gyroscope(
        interval: 200,
        on_reading: ->(event) { page.update(rotation, value: event.data.inspect) },
        on_error: ->(event) { page.update(rotation, value: event.data.to_s) }
      )
    RUBY
    "haptic_feedback" => <<~'RUBY',
      page.add(
        button(
          "Confirm",
          on_click: ->(_event) {
            page.medium_impact(on_result: ->(_result, error) { warn error if error })
          }
        )
      )
    RUBY
    "local_authentication" => <<~'RUBY',
      status = text(value: "Notes are locked")
      page.add(status)
      auth = page.local_authentication
      auth.authenticate(
        localized_reason: "Unlock your notes",
        biometric_only: false,
        on_result: ->(unlocked, error) {
          message = if error
            "Not unlocked: #{Ruflet::LocalAuthError.from_error(error).code || error}"
          else
            unlocked ? "Notes unlocked" : "Authentication failed, try again"
          end
          page.update(status, value: message)
        }
      )
    RUBY
    "magnetometer" => <<~'RUBY',
      magnetic_field = text(value: "Reading magnetic field…")
      page.add(magnetic_field)
      page.magnetometer(
        interval: 250,
        on_reading: ->(event) { page.update(magnetic_field, value: event.data.inspect) },
        on_error: ->(event) { page.update(magnetic_field, value: event.data.to_s) }
      )
    RUBY
    "permission_handler" => <<~'RUBY',
      status = text(value: "Camera permission not requested")
      page.add(status)
      permissions = page.permission_handler
      permissions.request("camera", on_result: ->(permission, error) {
        page.update(status, value: error ? error.to_s : "Camera: #{permission}")
      })
    RUBY
    "screen_brightness" => <<~'RUBY',
      status = text(value: "Reading brightness…")
      page.add(status)
      brightness = page.screen_brightness
      brightness.get_application_screen_brightness(on_result: ->(value, error) {
        next page.update(status, value: error.to_s) if error

        brightness.set_application_screen_brightness(0.8, on_result: ->(_result, set_error) {
          message = set_error ? set_error.to_s : "Brightness changed from #{value} to 0.8"
          page.update(status, value: message)
        })
      })
    RUBY
    "secure_storage" => <<~'RUBY',
      status = text(value: "Saving token…")
      page.add(status)
      token = "token-from-your-sign-in-flow"
      storage = page.secure_storage
      storage.set("access_token", token, on_result: ->(_saved, save_error) {
        next page.update(status, value: save_error.to_s) if save_error

        storage.get("access_token", on_result: ->(value, read_error) {
          page.update(status, value: read_error ? read_error.to_s : "Token loaded: #{value}")
        })
      })
    RUBY
    "semantics_service" => <<~'RUBY',
      accessibility = page.semantics_service
      accessibility.announce_message(
        "Your changes were saved",
        assertiveness: "polite",
        on_result: ->(_result, error) { warn error if error }
      )
    RUBY
    "shake_detector" => <<~'RUBY',
      status = text(value: "Shake the device to refresh")
      page.add(status)
      page.shake_detector(
        minimum_shake_count: 2,
        on_shake: ->(_event) { page.update(status, value: "Refreshing…") }
      )
    RUBY
    "share" => <<~'RUBY',
      status = text(value: "Ready to share")
      page.add(status)
      page.share_text(
        "Try Ruflet: https://ruflet.dev",
        title: "Ruflet",
        subject: "Ruby apps for every screen",
        on_result: ->(result, error) {
          page.update(status, value: error ? error.to_s : "Share result: #{result}")
        }
      )
    RUBY
    "shared_preferences" => <<~'RUBY',
      status = text(value: "Saving preference…")
      page.add(status)
      preferences = page.shared_preferences
      preferences.set("theme", "dark", on_result: ->(_saved, save_error) {
        next page.update(status, value: save_error.to_s) if save_error

        preferences.get("theme", on_result: ->(value, read_error) {
          page.update(status, value: read_error ? read_error.to_s : "Theme: #{value}")
        })
      })
    RUBY
    "storage_paths" => <<~'RUBY',
      path = text(value: "Finding documents directory…")
      page.add(path)
      page.get_application_documents_directory(on_result: ->(directory, error) {
        page.update(path, value: error ? error.to_s : directory.to_s)
      })
    RUBY
    "url_launcher" => <<~'RUBY',
      status = text(value: "Ready to open Ruflet")
      page.add(status)
      page.launch_url(
        "https://ruflet.dev",
        mode: "externalApplication",
        on_result: ->(opened, error) {
          page.update(status, value: error ? error.to_s : "Opened: #{opened}")
        }
      )
    RUBY
    "user_accelerometer" => <<~'RUBY',
      movement = text(value: "Waiting for user movement")
      page.add(movement)
      page.user_accelerometer(
        interval: 200,
        on_reading: ->(event) { page.update(movement, value: event.data.inspect) },
        on_error: ->(event) { page.update(movement, value: event.data.to_s) }
      )
    RUBY
    "wakelock" => <<~'RUBY'
      status = text(value: "Keeping the screen awake…")
      page.add(status)
      wakelock = page.wakelock
      wakelock.enable(on_result: ->(_result, error) {
        page.update(status, value: error ? error.to_s : "Wakelock enabled")
      })
    RUBY
  }.freeze

  EXTENSION_CATALOG = [
    { key: "ads", title: "Ads", package: "ruflet_ads", kind: "Control family", summary: "Show Google Mobile Ads banner and interstitial ads in Android and iOS apps.", controls: %w[control-banner-ad control-interstitial-ad control-native-ad], platforms: "Ads load on Android and iOS only. Set `unit_id` on every ad: an interstitial without one loads Google's test unit, but a banner without one falls back to the interstitial test ids (a client bug), so no test banner shows. Use your own AdMob app and unit ids before you ship. Google's Mobile Ads SDK also needs your AdMob application id in the app, and Ruflet has no `ruflet.yaml` setting for it: the Android manifest of the client `ruflet build` generates has none, and iOS and macOS builds remove the sample id the client template ships. Without that id the SDK stops the app at launch on Android and iOS. `native_ad` is not drawn yet.", example: "status = text(value: \"Loading ad…\")\n# Google's Android test banner; on iOS use \"ca-app-pub-3940256099942544/2934735716\"\nad = banner_ad(\n  unit_id: \"ca-app-pub-3940256099942544/6300978111\",\n  on_load: ->(_event) { page.update(status, value: \"Ad loaded\") },\n  on_error: ->(event) { page.update(status, value: \"Ad failed: \#{event.data}\") }\n)\npage.add(column(children: [ad, status]))" },
    { key: "audio", title: "Audio", package: "ruflet_audio", kind: "Media service", summary: "Play audio from a URL, an asset, or base64 data, and follow its position and state.", controls: %w[control-audio], platforms: "Audio plays on Android, iOS, macOS, Windows, Linux and the web; `balance` is ignored on the web. The player is a page service: create it with `page.audio(...)`, not `page.add`.", example: "status = text(value: \"Stopped\")\nplayer = page.audio(\n  src: \"https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3\",\n  on_state_change: ->(event) { page.update(status, value: event.data[:state].to_s) }\n)\npage.add(row(children: [button(\"Play\", on_click: ->(_event) { player.play }), status]))" },
    { key: "audio_recorder", title: "Audio Recorder", package: "ruflet_audio_recorder", kind: "Device service", summary: "Record microphone input, inspect recorder state, and receive streams or uploads.", services: %w[audio_recorder], required_services: %w[microphone], example: "recorder = page.audio_recorder\nrecorder.start_recording(on_result: ->(result, error) { })" },
    { key: "camera", title: "Camera", package: "ruflet_camera", kind: "Device service", summary: "Display a native camera preview and receive camera state or image events.", services: %w[camera], required_services: %w[camera], example: "page.camera(\n  preview_enabled: true,\n  on_stream_image: ->(event) { puts event.data }\n)" },
    { key: "charts", title: "Charts", package: "ruflet_charts", kind: "Control family", summary: "Build interactive bar, line, pie, scatter, candlestick, and radar charts.", controls: %w[control-bar-chart control-bar-chart-group control-bar-chart-rod control-bar-chart-rod-stack-item control-line-chart control-line-chart-data control-line-chart-data-point control-pie-chart control-pie-chart-section control-scatter-chart control-scatter-chart-spot control-candlestick-chart control-candlestick-chart-spot control-radar-chart control-radar-chart-title control-radar-data-set control-radar-data-set-entry control-chart-axis control-chart-axis-label], platforms: "Charts are drawn with fl_chart and look the same on every platform. See [Charts and Canvas](/docs/charts-and-canvas) for a guide.", example: "sales = bar_chart(\n  min_y: 0,\n  max_y: 100,\n  groups: [\n    bar_chart_group(x: 0, rods: [bar_chart_rod(from_y: 0, to_y: 72, color: \"#2563eb\")]),\n    bar_chart_group(x: 1, rods: [bar_chart_rod(from_y: 0, to_y: 91, color: \"#7c3aed\")])\n  ],\n  on_event: ->(event) { puts event.data.inspect }\n)\npage.add(sales)" },
    { key: "code_editor", title: "Code Editor", package: "ruflet_code_editor", kind: "Editing control", summary: "Edit syntax-highlighted source code and handle value, selection, and focus changes.", controls: %w[control-code-editor], platforms: "The editor works on every platform; iOS and macOS draw a Cupertino-styled editor and the other platforms the Material one.", example: "status = text(value: \"Start typing Ruby\")\neditor = code_editor(\n  \"puts :hello\",\n  language: \"ruby\",\n  expand: true,\n  on_change: ->(event) { page.update(status, value: \"\#{event.control.props[\"value\"].to_s.length} characters\") }\n)\npage.add(column(expand: true, children: [editor, status]))" },
    { key: "color_pickers", title: "Color Pickers", package: "ruflet_color_pickers", kind: "Control family", summary: "Provide color, hue-ring, slide, material, block, and multiple-choice color pickers.", controls: %w[control-color-picker control-hue-ring-picker control-slide-picker control-material-picker control-block-picker control-multiple-choice-block-picker], wire_types: %w[ColorPicker HueRingPicker SlidePicker MaterialPicker BlockPicker MultipleChoiceBlockPicker], platforms: "The pickers work on every platform; iOS and macOS draw them with Cupertino-styled parts. Picked colors arrive as `\"#aarrggbb\"` strings.", example: "selected = text(value: \"#ff2563eb\")\npicker = color_picker(\n  color: \"#2563eb\",\n  enable_alpha: true,\n  on_color_change: ->(event) { page.update(selected, value: event.data.to_s) }\n)\npage.add(column(children: [picker, selected]))" },
    { key: "datatable2", title: "DataTable2", package: "ruflet_datatable2", kind: "Data control", summary: "Render a table with fixed rows or columns and richer scrolling and sizing options.", controls: %w[control-data-table-2 control-data-column-2 control-data-row-2 control-data-cell], wire_types: %w[DataTable2], example: "table = data_table2(\n  fixed_top_rows: 1,\n  columns: [data_column2(label: text(value: \"Name\")), data_column2(label: text(value: \"Role\"))],\n  rows: [data_row2(cells: [data_cell(content: text(value: \"Ruflet\")), data_cell(content: text(value: \"Framework\"))])],\n  on_select_all: ->(event) { puts event.data.inspect }\n)\npage.add(table)" },
    { key: "flashlight", title: "Flashlight", package: "ruflet_flashlight", kind: "Device service", summary: "Check flashlight availability and turn the device torch on or off.", services: %w[flashlight], required_services: %w[camera], example: "torch = page.flashlight\ntorch.on(on_result: ->(result, error) { })" },
    { key: "geolocator", title: "Geolocator", package: "ruflet_geolocator", kind: "Device service", summary: "Request location access, read positions, and subscribe to position changes.", services: %w[geolocator], required_services: %w[location], example: "location = page.geolocator\nlocation.get_current_position(on_result: ->(position, error) { })" },
    { key: "local_auth", title: "Local Authentication", package: "ruflet_local_auth", kind: "Device service", summary: "Confirm the user's identity with biometrics or the device passcode.", services: %w[local_authentication], required_services: %w[biometrics], example: "auth = page.local_authentication\nauth.authenticate(localized_reason: \"Unlock your notes\", on_result: ->(unlocked, error) { })" },
    { key: "lottie", title: "Lottie", package: "ruflet_lottie", kind: "Animation control", summary: "Render and control Lottie animations from assets, URLs, or embedded sources.", controls: %w[control-lottie], platforms: "Lottie animations play on every platform.", example: "animation = lottie(\n  src: \"assets/success.json\",\n  repeat: false,\n  error_content: text(value: \"Animation unavailable\"),\n  on_load: ->(_event) { puts \"Animation loaded\" }\n)\npage.add(animation)" },
    { key: "map", title: "Map", package: "ruflet_map", kind: "Control family", summary: "Build interactive maps with tile, marker, circle, polyline, polygon, and attribution layers.", controls: %w[control-map control-tile-layer control-marker-layer control-marker control-circle-layer control-circle-marker control-polyline-layer control-polyline-marker control-polygon-layer control-polygon-marker control-simple-attribution control-rich-attribution control-text-source-attribution control-image-source-attribution], platforms: "Maps are drawn with flutter_map on every platform; the attribution controls are Cupertino-styled on iOS and macOS. Tiles come from the server in `url_template`: follow its usage policy, set `user_agent_package_name` and show its attribution. See [Maps](/docs/maps) for a guide.", example: "office = [40.7128, -74.0060]\nmap_view = map(\n  [\n    tile_layer(url_template: \"https://tile.openstreetmap.org/{z}/{x}/{y}.png\", user_agent_package_name: \"com.example.app\"),\n    marker_layer([marker(icon(\"location_on\"), coordinates: office)]),\n    rich_attribution([text_source_attribution(\"OpenStreetMap contributors\")])\n  ],\n  initial_center: office,\n  initial_zoom: 13,\n  expand: true,\n  on_tap: ->(event) { puts event.data[:coordinates].inspect }\n)\npage.add(map_view)" },
    { key: "permission_handler", title: "Permission Handler", package: "ruflet_permission_handler", kind: "Device service", summary: "Inspect and request operating-system permissions at the moment a user needs them.", services: %w[permission_handler], example: "permissions = page.permission_handler\npermissions.request(\"camera\", on_result: ->(status, error) { })" },
    { key: "qrcode_scanner", title: "QR Code Scanner", package: "ruflet_qrcode_scanner", kind: "Scanner control", summary: "Scan QR codes and supported barcodes with the native camera.", required_services: %w[camera], guide: "qrcode-scanner", example: "qrcode_scanner(\n  formats: [:qr_code],\n  on_detect: ->(event) { puts event.value }\n)" },
    { key: "rive", title: "Rive", package: "ruflet_rive", kind: "Animation control", summary: "Render Rive artboards, animations, and state machines.", controls: %w[control-rive], platforms: "Rive files play on every platform.", example: "mascot = rive(\n  \"https://cdn.rive.app/animations/vehicles.riv\",\n  fit: \"contain\",\n  placeholder: progress_ring(),\n  expand: true\n)\npage.add(mascot)" },
    { key: "secure_storage", title: "Secure Storage", package: "ruflet_secure_storage", kind: "Storage service", summary: "Store, retrieve, enumerate, and remove sensitive values using platform-secure storage.", services: %w[secure_storage], example: "token = \"token-from-your-sign-in-flow\"\nstorage = page.secure_storage\nstorage.set(\"access_token\", token, on_result: ->(result, error) { })" },
    { key: "spinkit", title: "SpinKit", package: "ruflet_spinkit", kind: "Animation control", summary: "Show animated loading indicators from the SpinKit collection.", controls: %w[control-spinkit], example: "loader = spinkit(\n  three_bounce: { color: \"#2563eb\", size: 32 }\n)\npage.add(column(children: [loader, text(value: \"Loading…\")]))" },
    { key: "video", title: "Video", package: "ruflet_video", kind: "Media control", summary: "Play video with configurable playlists, controls, aspect ratio, and playback events.", controls: %w[control-video], platforms: "Video plays with media_kit; iOS and macOS show Cupertino-style playback controls and the other platforms Material ones. A playlist `resource` is passed to the player as is, so use a URL or a file path on the device.", example: "player = video(\n  playlist: [{ resource: \"https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4\" }],\n  show_controls: true,\n  aspect_ratio: 16 / 9.0,\n  on_error: ->(event) { warn event.data }\n)\npage.add(player)\npage.add(button(\"Play or pause\", on_click: ->(_event) { player.play_or_pause }))" },
    { key: "webview", title: "WebView", package: "ruflet_webview", kind: "Web content control", summary: "Embed web content and control navigation in a native WebView.", controls: %w[control-web-view], platforms: "iOS, Android and macOS draw a native web view with events and methods. The web shows the page in an iframe, without events or methods. Windows and Linux draw an error box: the web view is not supported there yet.", example: "browser = web_view(\n  url: \"https://ruflet.dev\",\n  expand: true,\n  on_page_ended: ->(event) { puts \"Loaded \#{event.data}\" },\n  on_web_resource_error: ->(event) { warn event.data }\n)\npage.add(browser)\nbrowser.get_title { |title, error| puts(error || title) }" }
  ].freeze

  def self.sections
    @sections ||= [
      Section.new(
        id: "learn",
        title: "Learn",
        entries: [
          entry("introduction", "Introduction", "Build web, desktop, and mobile applications with Ruby and Ruflet.", SOURCE_ROOT.join("introduction.md"), "Learn"),
          entry("installation", "Installation", "Install the Ruflet CLI and prepare a Ruby development environment.", SOURCE_ROOT.join("installation.md"), "Learn"),
          entry("getting-started", "Getting Started", "Create a Ruflet app, run it in a browser, and learn the development loop.", SOURCE_ROOT.join("getting_started.md"), "Learn"),
          entry("creating-a-new-app", "Creating a New Ruflet App", "Scaffold a new project, inspect the generated files, and understand `ruflet.yaml`.", SOURCE_ROOT.join("creating_a_new_app.md"), "Learn"),
          entry("app-structure", "App Structure", "Understand the generated files, the role of `main.rb`, `Gemfile`, and `ruflet.yaml`, and how Ruflet apps are organized.", SOURCE_ROOT.join("app_structure.md"), "Learn"),
          entry("running-a-ruflet-app", "Running a Ruflet App", "Run Ruflet for mobile, web, and desktop, and understand the core development loop.", SOURCE_ROOT.join("running_a_ruflet_app.md"), "Learn"),
          entry("cli-workflow", "CLI Workflow", "What `new`, `run`, `build`, `install`, `update`, and `doctor` do in a real Ruflet project.", SOURCE_ROOT.join("cli_workflow.md"), "Learn"),
          entry("testing-on-mobile", "Testing on Mobile", "Connect to the Ruflet mobile client and verify your app on real devices.", SOURCE_ROOT.join("testing_on_mobile.md"), "Learn"),
          entry("examples-overview", "Examples Overview", "See how the example apps build on the fundamentals and where to go next.", SOURCE_ROOT.join("examples_overview.md"), "Learn")
        ]
      ),
      Section.new(
        id: "tutorials",
        title: "Tutorials",
        entries: [
          entry("tutorial-calculator", "Calculator", "Build a small Ruflet calculator and learn buttons, layout, and state updates.", SOURCE_ROOT.join("tutorial_calculator.md"), "Tutorials"),
          entry("tutorial-todo", "ToDo", "Build a task list with filters, mutations, and realistic view composition.", SOURCE_ROOT.join("tutorial_todo.md"), "Tutorials"),
          entry("tutorial-solitaire", "Solitaire", "Study a larger interactive Ruflet app with richer state and custom presentation.", SOURCE_ROOT.join("tutorial_solitaire.md"), "Tutorials"),
          entry("examples", "Example Gallery", "Find complete examples and guides for common Ruflet application features.", SOURCE_ROOT.join("examples.md"), "Tutorials")
        ]
      ),
      Section.new(
        id: "publishing",
        title: "Publishing",
        entries: [
          entry("build-and-release", "Build and Release", "Server-driven and self-contained builds, platform targets, assets, and release expectations.", SOURCE_ROOT.join("build_and_release.md"), "Publishing"),
          entry("publishing-android", "Android", "Package Android builds, configure release signing, and decide between server-driven and self-contained delivery.", SOURCE_ROOT.join("publishing_android.md"), "Publishing"),
          entry("publishing-ios", "iOS", "Prepare iOS builds and archives, configure signing, and set the right expectations for device testing.", SOURCE_ROOT.join("publishing_ios.md"), "Publishing"),
          entry("publishing-desktop", "Desktop", "Ship Ruflet apps for macOS, Windows, and Linux with one Ruby app layer.", SOURCE_ROOT.join("publishing_desktop.md"), "Publishing"),
          entry("publishing-web", "Web", "Run and ship Ruflet apps for the web with the same Ruby codebase.", SOURCE_ROOT.join("publishing_web.md"), "Publishing")
        ]
      ),
      Section.new(
        id: "integrations",
        title: "Integrations",
        entries: [
          entry("rails-integration", "Rails Integration", "Use Ruflet inside Rails with `ruflet_rails`, generated config, mounting, and app builds from Rails.", SOURCE_ROOT.join("rails_integration.md"), "Integrations"),
          entry("rails-erb-to-native", "ERB to Native", "Render Rails routes and ERB templates as real native Ruflet controls without a WebView.", SOURCE_ROOT.join("rails_erb_to_native.md"), "Integrations"),
          entry("rails-native-components", "Widgets", "Use every Ruflet widget from ERB with normal native tags or Rails view helpers.", SOURCE_ROOT.join("rails_native_components.md"), "Integrations", parent_slug: "rails-erb-to-native"),
          entry("rails-native-services", "Services", "Declare native services and invoke device capabilities from ERB-to-native screens.", SOURCE_ROOT.join("rails_native_services.md"), "Integrations", parent_slug: "rails-erb-to-native"),
          entry("rails-api-reference", "Rails API", "Public `ruflet_rails` methods, configuration, generator options, tasks, and view helpers.", SOURCE_ROOT.join("rails_api_reference.md"), "Integrations"),
          entry("rails-native-html", page_heading(SOURCE_ROOT.join("rails_native_html.md")), "Rails HTML in a native Ruflet shell, and how it compares with the other Rails modes.", SOURCE_ROOT.join("rails_native_html.md"), "Integrations"),
          entry("rails-native-styling", "Styling Rails Pages", "Style native-shell HTML with CSS, and ERB-to-native screens with Tailwind-style utility classes.", SOURCE_ROOT.join("rails_native_styling.md"), "Integrations"),
          entry("rails-native-interactivity", "Rails Navigation and Actions", "Use ordinary Rails links and forms with supported native-shell navigation annotations.", SOURCE_ROOT.join("rails_native_interactivity.md"), "Integrations"),
          entry("rails-assets", "Assets and URLs", "Resolve Rails asset URLs that a native Ruflet client can reach.", SOURCE_ROOT.join("rails_assets.md"), "Integrations"),
          entry("rails-native-shell", "Native Shell", "Wrap Rails views in a native shell and promote supported ERB-declared chrome and service actions.", SOURCE_ROOT.join("rails_webview_apps.md"), "Integrations"),
          entry("ruflet-record", "RufletRecord", "Store app data in SQLite with RufletRecord models, schema helpers, lazy queries and transactions.", SOURCE_ROOT.join("ruflet_record.md"), "Integrations")
        ]
      ),
      Section.new(
        id: "reference",
        title: "Reference",
        entries: [
          entry("reference", "API Reference", "Overview of Ruflet controls, services, CLI workflow, and app structure.", SOURCE_ROOT.join("reference.md"), "Reference"),
          entry("cli-reference", "CLI Reference", "Complete Ruflet CLI commands, options, defaults, hot reload controls, and diagnostics.", SOURCE_ROOT.join("cli_reference.md"), "Reference"),
          entry("events-and-state", "Events and State", "Handle control and Page events, read payloads, keep Ruby state, and patch mounted controls.", SOURCE_ROOT.join("events_and_state.md"), "Reference"),
          entry("configuration-reference", "Configuration", "Every supported `ruflet.yaml` and `services.yaml` key, extension, service, and environment override.", SOURCE_ROOT.join("configuration_reference.md"), "Reference")
        ]
      ),
      Section.new(
        id: "controls",
        title: "Widgets",
        entries: [
          entry("component-reference", "All Widgets", "Browse every Ruflet widget and open its properties, events, methods, and examples.", SOURCE_ROOT.join("component_reference.md"), "Widgets"),
          entry("controls-and-layout", "Controls and Layout", "How controls, containers, and the layout model fit together.", SOURCE_ROOT.join("controls_and_layout.md"), "Controls"),
          entry("navigation-feedback", "Navigation and Feedback", "Views, dialogs, snackbars, bottom sheets, and other navigation and feedback patterns.", SOURCE_ROOT.join("navigation_feedback.md"), "Controls"),
          entry("charts-and-canvas", "Charts and Canvas", "Bar, line, pie, scatter, candlestick, and radar charts, plus canvas drawing primitives.", SOURCE_ROOT.join("charts_and_canvas.md"), "Controls"),
          entry("maps", "Maps", "Interactive maps with tile layers, markers, circles, and shapes.", SOURCE_ROOT.join("maps.md"), "Controls"),
          *control_entries
        ]
      ),
      Section.new(
        id: "services",
        title: "Services",
        entries: [
          entry("services-and-plugins", "Services and Device APIs", "Use page convenience methods and persistent services to access client capabilities.", SOURCE_ROOT.join("services_and_plugins.md"), "Services"),
          *service_entries
        ]
      ),
      Section.new(
        id: "extensions",
        title: "Extensions",
        entries: [
          entry("extensions", "Extension Catalog", "Enable optional Ruflet client packages and find the Ruby APIs they provide.", SOURCE_ROOT.join("extensions.md"), "Extensions"),
          *extension_entries,
          entry("extension-authoring", "Extension Authoring", "Build typed Ruflet controls as Flutter packages that implement `RufletExtension`.", SOURCE_ROOT.join("extension_authoring.md"), "Extensions")
        ]
      )
    ]
  end

  def self.first
    sections.first.entries.first
  end

  def self.find(slug)
    sections.flat_map(&:entries).find { |entry| entry.slug == slug } || first
  end

  def self.all_entries
    sections.flat_map(&:entries)
  end

  def self.search_index
    all_entries.map do |entry|
      markdown = entry.content || (entry.source&.exist? ? entry.source.read : "")
      {
        slug: entry.slug,
        title: entry.title,
        summary: plain_inline_text(entry.summary).presence || first_paragraph(markdown),
        section: entry.section,
        url: Rails.application.routes.url_helpers.doc_path(entry.slug),
        text: [ entry.title, plain_inline_text(entry.summary).presence, entry.section, searchable_text(markdown) ].compact.join(" ")
      }
    end
  end

  def self.index_for(slug)
    all_entries.index { |entry| entry.slug == slug }
  end

  def self.previous_for(slug)
    index = index_for(slug)
    return nil unless index && index.positive?

    all_entries[index - 1]
  end

  def self.next_for(slug)
    index = index_for(slug)
    return nil unless index

    all_entries[index + 1]
  end

  def self.control_catalog
    @control_catalog ||= JSON.parse(CONTROL_CATALOG_PATH.read, symbolize_names: true).sort_by { |control| control[:title] }
  end

  def self.service_catalog
    @service_catalog ||= JSON.parse(SERVICE_CATALOG_PATH.read, symbolize_names: true)
  end

  def self.extension_catalog
    EXTENSION_CATALOG
  end

  def self.runtime_catalog
    @runtime_catalog ||= JSON.parse(RUNTIME_CATALOG_PATH.read, symbolize_names: true)
  end

  # Curated summaries and examples for controls that have no prose page,
  # keyed by slug: { "control-x": { "summary": "...", "example": ["line", ...] } }.
  def self.control_docs
    @control_docs ||= CONTROL_DOCS_PATH.exist? ? JSON.parse(CONTROL_DOCS_PATH.read) : {}
  end

  # Control slugs and service helpers that exist only on Ruflet main.
  def self.next_release
    @next_release ||= begin
      config = NEXT_RELEASE_PATH.exist? ? JSON.parse(NEXT_RELEASE_PATH.read) : {}
      {
        controls: Array(config["controls"]),
        services: Array(config["services"]),
        members: config.fetch("members", {}),
        client_ignored: config.fetch("client_ignored", {}),
        design_client_ignored: config.fetch("design_client_ignored", {})
      }
    end
  end

  # The inline marker for one generated property, event or method line of a
  # control that exists in 0.0.23, or nil when the line works on 0.0.23.
  # "client_ignored" lists names as an array, or as a hash of name => note
  # for a line whose 0.0.23 client does only part of what it describes (for
  # example an event it sends without some of its data).
  def self.next_release_note(slug, kind, name)
    ignored = next_release[:client_ignored].dig(slug, kind)
    if Array(next_release[:members].dig(slug, kind)).include?(name)
      "#{NEXT_RELEASE_MARKER}."
    elsif ignored.is_a?(Hash) && ignored.key?(name)
      "#{ignored[name]} #{NEXT_RELEASE_MARKER}."
    elsif !ignored.is_a?(Hash) && Array(ignored).include?(name)
      "#{NEXT_RELEASE_CLIENT_NOTES.fetch(kind)} #{NEXT_RELEASE_MARKER}."
    elsif (note = design_client_note(slug, kind, name))
      "#{note} #{NEXT_RELEASE_MARKER}."
    end
  end

  # True when 0.0.23 rejects the line or ignores it on every platform
  # ("members" and the "client_ignored" arrays); a "design_client_ignored"
  # line still works on the other design, and a "client_ignored" name with a
  # note of its own still partly works on 0.0.23.
  def self.next_release_everywhere?(slug, kind, name)
    %i[members client_ignored].any? do |list|
      names = next_release[list].dig(slug, kind)
      !names.is_a?(Hash) && Array(names).include?(name)
    end
  end

  # "design_client_ignored" lists names per design as an array, or as a hash
  # of name => note when the generic note is not exact (for example a row
  # control that works in one parent table and not in another).
  def self.design_client_note(slug, kind, name)
    next_release[:design_client_ignored].each do |design, controls|
      names = controls.dig(slug, kind)
      next unless names.is_a?(Hash) ? names.key?(name) : Array(names).include?(name)

      return names[name] if names.is_a?(Hash)

      return "#{NEXT_RELEASE_DESIGN_PLATFORMS.fetch(design)}, #{NEXT_RELEASE_DESIGN_NOTES.fetch(kind)}"
    end
    nil
  end

  # Puts the callout under the H1 unless the page already has one. Generated
  # property descriptions may carry the inline marker, so look for the
  # blockquote form only.
  def self.with_next_release_callout(markdown, consequence)
    return markdown if markdown.include?("> #{NEXT_RELEASE_MARKER}")

    callout = "> #{NEXT_RELEASE_MARKER}. #{consequence}"
    lines = markdown.lines
    heading = lines.index { |line| line.start_with?("# ") }
    return "#{callout}\n\n#{markdown}" unless heading

    before = lines[0..heading].join.chomp
    after = lines[(heading + 1)..].join.sub(/\A\n+/, "")
    "#{before}\n\n#{callout}\n\n#{after}"
  end

  def self.entry(slug, title, summary, source, section, content = nil, parent_slug: nil)
    Entry.new(
      slug: slug,
      title: title,
      summary: summary,
      source: source,
      section: section,
      content: content,
      parent_slug: parent_slug
    )
  end

  def self.first_paragraph(markdown)
    markdown.to_s
            .split(/\n{2,}/)
            .map { |block| clean_markdown(block) }
            .find(&:present?)
  end

  # The H1 of a hand-written page, so a nav title cannot drift from the page.
  def self.page_heading(path)
    path.read[/^# (.+)$/, 1].to_s.strip
  end

  # Search results show summaries as escaped text, so drop inline Markdown
  # (links and code spans) but keep the words.
  def self.plain_inline_text(text)
    text.to_s.gsub(/\[([^\]]+)\]\([^)]+\)/, '\1').gsub(/`([^`]+)`/, '\1')
  end

  def self.searchable_text(markdown)
    clean_markdown(markdown.to_s)
  end

  def self.clean_markdown(markdown)
    markdown
      .gsub(/```.*?```/m, " ")
      .gsub(/`([^`]+)`/, '\1')
      .gsub(/!\[[^\]]*\]\([^)]+\)/, " ")
      .gsub(/\[([^\]]+)\]\([^)]+\)/, '\1')
      .gsub(/[#>*_\-]+/, " ")
      .squish
  end

  def self.control_entries
    control_catalog.map do |control|
      source = source_for_slug(control[:slug])
      content = if source
        "#{source.read.rstrip}\n\n#{generated_control_api_appendix(control)}"
      else
        generated_control_markdown(control)
      end
      if next_release[:controls].include?(control[:slug])
        content = with_next_release_callout(content, NEXT_RELEASE_CONSEQUENCES.fetch(:controls))
      end
      summary = source ? nil : generated_control_summary(control)
      entry(control[:slug], control[:title], summary, nil, "Widgets", content)
    end
  end

  def self.service_entries
    service_catalog.fetch(:services).sort_by { |service| service[:title] }.map do |service|
      helper = service.fetch(:helper)
      content = generated_service_markdown(service)
      if next_release[:services].include?(helper)
        content = with_next_release_callout(content, format(NEXT_RELEASE_CONSEQUENCES.fetch(:services), helper: helper))
      end
      # A service added by script/sync_ruflet_api before its summary is written
      # still renders; docs_coverage_test.rb fails on the generic text.
      summary = SERVICE_SUMMARIES.fetch(helper) { "Complete `page.#{helper}` service reference." }
      entry("service-#{helper.tr('_', '-')}", service[:title], summary, nil, "Services", content)
    end
  end

  def self.extension_entries
    extension_catalog.reject { |extension| Array(extension[:services]).any? }.sort_by { |extension| extension[:title] }.map do |extension|
      if extension[:guide]
        entry(extension[:guide], extension[:title], extension[:summary], SOURCE_ROOT.join("control_qrcode_scanner.md"), "Extensions")
      else
        entry("extension-#{extension[:key].tr('_', '-')}", extension[:title], extension[:summary], nil, "Extensions", generated_extension_markdown(extension))
      end
    end
  end

  def self.generated_service_markdown(service)
    helper = service.fetch(:helper)
    extension = extension_catalog.find { |candidate| Array(candidate[:services]).include?(helper) }
    accessor_takes_properties = Array(service.dig(:page_accessor, :parameters)).any?
    intro = if accessor_takes_properties
      "Create or retrieve this service with `page.#{helper}(**properties)`. Ruflet reuses the registered service unless you supply a different `id`."
    else
      "Create or retrieve this service with `page.service(:#{helper})`, or declare it with the `#{helper}` DSL helper. `page.#{helper}` itself reads the page's `#{helper}` view property and does not create the service."
    end
    lines = [
      "# #{service.fetch(:title)} service", "",
      intro, "",
      "## Example", "", "```ruby", *service_example(service), "```", "",
      "## Page accessor", "", "- `page.#{format_api_method(service.fetch(:page_accessor))}`", "",
      "## Properties", ""
    ]
    Array(service[:properties]).each { |property| lines << describe(property, "properties") }
    lines << "- None." if Array(service[:properties]).empty?
    lines << ""
    if Array(service[:events]).any?
      lines.concat([ "## Events", "" ])
      Array(service[:events]).each { |event| lines << describe(event, "events") }
      lines << ""
    end
    methods = Array(service[:methods])
    if methods.any?
      lines.concat([ "## Service methods", "" ])
      methods.each { |method| lines << "- `#{format_api_method(method)}`" }
      lines << ""
    end
    proxies = Array(service[:proxy_methods])
    if proxies.any?
      lines.concat([ "## Page proxy methods", "", "Calling `page.#{helper}` with no properties returns a focused proxy with these methods:", "" ])
      proxies.each { |method| lines << "- `#{format_api_method(method)}`" }
      lines << ""
    end
    convenience_methods = SERVICE_CONVENIENCE_METHODS.fetch(helper, []).filter_map do |name|
      runtime_catalog.fetch(:page).find { |method| method[:name] == name }
    end
    if convenience_methods.any?
      lines.concat([ "## Page convenience methods", "", "Use these one-shot Page calls when you do not need to keep the service object:", "" ])
      convenience_methods.each { |method| lines << "- `page.#{format_api_method(method)}`" }
      lines << ""
    end
    lines.concat([
      "## Result and error handling", "",
      "Client calls are asynchronous. When a method accepts `on_result:`, handle both callback values: `|result, error|`. Availability and returned data can vary by platform.", "",
      "## Common service API", "",
      "The service also supports the common Ruflet control API: #{service_catalog.fetch(:common_control_methods).map { |method| "`#{format_api_method(method)}`" }.join(', ')}.", "",
      "Use the named methods above for application code; common control methods mainly support event registration, updates, and runtime integration.", "",
      "## Wire reference", "",
      "- Service helper: `#{helper}`",
      "- Wire type: `#{service.fetch(:widget_type)}`"
    ])
    aliases = Array(service[:aliases])
    lines << "- Aliases: #{aliases.map { |name| "`#{name}`" }.join(', ')}" if aliases.any?
    if extension
      lines.concat([
        "", "## Client extension setup", "",
        "This service is implemented by the `#{extension.fetch(:package)}` client extension. Enable it in `ruflet.yaml`, then rebuild the client:", "",
        "```yaml", "extensions:", "  - #{extension.fetch(:key)}", "```", "",
        "Application code uses `page.#{helper}`; do not add the package directly to your app's Flutter dependencies."
      ])
      required = (Array(extension[:required_services]) + SERVICE_PROTECTED_ACCESS.fetch(helper, [])).uniq
      if required.any?
        lines.concat([ "", "Declare protected access in `services.yaml`:", "", "```yaml", "services:" ])
        required.each { |name| lines << "  - #{name}:" << "      description: Explain why your app needs #{name.tr('_', ' ')} access." }
        lines << "```"
      end
    elsif SERVICE_PROTECTED_ACCESS.key?(helper)
      lines.concat([ "", "## Protected device access", "", "Declare motion access in `services.yaml`, then rebuild the native client:", "", "```yaml", "services:", "  - motion:", "      description: Explain why your app reads motion sensor data.", "```" ])
    end
    lines.join("\n")
  end

  def self.service_example(service)
    SERVICE_EXAMPLES.fetch(service.fetch(:helper)).lines(chomp: true)
  end

  def self.generated_extension_markdown(extension)
    lines = [
      "# #{extension.fetch(:title)} extension", "", extension.fetch(:summary), "",
      "## Enable the extension", "", "Add the extension key to `ruflet.yaml`:", "", "```yaml", "extensions:", "  - #{extension.fetch(:key)}", "```", "",
      "Run `ruflet run` during development or `ruflet build <target>` for a release. Extension packages are compiled into the Ruflet client, so rebuild the client after changing this list.", "",
      "## Ruby DSL example", "", "```ruby", extension.fetch(:example), "```", "",
      "## API provided", "",
      "- Extension key: `#{extension.fetch(:key)}`",
      "- Client package: `#{extension.fetch(:package)}`",
      "- Kind: #{extension.fetch(:kind)}"
    ]
    Array(extension[:controls]).each do |slug|
      control = control_catalog.find { |candidate| candidate[:slug] == slug }
      lines << "- [#{control ? control[:title] : slug} control reference](/docs/#{slug}) — complete helpers, properties, events, and methods."
    end
    Array(extension[:services]).each do |helper|
      service = service_catalog.fetch(:services).find { |candidate| candidate[:helper] == helper }
      lines << "- [#{service ? service[:title] : helper} service reference](/docs/service-#{helper.tr('_', '-')}) — complete properties, events, and callable methods."
    end
    if Array(extension[:wire_types]).any?
      lines << "- Wire controls: #{Array(extension[:wire_types]).map { |name| "`#{name}`" }.join(', ')}"
    end
    if Array(extension[:properties]).any?
      lines.concat([ "", "## Properties", "" ])
      Array(extension[:properties]).each { |property| lines << describe(property, "properties") }
    end
    if Array(extension[:events]).any?
      lines.concat([ "", "## Events", "" ])
      Array(extension[:events]).each { |event| lines << describe(event, "events") }
    end
    lines.concat([ "", "## Permissions and platforms", "" ])
    lines.concat([ extension[:platforms], "" ]) if extension[:platforms]
    required = Array(extension[:required_services])
    if required.any?
      lines << "This extension uses protected device access. Declare it in `services.yaml` with a user-facing explanation:"
      lines.concat([ "", "```yaml", "services:" ])
      required.each { |service| lines << "  - #{service}:" << "      description: Explain why your app needs #{service.tr('_', ' ')} access." }
      lines.concat([ "```", "", "Request access when the user starts the related action. Android, Apple platforms, desktop, and web can differ in capability and permission behavior; handle errors and unsupported results." ])
    elsif extension[:platforms]
      lines << "This extension needs no protected service declaration."
    else
      lines << "No protected service declaration is added automatically. Platform support still follows the underlying Flutter plugin, so test every target you ship."
    end
    lines.concat([ "", "## Build behavior", "", "Ruflet resolves the extension key to `#{extension.fetch(:package)}` and includes that package through the client extension pipeline. Application code uses the Ruby DSL shown above; do not add the package directly to your app's Flutter dependencies." ])
    lines.join("\n")
  end

  def self.source_for_slug(slug)
    path = SOURCE_ROOT.join("#{slug.tr('-', '_')}.md")
    path.exist? ? path : nil
  end

  def self.generated_control_summary(control)
    curated = control_docs.dig(control[:slug], "summary")
    return curated if curated.present?

    family = control[:family].to_s.sub(/s\z/, "").capitalize
    "#{family} control for Ruflet applications."
  end

  COMMON_PROPERTIES_PATH = Rails.root.join("config/control_common_properties.json")

  # Layout/animation properties shared by most controls — listed once as a note
  # rather than repeated on every page.
  def self.common_properties
    @common_properties ||=
      if COMMON_PROPERTIES_PATH.exist?
        JSON.parse(COMMON_PROPERTIES_PATH.read)
      else
        []
      end
  end

  # Ordered list of meaningful properties to reach for when building a sample.
  EXAMPLE_PROPERTY_PRIORITY = %w[
    value label text content title subtitle src url icon leading trailing
    options selected checked min max divisions password multiline color bgcolor
    open expand width height
  ].freeze

  PROPERTY_DESCRIPTIONS_PATH = Rails.root.join("config/property_descriptions.json")

  # Shared descriptions for properties/events that recur across controls, so
  # every page explains what each attribute does (not just its name).
  def self.attribute_descriptions
    @attribute_descriptions ||=
      if PROPERTY_DESCRIPTIONS_PATH.exist?
        JSON.parse(PROPERTY_DESCRIPTIONS_PATH.read)
      else
        { "properties" => {}, "events" => {} }
      end
  end

  # `widget_overrides` holds descriptions that differ for one wire type, for
  # example SnackBar's `action` label versus the buttons' client `action:`.
  def self.describe(name, kind, control = nil)
    desc = control && attribute_descriptions.dig("widget_overrides", control[:widget_type].to_s, name.to_s)
    desc ||= attribute_descriptions[kind]&.[](name.to_s) || heuristic_description(name.to_s, kind)
    desc ||= "Sets the #{name.to_s.tr('_', ' ')} property." if kind == "properties"
    desc ||= "Fired when #{name.to_s.sub(/\Aon_/, '').tr('_', ' ')} occurs." if kind == "events"
    note = control && next_release_note(control[:slug], kind, name.to_s)
    desc = "#{desc} #{note}" if note
    "- `#{name}` — #{desc}"
  end

  # Derive a description for common naming patterns so more attributes are
  # explained without an explicit entry.
  def self.heuristic_description(name, kind)
    if kind == "events" && name.start_with?("on_")
      return "Fired on #{name.sub(/\Aon_/, '').tr('_', ' ')}."
    end

    return "Animates #{Regexp.last_match(1).tr('_', ' ')} changes." if name =~ /\Aanimate_(.+)/

    %w[color text style icon radius padding alignment width height bgcolor].each do |suffix|
      next unless name =~ /\A(.+)_#{suffix}\z/

      prefix = Regexp.last_match(1).tr("_", " ")
      word = suffix == "bgcolor" ? "background color" : suffix
      return "#{prefix.capitalize} #{word}."
    end

    nil
  end

  def self.generated_control_markdown(control)
    helper = preferred_helper(control)
    props = Array(control[:properties]).map(&:to_s)
    events = Array(control[:events]).map(&:to_s)
    common = props & common_properties
    specific = props - common

    lines = []
    curated = control_docs[control[:slug]]

    lines << "# #{control[:title]}"
    lines << ""
    lines << (curated ? curated.fetch("summary") : "#{control[:title]} control. Build it with the `#{helper}` helper.")
    lines << ""

    # --- Example ----------------------------------------------------------
    lines << "## Example"
    lines << ""
    lines << "```ruby"
    lines.concat(curated ? Array(curated.fetch("example")) : generated_control_example(control, helper))
    lines << "```"
    lines << ""

    # --- Properties -------------------------------------------------------
    lines << "## Properties"
    lines << ""
    if specific.any?
      specific.each { |property| lines << describe(property, "properties", control) }
    end
    if common.any?
      lines << "" if specific.any?
      lines << "### Common layout and animation properties"
      lines << ""
      common.each { |property| lines << describe(property, "properties", control) }
    end
    if props.empty?
      lines << "- See the control definition for the full property list."
    end
    lines << ""

    # --- Events -----------------------------------------------------------
    if events.any?
      lines << "## Events"
      lines << ""
      events.each { |event| lines << describe(event, "events", control) }
      lines << ""
    end

    append_control_methods(lines, control)

    # --- Reference --------------------------------------------------------
    lines << "## Reference"
    lines << ""
    lines << "- Family: `#{control[:family]}`"
    lines << "- Widget type: `#{control[:widget_type]}`"
    lines << "- Helpers: #{Array(control[:helpers]).map { |name| "`#{name}`" }.join(', ')}"
    lines.join("\n")
  end

  def self.generated_control_api_appendix(control)
    lines = [ "## Complete API", "" ]
    lines << "### Helpers"
    lines << ""
    helper_signatures = Array(control[:helper_signatures])
    if helper_signatures.any?
      helper_signatures.each { |helper| lines << "- `#{format_api_method(helper)}`" }
    else
      Array(control[:helpers]).each { |helper| lines << "- `#{helper}`" }
    end
    lines << ""
    lines << "### Accepted properties"
    lines << ""
    Array(control[:properties]).each { |property| lines << describe(property, "properties", control) }
    lines << "- None." if Array(control[:properties]).empty?
    lines << ""
    if Array(control[:events]).any?
      lines << "### Events"
      lines << ""
      Array(control[:events]).each { |event| lines << describe(event, "events", control) }
      lines << ""
    end
    append_control_methods(lines, control, heading: "### Methods")
    lines << "### Wire reference"
    lines << ""
    lines << "- Family: `#{control[:family]}`"
    lines << "- Widget type: `#{control[:widget_type]}`"
    lines.join("\n")
  end

  def self.append_control_methods(lines, control, heading: "## Methods")
    methods = Array(control[:methods])
    return if methods.empty?

    lines << heading
    lines << ""
    methods.each do |method|
      name = (method[:name] || method["name"]).to_s
      # `method_notes` qualifies a method on one wire type, for example one
      # that a design cannot run.
      description = attribute_descriptions.dig("method_notes", control[:widget_type].to_s, name)
      note = next_release_note(control[:slug], "methods", name)
      signature = "- `#{format_api_method(method)}`"
      signature = "#{signature} — #{description}" if description
      lines << [ signature, note ].compact.join(" ")
    end
    lines << ""
  end

  def self.format_api_method(method)
    name = method[:name] || method["name"]
    parameters = method[:parameters] || method["parameters"] || []
    formatted = parameters.map do |kind, argument|
      case kind.to_s
      when "req" then argument
      when "opt" then "#{argument} = ..."
      when "rest" then "*#{argument}"
      when "keyreq" then "#{argument}:"
      when "key" then "#{argument}: ..."
      when "keyrest" then "**#{argument}"
      when "block" then "&#{argument}"
      end
    end.compact.join(", ")
    formatted.empty? ? name : "#{name}(#{formatted})"
  end

  def self.preferred_helper(control)
    helpers = Array(control[:helpers]).uniq
    raise "No public helper documented for #{control[:widget_type]}" if helpers.empty?

    helpers.find { |name| name.include?("_") } || helpers.first
  end

  def self.generated_control_example(control, helper)
    crafted = crafted_control_example(control[:widget_type])
    return crafted if crafted

    prop_lines = example_property_lines(control)

    return [ "#{helper}()" ] if prop_lines.empty?

    open = "#{helper}("
    body = prop_lines.each_with_index.map do |line, index|
      "  #{line}#{index < prop_lines.length - 1 ? ',' : ''}"
    end
    [ open, *body, ")" ]
  end

  def self.crafted_control_example(widget_type)
    {
      "option" => [
        'dropdown_option("ruby", text: "Ruby")'
      ],
      "autofillgroup" => [
        "autofill_group(",
        '  text_field(label: "Email", autofill_hints: ["email"])',
        ")"
      ],
      "browsercontextmenu" => [
        "page.browser_context_menu(disabled: true)"
      ],
      "fillediconbutton" => [
        "filled_icon_button(",
        '  icon: "add",',
        '  tooltip: "Add item",',
        "  on_click: ->(event) {}",
        ")"
      ],
      "filledtonaliconbutton" => [
        "filled_tonal_icon_button(",
        '  icon: "favorite",',
        '  selected_icon: "favorite",',
        "  selected: true,",
        "  on_click: ->(event) {}",
        ")"
      ],
      "hero" => [
        "hero(",
        '  image("assets/logo.png"),',
        '  tag: "app-logo"',
        ")"
      ],
      "outlinediconbutton" => [
        "outlined_icon_button(",
        '  icon: "search",',
        '  tooltip: "Search",',
        "  on_click: ->(event) {}",
        ")"
      ],
      "lottie" => [
        "lottie(",
        '  src: "assets/success.json",',
        "  repeat: true,",
        "  on_load: ->(event) {}",
        ")"
      ],
      "markerlayer" => [
        "office = [51.505, -0.09]",
        "",
        "markers = marker_layer([",
        "  marker(",
        '    icon("location_on", color: :red600),',
        "    coordinates: office,",
        "    width: 44,",
        "    height: 44",
        "  )",
        "])",
        "",
        "page.add(",
        "  map(",
        "    [",
        '      tile_layer(url_template: "https://tile.openstreetmap.org/{z}/{x}/{y}.png"),',
        "      markers",
        "    ],",
        "    initial_center: office,",
        "    initial_zoom: 13,",
        "    expand: true",
        "  )",
        ")"
      ],
      "menubar" => [
        "file_menu = submenu_button(",
        "  [",
        "    menu_item_button(",
        '      "Open",',
        '      leading: icon("folder_open"),',
        "      on_click: ->(event) {}",
        "    ),",
        "    menu_item_button(",
        '      "Save",',
        '      leading: icon("save"),',
        "      on_click: ->(event) {}",
        "    )",
        "  ],",
        '  content: text("File")',
        ")",
        "",
        "page.add(menu_bar([file_menu]))"
      ],
      "nestedscrollview" => [
        "nested_scroll_view(",
        '  [sliver_app_bar(title: text("Inbox"), pinned: true, expanded_height: 160)],',
        '  body: list_view((1..30).map { |n| list_tile(title: text("Message #{n}")) }),',
        "  expand: true",
        ")"
      ],
      "overlay" => [
        "overlay([",
        "  progress_ring(),",
        '  snack_bar("Saved")',
        "])"
      ],
      "polygonmarker" => [
        "service_area = polygon_marker(",
        "  coordinates: [",
        "    [51.51, -0.12],",
        "    [51.50, -0.06],",
        "    [51.48, -0.09]",
        "  ],",
        '  color: "#3b82f6,0.2",',
        "  border_color: :blue600,",
        "  border_stroke_width: 2,",
        '  label: "Service area"',
        ")",
        "",
        "page.add(",
        "  map(",
        "    [",
        '      tile_layer(url_template: "https://tile.openstreetmap.org/{z}/{x}/{y}.png"),',
        "      polygon_layer([service_area])",
        "    ],",
        "    initial_center: [51.50, -0.09],",
        "    initial_zoom: 12,",
        "    expand: true",
        "  )",
        ")"
      ],
      "shadermask" => [
        "shader_mask(",
        '  text(value: "Ruflet", style: { size: 36 }),',
        '  blend_mode: "srcIn"',
        ")"
      ],
      "shimmer" => [
        "shimmer(",
        "  container(width: 240, height: 80, bgcolor: \"#d1d5db\"),",
        '  base_color: "#d1d5db",',
        '  highlight_color: "#f9fafb"',
        ")"
      ],
      "textspan" => [
        "text_span(",
        '  "Ruflet documentation",',
        '  url: "https://ruflet.dev"',
        ")"
      ]
    }[widget_type.to_s]
  end

  def self.example_property_lines(control)
    props = Array(control[:properties]).map(&:to_s)
    events = Array(control[:events]).map(&:to_s)

    # The example must show what it sets with 0.0.23: leave out what 0.0.23
    # rejects or ignores on every platform (config/next_release.json).
    events.reject! { |name| next_release_everywhere?(control[:slug], "events", name) }
    event = %w[on_click on_change on_tap on_submit].find { |e| events.include?(e) } || events.first

    candidates = EXAMPLE_PROPERTY_PRIORITY.select { |p| props.include?(p) }
    candidates -= [ "url" ] if event == "on_click"
    candidates.reject! { |property| next_release_everywhere?(control[:slug], "properties", property) }
    chosen = candidates.first(4)
    lines = chosen.filter_map { |property| sample_value_for(property, control[:title]) }

    # Add one representative event handler if the control has any.
    lines << "#{event}: ->(event) {}" if event

    lines
  end

  def self.sample_value_for(property, title)
    case property
    when "title"        then 'title: text("Title")'
    when "subtitle"     then 'subtitle: text("Subtitle")'
    when "content"      then "content: text(#{title.inspect})"
    when "controls"
      # `controls` is the wire prop; the helper DSL takes `children:`.
      "children: []"
    when "children", "actions", "tabs", "destinations", "options"
      "#{property}: []"
    when "icon", "leading_icon", "trailing_icon", "selected_trailing_icon", "select_icon"
      "#{property}: \"add\""
    when "leading"      then 'leading: icon("menu")'
    when "trailing"     then 'trailing: icon("chevron_right")'
    when "label", "hint_text", "helper_text", "cancel_text", "confirm_text"
      "#{property}: #{property.tr('_', ' ').capitalize.inspect}"
    when "value"        then 'value: "Sample"'
    when "text"         then 'text: "Sample"'
    when "src"          then 'src: "https://example.com/image.png"'
    when "url"          then 'url: "https://example.com"'
    when "selected", "checked", "open" then "#{property}: true"
    when "password", "multiline"       then "#{property}: true"
    when "min"          then "min: 0"
    when "max"          then "max: 100"
    when "divisions"    then "divisions: 10"
    when "color"        then "color: :blue_600"
    when "bgcolor"      then "bgcolor: :surface_container_high"
    when "width"        then "width: 240"
    when "height"       then "height: 120"
    when "expand"       then "expand: true"
    end
  end

  private_class_method :entry, :control_entries, :source_for_slug, :generated_control_summary,
                       :service_entries, :extension_entries, :generated_service_markdown,
                       :generated_extension_markdown, :service_example,
                       :generated_control_markdown, :preferred_helper, :generated_control_example,
                       :crafted_control_example, :example_property_lines, :sample_value_for, :common_properties,
                       :attribute_descriptions, :describe, :heuristic_description,
                       :generated_control_api_appendix, :append_control_methods, :format_api_method,
                       :with_next_release_callout, :next_release_note, :next_release_everywhere?, :plain_inline_text,
                       :page_heading
end
