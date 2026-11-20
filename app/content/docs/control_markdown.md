# Markdown

Render Markdown content inside a Ruflet view.

## Example

```ruby
markdown(
  value: "# Hello\n\nThis is **Markdown**."
)
```

## Common properties

- `value`
- `code_theme`
- `selectable`
- `extension_set`

## Usage

```ruby
markdown(
  value: "## Release notes\n\n- Added controls\n- Improved builds"
)
```

## Notes

- Use `markdown` when content should stay text-first but still support formatting
