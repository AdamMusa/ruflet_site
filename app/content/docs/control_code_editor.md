# CodeEditor

A syntax-highlighting code editor with line folding, autocomplete, and an
optional gutter. Backed by the Flet
[`CodeEditor`](https://flet.dev/docs/controls/codeeditor/) extension, so the
`code_editor` extension must be enabled in `ruflet.yaml`:

```yaml
extensions:
  - code_editor
```

## Example

```ruby
CODE = <<~RUBY
  class App < Ruflet::App
    def view(page)
      page.add(text(value: "Hello from Ruflet!"))
    end
  end
RUBY

editor = code_editor(
  CODE,
  language: "ruby",
  code_theme: "atom-one-dark",
  read_only: false,
  expand: true,
  on_change: ->(event) { @length = event.data.to_s.length }
)
```

The first positional argument is the editor `value` (the code), so
`code_editor("puts 1", language: "ruby")` and
`code_editor(value: "puts 1", language: "ruby")` are equivalent.

## Properties

- `value` — the full text of the editor, including folded sections.
- `language` — a [highlight.js](https://highlightjs.org/) language id used for
  syntax highlighting (e.g. `"ruby"`, `"python"`, `"javascript"`, `"json"`,
  `"yaml"`). When omitted, no highlighting is applied.
- `code_theme` — a highlight.js theme name shared with Markdown
  (e.g. `"atom-one-light"`, `"atom-one-dark"`, `"monokai-sublime"`,
  `"github"`).
- `text_style` — a text style map for the editor content (`size`, `weight`,
  `font_family`, …).
- `padding` — padding around the editor content.
- `read_only` — when `true`, the text cannot be edited (default `false`).
- `autofocus` — focus the editor on mount (default `false`).
- `autocomplete` — enable the autocomplete popup (default `false`).
- `autocomplete_words` — an array of words offered by autocomplete.
- `selection` — the current text selection / caret position
  (`{ base_offset:, extent_offset: }`).
- `gutter_style` — styling for the line-number gutter.
- `expand` — fill the available space in a `row`/`column`.
- `width` / `height` — fixed size when not expanding.
- `tooltip`, `visible`, `opacity`, `rtl`, `disabled` — the usual layout
  properties.

## Events

- `on_change` — the text changed (data: the new value).
- `on_selection_change` — the selection or caret position changed.
- `on_focus` — the editor gained focus.
- `on_blur` — the editor lost focus.

## Reference

- Family: `materials`
- Widget type: `codeeditor`
- Helper: `code_editor`
