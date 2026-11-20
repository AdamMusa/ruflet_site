# Markdown

Render Markdown content inside a Ruflet view.

## Example

```ruby
markdown(
  value: "# Hello\n\nThis is **Markdown**."
)
```

## Common properties

- `value` — the Markdown source; the first positional argument sets it
- `code_theme` — highlighting for fenced code blocks, a theme name such as `"atom-one-dark"` or `"github"`
- `selectable` — let the user select the text
- `extension_set` — `"none"` (default), `"commonMark"`, `"gitHubWeb"` or `"gitHubFlavored"`; tables, task lists and strikethrough need `"gitHubFlavored"`

## Usage

```ruby
markdown(
  value: "## Release notes\n\n- Added controls\n- Improved builds"
)
```

Links do nothing until you handle them: set `auto_follow_links: true` to open
them in the browser, or handle `on_tap_link`, whose `event.data` is the link's
URL.

```ruby
notes = <<~MD
  ## Changelog

  | Version | Change |
  | --- | --- |
  | 0.0.23 | Rails grids |

  Read the [full notes](https://ruflet.dev/docs), or run `ruflet update`.
MD

page.add(
  markdown(
    notes,
    extension_set: "gitHubFlavored",
    code_theme: "atom-one-dark",
    selectable: true,
    on_tap_link: ->(event) { page.launch_url(event.data) }
  )
)
```

## Styling

- `md_style_sheet` — text styles per element: `{ h1_text_style:, h2_text_style:, p_text_style:, a_text_style:, code_text_style:, ... }`, each a style hash such as `{ size: 28, weight: "bold" }`.
- `code_style_sheet` — the same for code blocks.
- `latex_style` and `latex_scale_factor` — formulas written as `$...$` or `$$...$$`.
- `soft_line_break: true` — keep single line breaks in the source.
- `fit_content` and `shrink_wrap` — both default to `true`: the markdown takes only the size of its content.
- `image_error_content` — a control shown for an image that fails to load.

## Events

- `on_tap_link` — `event.data` is the URL.
- `on_tap_text` — a tap on text that is not a link.
- `on_selection_change` — with `selectable: true`; `event.data[:text]` is the selected text.

## Notes

- Use `markdown` when content should stay text-first but still support formatting
