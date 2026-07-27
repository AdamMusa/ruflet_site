# Styling Rails Pages

Pages displayed by `Ruflet::Rails.native_app` remain HTML inside a WebView.
Style them with the same CSS, asset pipeline, import maps, JavaScript, and
responsive techniques used by the browser version of the Rails application.

## Design for the shell

- Keep body content responsive because the native shell can add an app bar,
  drawer, navigation rail, or bottom navigation around it.
- Use normal Rails asset helpers for stylesheets and images.
- Avoid duplicating visible HTML navigation that is also promoted to native
  chrome. Ruflet view helpers mark promoted elements as hidden.
- Test safe areas, keyboard resizing, text scaling, and narrow device widths.
- Use reachable absolute URLs for resources loaded outside the WebView.

```erb
<main class="account-page">
  <h1>Account</h1>
  <%= image_tag "profile-placeholder.png", alt: "" %>
  <%= form_with model: @account do |form| %>
    <%= form.email_field :email %>
    <%= form.submit "Save" %>
  <% end %>
</main>
```

Ruflet does not interpret utility classes as native control properties in this
release. If the screen must be a native control tree, build it with Ruflet's
Ruby control helpers instead.

See [Rails View Helpers](/docs/rails-native-components) for shell annotations
and [Rails Assets and URLs](/docs/rails-assets) for client-reachable assets.
