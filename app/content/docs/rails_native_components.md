# Rails View Helpers

`ruflet_rails` includes helpers in Action View. `ruflet_frame` embeds a mounted
Ruflet web app. The other helpers emit ordinary HTML plus annotations read by
`Ruflet::Rails.native_app`.

## Embed a Ruflet web app

```erb
<%= ruflet_frame "/ruflet", height: 640, width: "100%", title: "Ruflet app" %>
```

`ruflet_frame` also accepts `style:` and extra iframe attributes.

## App bar

```erb
<%= ruflet_appbar "Inbox" do %>
  <%= ruflet_appbar_action "search", search_path, nav: :push %>
<% end %>
```

`ruflet_appbar` accepts `payload:`, `leading:`, `actions:`, and HTML
attributes. App-bar actions accept an icon, optional URL, `nav:`, and payload.

## Bottom navigation

```erb
<%= ruflet_bottom_nav do %>
  <%= ruflet_nav_item "Home", root_path, icon: "home", selected: current_page?(root_path) %>
  <%= ruflet_nav_item "Account", account_path, icon: "person" %>
<% end %>
```

Items require `label`, `href`, and `icon:`. They also accept `selected:`,
`color:`, `size:`, and `payload:`.

## Drawer and navigation rail

```erb
<%= ruflet_drawer do %>
  <%= ruflet_drawer_item "Home", root_path, icon: "home" %>
  <%= ruflet_drawer_item "Settings", settings_path, icon: "settings", nav: :push %>
<% end %>

<%= ruflet_navigation_rail extended: true, breakpoint: 720 do %>
  <%= ruflet_rail_item "Inbox", inbox_path, icon: "mail" %>
<% end %>
```

`ruflet_rail` is an alias for `ruflet_navigation_rail`. Use Rails route state
to set `selected:` on destination helpers.

## Platform actions

The view helpers for share, clipboard, URL launching, and haptics are covered
in [Rails Service Actions](/docs/rails-native-services).

See [Rails API Reference](/docs/rails-api-reference) for every signature and
default.
