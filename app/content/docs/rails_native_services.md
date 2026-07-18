# Services and Extensions

Native HTML screens can reach the device. Declare a platform service or an
extension control with a tag — each has a matching helper.

## Platform services

Services are non-visual: the camera, GPS, battery, clipboard, and sensors don't
render anything. Declaring one on a screen mounts it on the client's service
registry so it is available while the screen is showing.

```erb
<%= camera %>
<%= geolocator %>
<%= battery %>
```

Available services:

- media and hardware: `camera`, `audio_recorder`, `flashlight`,
  `haptic_feedback`, `wakelock`, `screen_brightness`
- location and sensors: `geolocator`, `accelerometer`, `gyroscope`,
  `magnetometer`, `barometer`, `user_accelerometer`, `shake_detector`
- data and system: `clipboard`, `secure_storage`, `shared_preferences`,
  `storage_paths`, `file_picker`, `battery`, `connectivity`,
  `permission_handler`
- sharing and links: `share`, `url_launcher`

Because a service renders nothing, it is left out of the visible layout — mount
it anywhere in the screen:

```erb
<appbar title="Camera"></appbar>
<%= camera %>
<%= permission_handler %>

<column class="p-6 gap-4">
  <text>Ready to capture.</text>
</column>
```

## Extension controls

Extensions are visible controls that render inline like any other:

- media: `<audio>`, `<video>`
- graphics: `<lottie src="…">`, `<rive>`, `<color-picker>`
- content: `<code-editor language="ruby">…</code-editor>`, `<map>`
- charts: `<bar-chart>`, `<line-chart>`, `<pie-chart>`, `<scatter-chart>`,
  `<candlestick-chart>`, `<radar-chart>`

```erb
<%= code_editor "puts 'Hello from Ruflet'", language: "ruby", height: 120 %>

<%= container class: "h-64 rounded-xl overflow-hidden" do %>
  <%= map expand: true do %>
    <%= widget "tile-layer", url_template: "https://tile.openstreetmap.org/{z}/{x}/{y}.png" %>
  <% end %>
<% end %>
```

Use each control's real attributes — for example `<video>` takes a `playlist`,
and a chart takes `groups`. A wrong attribute renders a small inline placeholder
instead of crashing the screen, so mistakes are easy to spot.

## Related guides

- [Native HTML Apps](/docs/rails-native-html)
- [Components](/docs/rails-native-components)
- [Navigation and Forms](/docs/rails-native-interactivity)
