# FormRow

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). With 0.0.23 the client shows "Unknown control".

A labeled row for one field: a leading `prefix` label, the field aligned to the
end, and optional `helper` and `error` lines below. Material clients draw a
padded row; iOS clients draw a `CupertinoFormRow`.

## Example

```ruby
page.add(
  list_section(
    [
      form_row(
        switch(value: true),
        prefix: "Notifications",
        helper: "Alerts for new messages"
      ),
      form_row(
        text_field(width: 180, hint_text: "Your name"),
        prefix: "Name"
      )
    ],
    header: text("Profile")
  )
)
```

The field is the first argument or `content:`. `form_row` raises
ArgumentError without one.

## Properties

- `content` — the field (required).
- `prefix` — the leading label, as a String or a control.
- `helper` — a hint line under the row, as a String or a control.
- `error` — an error line under the row, as a String or a control.
- `padding` — space around the row.

## Usage

`form_row` only lays a field out. To validate the field, put the rows inside a
[`form`](/docs/control-form) and give the field a `validator:`. To show a
validation message in the row, set its `error`:

```ruby
name_field = text_field(width: 180)
name_row = form_row(name_field, prefix: "Name")

page.add(
  column(
    children: [
      name_row,
      filled_button(
        content: text("Save"),
        on_click: ->(_event) {
          message = name_field.props["value"].to_s.empty? ? "Enter your name" : nil
          page.update(name_row, error: message)
        }
      )
    ]
  )
)
```
