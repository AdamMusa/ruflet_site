# Rails Navigation and Actions

`Ruflet::Rails.native_app` hosts normal Rails pages. Links and forms therefore
keep their normal browser behavior unless a supported view helper adds a
native-shell annotation.

## Links and forms

Use Rails paths, methods, CSRF protection, redirects, validations, and Turbo as
you normally would. Keep a real `href` on annotated links so the page remains
usable in an ordinary browser.

```erb
<%= link_to "Account", account_path %>

<%= form_with model: @account do |form| %>
  <%= form.email_field :email %>
  <%= form.submit "Save" %>
<% end %>
```

## Native navigation annotations

App-bar, drawer, rail, and bottom-navigation item helpers emit URLs and native
navigation metadata:

```erb
<%= ruflet_appbar_action "settings", settings_path, nav: :push %>
<%= ruflet_drawer_item "Home", root_path, icon: "home", nav: :root %>
```

Use `:push` when the destination should join the native view stack. Use a root
action for top-level destinations. Derive `selected:` from the current Rails
route so native chrome stays synchronized after a page load.

## Platform actions

Use the supported share, copy, launch, and haptic helpers for actions that the
native shell should intercept. Each still emits an ordinary link or button for
the browser rendering.

See [WebView Apps](/docs/rails-webview-apps) and
[Rails API Reference](/docs/rails-api-reference) for the WebView shell. For
native widgets rendered from ERB instead, see
[ERB to Native](/docs/rails-erb-to-native).
