# Form

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). On 0.0.23 `validator:` raises ArgumentError (unknown keyword).

Groups input fields that validate, save and reset together, like Flutter's
`Form`. Validators are Ruby lambdas and run on the server; the client lays the
form out like a `column`.

## Example

```ruby
status = text(value: "")

create_account = ->(form) {
  if form.validate
    values = form.save
    page.update(status, value: "Welcome, #{values["email"]}")
  else
    page.update(status, value: "Check the highlighted fields")
  end
}

signup = form(
  spacing: 12,
  on_submit: ->(event) { create_account.call(event.control) },
  controls: [
    text_field(
      label: "Email",
      key: "email",
      validator: ->(value) { "Enter an email address" unless value.include?("@") }
    ),
    checkbox(
      label: "I accept the terms",
      key: "terms",
      validator: ->(value) { "Please accept the terms" unless value }
    ),
    filled_button(
      content: text("Create account"),
      on_click: ->(_event) { create_account.call(signup) }
    )
  ]
)

page.add(signup)
page.add(status)
```

Pass the fields as `controls:`, as the first argument, or in a block.

## Field options

Fields anywhere below the form take part, for example inside a `row` or a
[`form_row`](/docs/control-form-row). A nested `form` owns its own fields.
These inputs are form fields: `text_field` (and `cupertino_text_field`),
`dropdown`, `checkbox`, `switch`, `radio_group`, `slider`, `range_slider`,
`date_picker`, `time_picker` and `segmented_button`.

Each field accepts three Ruby-only options. Like event handlers, they stay on
the server and are never sent to the client:

- `validator:` — `->(value) { ... }` returns an error message String, or `nil` when the value is valid.
- `on_saved:` — `->(value) { ... }` is called by `form.save` with the field's value.
- `autovalidate_mode:` — when the field validates itself: `"disabled"` (default), `"always"`, `"on_user_interaction"` or `"on_unfocus"`.

`text_field` shows the message as its `error`, `dropdown` as its `error_text`,
and `checkbox` turns on its error state. Other fields, such as `switch`,
`radio_group` and `slider`, have no error display, so read their messages from
`form.errors`.

## Autovalidate modes

Set `autovalidate_mode:` on the form for every field, or on one field:

- `"disabled"` — validate only when you call `form.validate`.
- `"always"` — validate on every page update and every field change.
- `"on_user_interaction"` — validate a field once the user has changed it; on the form, once any field changed. `form.reset` ends it.
- `"on_unfocus"` — validate a field when it loses focus.

```ruby
page.add(
  form(
    autovalidate_mode: "on_user_interaction",
    controls: [
      text_field(
        label: "Username",
        validator: ->(value) { "At least 3 characters" if value.length < 3 }
      )
    ]
  )
)
```

## Form methods

- `validate` — runs the validator of every visible, enabled field, shows the errors and returns `true` when all fields are valid.
- `save` — calls `on_saved` for every visible field that has one, then returns `values`.
- `reset` — puts every field back to the value it had when it joined the form and clears the errors.
- `values` — `{ key => value }` for every visible field. The key is the field's `key:`, or its id.
- `errors` — `{ key => message }` for the fields whose last validation failed.
- `fields` — the fields of the form, in tree order.

`validate` and `reset` send one page update themselves; you do not need to
call `page.update` after them.

## Events

- `on_submit` — the user pressed Enter in one of the form's text fields. `event.control` is the form.
- `on_change` — any field of the form changed.

## Layout properties

The form lays out its `controls` like a `column`: `spacing`, `alignment`,
`horizontal_alignment`, `tight`, `scroll`, `expand` and the common layout
properties.
