# Services and Plugins

Ruflet supports two kinds of non-trivial platform capabilities:

- built-in page/runtime services that are already exercised in the repo
- optional client extensions enabled through `ruflet.yaml`

Understanding the difference helps a lot when planning an app.

## Built-in page and device APIs

The current repo demonstrates these page-level capabilities:

- Clipboard: `page.set_clipboard`, `page.set_clipboard_image`, `page.set_clipboard_files`, `page.get_clipboard_files`, `page.get_clipboard_image`
- File system pickers: `page.pick_files`, `page.save_file`, `page.get_directory_path`
- URL launching: `page.launch_url`
- Connectivity: `page.service(:connectivity)`, `page.get_connectivity`
- Battery: `page.service(:battery)`, `page.get_battery_level`, `page.get_battery_state`, `page.battery_save_mode?`
- Camera: `page.service(:camera)`
- Flashlight: `page.service(:flashlight)`
- Storage paths: `page.service(:storage_paths)`
- Share: demonstrated in Ruflet Studio

## Media and embedded experiences

Ruflet Studio also demonstrates control/service-driven integrations for:

- audio
- video
- web view

These are the kinds of capabilities that make Ruflet more than a basic widget wrapper.

## Optional client extensions in `ruflet.yaml`

The Ruflet CLI currently recognizes these service keys for generated/client-enabled extensions:

- `ads`
- `audio`
- `audio_recorder`
- `camera`
- `charts`
- `code_editor`
- `color_pickers`
- `datatable2`
- `flashlight`
- `geolocator`
- `lottie`
- `map`
- `permission_handler`
- `secure_storage`
- `video`
- `webview`

Example config:

```yaml
services:
  - camera
  - video
  - webview
  - secure_storage
```

## How to think about these features

- Use built-in page APIs for things already modeled directly by the runtime.
- Use `services:` in `ruflet.yaml` when the Flutter client needs extra packages or capabilities baked into the app build.
- Validate service needs early if you plan to ship iOS or Android builds, since permissions and platform packaging can influence your build setup.

## Repo-backed examples you can copy from

- Connectivity: get current network state
- Battery: read level, state, and saver mode
- Camera: discover and initialize available cameras
- File Picker: choose files, pick directories, and save file destinations
- Clipboard: copy text, copy file references, and read clipboard image payloads
- WebView: embed a remote page inside the app
- Audio and Video: play media and invoke service methods from Ruby
