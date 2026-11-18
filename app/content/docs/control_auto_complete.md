# AutoComplete

A text field that suggests matching entries as the user types. Ruflet filters
the suggestions on the client: an entry matches when its value contains the
typed text, ignoring case.

## Example

```ruby
picked = text(value: "Pick a country")
page.add(
  column(
    children: [
      auto_complete(
        [
          auto_complete_suggestion(key: "fr", value: "France"),
          auto_complete_suggestion(key: "de", value: "Germany"),
          auto_complete_suggestion(key: "jp", value: "Japan")
        ],
        on_select: ->(event) { page.update(picked, value: "Selected #{event.value}") }
      ),
      picked
    ]
  )
)
```

## Common properties

- `suggestions` — `auto_complete_suggestion(key:, value:)` entries; the first positional argument sets them
- `value` — the text in the field
- `suggestions_max_height` — height of the suggestion list (default 200)
- `on_change` — the text changed; `event.data` is the text
- `on_select` — a suggestion was picked; `event.value` is its value and `event.selection` holds its `key` and `value`

## Usage

`auto_complete_suggestion` needs a `key` or a `value`; when one is missing it
copies the other. Use the `key` for your own identifier and the `value` for the
text the user sees.
