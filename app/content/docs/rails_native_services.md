# Rails Service Actions

`Ruflet::Rails.native_app` can promote four annotated Rails actions to client
services. These helpers emit normal HTML plus `data-ruflet-action` metadata.

## Share

```erb
<%= ruflet_share_link "Share invite",
      invite_path(@invite),
      text: "Join my workspace",
      title: "Invitation",
      subject: "You're invited" %>
```

`ruflet_share_link(label, href = "#", text:, title:, subject:, url:, files:)`
accepts any subset of the optional payload fields.

## Clipboard

```erb
<%= ruflet_copy_button "Copy code", text: @invite.code, toast: "Copied" %>
```

`haptic:` defaults to `true` and can be disabled.

## Launch a URL

```erb
<%= ruflet_launch_link "Open website", "https://example.com", mode: "externalApplication" %>
```

The `href` remains a normal browser destination. `mode:` is passed to the
native URL-launcher service.

## Haptic feedback

```erb
<%= ruflet_haptic_button "Saved", style: "selection" %>
```

The style defaults to `selection`; use a style supported by the client haptic
service.

These helpers cover annotated actions from Rails HTML. For the full Ruby
service API available to Ruflet control apps, see
[Services and Device APIs](/docs/services-and-plugins).
