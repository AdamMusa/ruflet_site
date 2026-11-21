# CodeEditor

A syntax-highlighting code editor with line numbers, code folding and
autocomplete. It is provided by the `ruflet_code_editor` client extension, so
enable `code_editor` in `ruflet.yaml` and rebuild the client:

```yaml
extensions:
  - code_editor
```

iOS and macOS draw a Cupertino-styled editor; Android, web, Windows and Linux
draw the Material one. Both read the same properties.

## Example

```ruby
CODE = <<~RUBY
  class App < Ruflet::App
    def view(page)
      page.add(text(value: "Hello from Ruflet!"))
    end
  end
RUBY

length = text(value: "#{CODE.length} characters")
editor = code_editor(
  CODE,
  language: "ruby",
  code_theme: "atom-one-dark",
  read_only: false,
  expand: true,
  on_change: ->(event) { page.update(length, value: "#{event.control.props["value"].to_s.length} characters") }
)
page.add(column(expand: true, children: [editor, length]))
```

The first positional argument is the editor `value` (the code), so
`code_editor("puts 1", language: "ruby")` and
`code_editor(value: "puts 1", language: "ruby")` are equivalent.

## Properties

- `value` — the full text of the editor, including folded sections. The client
  writes it back as the user types, so `event.control.props["value"]` stays
  current.
- `language` — a [highlight.js](https://highlightjs.org/) language id used for
  syntax highlighting (e.g. `"ruby"`, `"python"`, `"javascript"`, `"json"`,
  `"yaml"`). When omitted or unknown, no highlighting is applied.
- `code_theme` — the colors of the highlighted code: a highlight.js theme name
  (e.g. `"atom-one-light"`, `"atom-one-dark"`, `"monokai-sublime"`,
  `"github"`), or a hash of highlight.js token names to text styles, such as
  `{ "keyword" => { color: "#c678dd" }, "string" => { color: "#98c379" } }`.
  Write theme and language names with hyphens, as highlight.js does: with the
  next release `:atom_one_dark` works too. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `text_style` — a text style for the code (`size`, `weight`, `font_family`, …).
- `padding` — padding around the editor content (default `0`).
- `read_only` — when `true`, the text cannot be edited (default `false`).
- `autofocus` — focus the editor when it first appears (default `false`).
- `autocomplete` — show a suggestion popup while typing (default `false`).
- `autocomplete_words` — an array of extra words offered by autocomplete.
- `selection` — the selection or cursor position, as
  `{ base_offset:, extent_offset: }` in characters. Set it to move the cursor;
  the client writes it back as the user moves it.
- `gutter_style` — the line-number column:
  `{ text_style:, background_color:, width: 80, margin: 10, show_line_numbers: true, show_folding_handles: true, show_errors: true }`.
- `expand` — fill the available space in a `row`/`column`.
- `width` / `height` — fixed size when not expanding.
- `tooltip`, `visible`, `opacity`, `rtl`, `disabled` — the usual layout
  properties; a `disabled` editor cannot be focused.

## Events

- `on_change` — the user changed the text. `event.control.props["value"]` holds
  the full text, as a String. `event.data` is the text too, except that 0.0.23
  decodes text that is valid JSON: `{"a": 1}` arrives as a Hash and `42` as an
  Integer. With 0.0.23 a `value` you set from Ruby also fires it. With the next
  release `event.data` is always the text, and only the user's edits fire it. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `on_selection_change` — the cursor or selection moved. `event.data` has
  `selected_text` and `selection`, a hash with `base_offset`, `extent_offset`,
  `affinity` and `directional`.
- `on_focus` — the editor gained focus.
- `on_blur` — the editor lost focus.

## Methods

Call these on a mounted editor. Each accepts `timeout:` and `on_result:`.

- `focus` — move the keyboard focus to the editor.
- `fold_at(line_number)` — fold the block that starts at this line (counted
  from 0).
- `fold_imports` — fold the block of import lines, in languages whose imports
  the editor recognizes, such as Python and Java.
- `fold_comment_at_line_zero` — fold a comment that starts on the first line.

```ruby
editor = code_editor("import json\nimport time\n\nprint(time.time())", language: "python", expand: true)
page.add(editor)
page.add(button("Fold imports", on_click: ->(_event) { editor.fold_imports }))
```

## Reference

- Family: `materials`
- Widget type: `codeeditor`
- Helpers: `code_editor`, `codeeditor`
