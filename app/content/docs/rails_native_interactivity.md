# Navigation and Forms

Native HTML screens are interactive with the same tags you already know: links
navigate, buttons post to Rails, forms submit. State lives on the server, so
every interaction is an ordinary request.

## Navigation

A link pushes a new native screen, fetched from its URL. The native back button
and gesture pop it:

```erb
<a href="<%= settings_path %>">Settings</a>
```

Set `nav` to change how it navigates:

- `push` (default) — add a screen on top
- `replace` — swap the current screen
- `root` — reset the stack to this screen (tab-style)
- `back` — pop the current screen

```erb
<a href="<%= dashboard_path %>" nav="root">Home</a>
<a href="<%= step_two_path %>" nav="replace">Continue</a>
```

## Actions

An `on-click` posts to Rails and re-renders the current screen in place with the
response. This is the pattern for buttons that change state — the count, a like,
a toggle:

```erb
<button on-click="<%= like_path(post) %>">Like</button>
```

The value is a path (POST by default), or `verb:path` for another method:

```erb
<button on-click="delete:<%= item_path(item) %>" variant="outlined">Delete</button>
```

Because Rails `redirect_to` is followed, a controller can `redirect_back` or
`redirect_to` another screen and the client re-renders the target. Put
`on-click` on any element — a card, a row — to make the whole thing tappable.

Button variants: `filled`, `tonal`, `outlined`, `text`, `elevated`. Add an
`icon`; an icon-only button becomes a native icon button.

## Forms

A `<form>` with named fields tracks values natively and submits them like a
normal Rails form, then renders the response:

```erb
<form action="<%= session_path %>" method="post">
  <column class="p-6 gap-4">
    <h2>Sign in</h2>
    <input type="email" name="email" label="Email" placeholder="you@example.com">
    <input type="password" name="password" label="Password">
    <input type="checkbox" name="remember" label="Remember me" checked>
    <input type="submit" value="Sign in">
  </column>
</form>
```

`<input>` supports `text`, `email`, `password`, `number`, `tel`, `url`,
`checkbox`, `range`, `radio`, `hidden`, and `submit`. `<textarea>` and `<select>`
(with `<option>`) work too. Requests carry the Rails session and CSRF token
automatically, so `protect_from_forgery` stays on.

## App chrome

Promote page chrome to native controls with dedicated tags.

**App bar** — a title, an optional back button, and action buttons:

```erb
<appbar title="Inbox" class="bg-emerald-600"
        leading-icon="arrow_back" leading-href="<%= root_path %>" leading-nav="root">
  <action icon="search" href="<%= search_path %>"></action>
  <action icon="more_vert" href="<%= settings_path %>"></action>
</appbar>
```

**Bottom navigation** — a tab bar; each tab resets to its URL as a new root:

```erb
<bottom-nav>
  <nav-item icon="chat" label="Chats" href="<%= chats_path %>" selected></nav-item>
  <nav-item icon="call" label="Calls" href="<%= calls_path %>"></nav-item>
</bottom-nav>
```

**Floating action button:**

```erb
<fab icon="add" href="<%= new_item_path %>"></fab>
```

## A worked example: a counter

The count lives in the session; each tap posts and re-renders:

```ruby
class CounterController < ApplicationController
  layout "native"

  def show
    @count = session[:count] ||= 0
  end

  def increment
    session[:count] = session[:count].to_i + 1
    redirect_to counter_path
  end
end
```

```erb
<appbar title="Counter"></appbar>

<column class="p-6 gap-8 items-center justify-center flex-1">
  <text class="text-5xl font-bold"><%= @count %></text>
  <button variant="filled" icon="add" on-click="<%= increment_path %>">Add</button>
</column>
```

## Related guides

- [Native HTML Apps](/docs/rails-native-html)
- [Components](/docs/rails-native-components)
- [Services and Extensions](/docs/rails-native-services)
