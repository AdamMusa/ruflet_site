# AutoComplete

A text field that suggests matching entries as the user types. Ruflet filters
the suggestions on the client: an entry matches when its `key` contains the
typed text, ignoring case. The list shows each entry's `value`.

## Example

```ruby
picked = text(value: "Pick a country")
page.add(
  column(
    children: [
      auto_complete(
        [
          auto_complete_suggestion(value: "France"),
          auto_complete_suggestion(value: "Germany"),
          auto_complete_suggestion(value: "Japan")
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
- `value` — the text in the field; on iOS and macOS only the starting text, so a later `page.update` of `value` does not change the field there
- `suggestions_max_height` — height of the suggestion list (default 200)
- `on_change` — the text changed; `event.data` is the text
- `on_select` — a suggestion was picked; `event.value` is its value and `event.selection` holds its `key` and `value`

## Usage

`auto_complete_suggestion` needs a `key` or a `value`; when one is missing it
copies the other. Give only `value:`, as above, so that the user searches the
same text they see. When you also pass a `key`, it must hold the searchable
text: typing "Ger" does not find `key: "de", value: "Germany"`. After a pick,
Material clients fill the field with the `value` and iOS and macOS with the
`key`.
